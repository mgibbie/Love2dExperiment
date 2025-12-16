-- Shop Scene
-- Buy jokers, consumables, booster packs, and vouchers

local GameState = require("micatro.core.game_state")
local Card = require("micatro.core.card")
local CardArea = require("micatro.core.card_area")
local Jokers = require("micatro.data.jokers")
local Tarots = require("micatro.data.tarots")
local Planets = require("micatro.data.planets")
local Vouchers = require("micatro.data.vouchers")
local Sprites = require("micatro.core.sprites")
local CardRender = require("micatro.ui.card_render")

local M = {}

-- External game state (passed from play scene)
local gameState = nil

-- Shop items
local shopItems = {}
local boosterPacks = {}
local voucherSlot = nil
local rerollCost = 5

-- Card areas
local jokerArea = nil
local consumableArea = nil

-- UI
local hoveredItem = nil
local hoveredButton = nil
local elapsedTime = 0
local bgShader = nil
local selectedCard = nil  -- Currently selected card for use/sell
local useButtonHovered = false
local sellButtonHovered = false

-- Constants
local CARD_WIDTH = 71
local CARD_HEIGHT = 95

function M.load()
    -- Load sprites
    Sprites.load()
    CardRender.loadSprites()
    CardRender.loadShaders()
    
    -- Load background shader
    local code = love.filesystem.read("shaders/balatro_bg.glsl")
    if code then
        local success, shader = pcall(love.graphics.newShader, code)
        if success then
            bgShader = shader
        end
    end
end

function M.enter()
    elapsedTime = 0
    
    -- Get or create game state (always check global first)
    if _G.MICATRO_GAME_STATE then
        gameState = _G.MICATRO_GAME_STATE
    elseif not gameState then
        gameState = GameState.new("b_red")
    end
    
    -- Set up card areas
    local w, h = love.graphics.getDimensions()
    
    jokerArea = CardArea.new(CardArea.TYPE.JOKER, {
        x = w * 0.05,
        y = h * 0.72,
        width = w * 0.55,
        height = 100,
        cardWidth = CARD_WIDTH,
        cardHeight = CARD_HEIGHT,
        maxCards = gameState.joker_slots,
        spacing = 15
    })
    
    consumableArea = CardArea.new(CardArea.TYPE.CONSUMABLE, {
        x = w * 0.65,
        y = h * 0.72,
        width = w * 0.3,
        height = 100,
        cardWidth = CARD_WIDTH * 0.9,
        cardHeight = CARD_HEIGHT * 0.9,
        maxCards = gameState.consumable_slots,
        spacing = 10
    })
    
    -- Populate existing jokers and consumables
    for _, jokerData in ipairs(gameState.jokers) do
        local card = Card.newJoker(jokerData.data)
        card.ability = jokerData.ability
        card.edition = jokerData.edition
        card.sell_value = jokerData.sell_value
        jokerArea:addCard(card)
    end
    
    for _, consData in ipairs(gameState.consumables) do
        local card = Card.newConsumable(consData.data)
        card.edition = consData.edition
        consumableArea:addCard(card)
    end
    
    -- Process pack results if returning from pack scene
    if _G.MICATRO_PACK_RESULT then
        local packResult = _G.MICATRO_PACK_RESULT
        print("Shop: Found pack result with " .. (type(packResult) == "table" and #packResult or 0) .. " cards")
        if type(packResult) == "table" and #packResult > 0 then
            for _, cardData in ipairs(packResult) do
                print("Shop: Processing card: " .. (cardData.name or "unknown") .. " (set: " .. tostring(cardData.set) .. ")")
                if cardData and cardData.set then
                    local set = cardData.set
                    if set == "Joker" then
                        -- Add joker to joker area
                        if jokerArea:hasRoom() then
                            local card = Card.newJoker(cardData)
                            jokerArea:addCard(card)
                            -- Also add to game state
                            GameState.addJoker(gameState, cardData)
                        end
                    elseif set == "Tarot" or set == "Planet" or set == "Spectral" then
                        -- Add consumable to consumable area
                        if consumableArea:hasRoom() then
                            local card = Card.newConsumable(cardData)
                            consumableArea:addCard(card)
                            -- Also add to game state
                            GameState.addConsumable(gameState, cardData)
                        else
                            print("No room in consumable area for: " .. (cardData.name or "unknown"))
                        end
                    else
                        print("Unknown card set: " .. tostring(set) .. " for card: " .. (cardData.name or "unknown"))
                    end
                else
                    print("Invalid card data in pack result")
                end
            end
        end
        -- Clear the pack result
        _G.MICATRO_PACK_RESULT = nil
    end
    
    -- Generate shop items
    M.generateShop()
end

function M.exit()
    -- Sync jokers back to game state
    gameState.jokers = {}
    for _, card in ipairs(jokerArea:getCards()) do
        table.insert(gameState.jokers, {
            data = card.data,
            ability = card.ability,
            edition = card.edition,
            sell_value = card.sell_value
        })
    end
    
    gameState.consumables = {}
    for _, card in ipairs(consumableArea:getCards()) do
        table.insert(gameState.consumables, {
            data = card.data,
            edition = card.edition
        })
    end
    
    -- Store game state globally for other scenes
    _G.MICATRO_GAME_STATE = gameState
end

function M.generateShop()
    shopItems = {}
    
    -- Generate jokers (2 slots by default)
    local numJokers = 2
    for i = 1, numJokers do
        local jokerData = Jokers.getRandom()
        table.insert(shopItems, {
            type = "joker",
            data = jokerData,
            cost = jokerData.cost,
            sold = false,
            x = 0, y = 0
        })
    end
    
    -- Generate consumables (2 slots)
    for i = 1, 2 do
        local roll = math.random(100)
        local cardData
        if roll <= 60 then
            cardData = Tarots.getRandom()
        else
            cardData = Planets.getRandom()
        end
        table.insert(shopItems, {
            type = "consumable",
            data = cardData,
            cost = cardData.cost,
            sold = false,
            x = 0, y = 0
        })
    end
    
    -- Generate booster packs (2 slots)
    -- Pack positions in boosters.png atlas based on type
    local packPositions = {
        arcana = {x = 0, y = 0},
        celestial = {x = 0, y = 1},
        spectral = {x = 0, y = 4},
        standard = {x = 0, y = 6},
        buffoon = {x = 0, y = 8}
    }
    
    boosterPacks = {
        {
            type = "pack",
            name = "Arcana Pack",
            packType = "arcana",
            cost = 4,
            cards = 3,
            choose = 1,
            pos = packPositions.arcana,
            x = 0, y = 0
        },
        {
            type = "pack",
            name = "Celestial Pack",
            packType = "celestial",
            cost = 4,
            cards = 3,
            choose = 1,
            pos = packPositions.celestial,
            x = 0, y = 0
        }
    }
    
    -- Generate voucher
    local availableVouchers = Vouchers.getAvailable(gameState.vouchers)
    if #availableVouchers > 0 then
        local voucher = availableVouchers[math.random(#availableVouchers)]
        voucherSlot = {
            type = "voucher",
            data = voucher,
            cost = voucher.cost,
            sold = false,
            x = 0, y = 0
        }
    else
        voucherSlot = nil
    end
    
    M.updateShopLayout()
end

function M.updateShopLayout()
    local w, h = love.graphics.getDimensions()
    
    -- Shop items layout (top section)
    local itemY = h * 0.2
    local totalItems = #shopItems
    local itemSpacing = 100
    local startX = (w - (totalItems - 1) * itemSpacing) / 2
    
    for i, item in ipairs(shopItems) do
        item.x = startX + (i - 1) * itemSpacing
        item.y = itemY
    end
    
    -- Booster packs (right side)
    local packX = w * 0.82
    local packY = h * 0.25
    for i, pack in ipairs(boosterPacks) do
        pack.x = packX
        pack.y = packY + (i - 1) * 120
    end
    
    -- Voucher (left side)
    if voucherSlot then
        voucherSlot.x = w * 0.12
        voucherSlot.y = h * 0.25
    end
end

function M.update(dt)
    elapsedTime = elapsedTime + dt
    
    if bgShader then
        bgShader:send("iTime", elapsedTime)
        local w, h = love.graphics.getDimensions()
        bgShader:send("iResolution", {w, h})
    end
    
    jokerArea:update(dt)
    consumableArea:update(dt)
end

function M.draw()
    local w, h = love.graphics.getDimensions()
    
    -- Background
    if bgShader then
        love.graphics.setShader(bgShader)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", 0, 0, w, h)
        love.graphics.setShader()
    else
        love.graphics.setColor(0.12, 0.08, 0.18, 1)
        love.graphics.rectangle("fill", 0, 0, w, h)
    end
    
    -- Title
    love.graphics.setColor(1, 1, 1, 1)
    local titleFont = love.graphics.newFont(32)
    love.graphics.setFont(titleFont)
    love.graphics.printf("SHOP", 0, 20, w, "center")
    
    -- Money display
    love.graphics.setColor(0.1, 0.1, 0.15, 0.9)
    love.graphics.rectangle("fill", w - 140, 15, 120, 40, 8)
    love.graphics.setColor(1, 0.85, 0.4, 1)
    local moneyFont = love.graphics.newFont(24)
    love.graphics.setFont(moneyFont)
    love.graphics.printf("$" .. gameState.money, w - 135, 22, 110, "center")
    
    -- Draw shop items
    for _, item in ipairs(shopItems) do
        M.drawShopItem(item)
    end
    
    -- Draw booster packs
    for _, pack in ipairs(boosterPacks) do
        M.drawBoosterPack(pack)
    end
    
    -- Draw voucher
    if voucherSlot then
        M.drawVoucher(voucherSlot)
    end
    
    -- Draw owned cards
    M.drawCardArea(jokerArea, "Your Jokers (Click to sell)")
    M.drawCardArea(consumableArea, "Consumables")
    
    -- Draw buttons
    M.drawButtons()
end

function M.drawShopItem(item)
    if item.sold then return end
    
    local w, h = CARD_WIDTH, CARD_HEIGHT
    local isHovered = hoveredItem == item
    local scale = isHovered and 1.08 or 1
    
    -- Create a temporary card object for rendering
    local tempCard = nil
    if item.type == "joker" then
        tempCard = Card.newJoker(item.data)
    elseif item.type == "consumable" then
        tempCard = Card.newConsumable(item.data)
    end
    
    if tempCard then
        tempCard.x = item.x
        tempCard.y = item.y
        tempCard.scale = scale
        tempCard.hovered = isHovered
        
        -- Draw the card using CardRender
        if item.type == "joker" then
            CardRender.drawJokerCard(tempCard, item.x, item.y, w * scale, h * scale, elapsedTime)
        elseif item.type == "consumable" then
            CardRender.drawConsumableCard(tempCard, item.x, item.y, w * scale, h * scale, elapsedTime)
        end
    else
        -- Fallback to placeholder if card type not supported
        love.graphics.push()
        love.graphics.translate(item.x, item.y)
        love.graphics.scale(scale, scale)
        
        love.graphics.setColor(0.95, 0.95, 0.98, 1)
        love.graphics.rectangle("fill", -w/2, -h/2, w, h, 6)
        
        love.graphics.setColor(0.2, 0.2, 0.3, 1)
        local nameFont = love.graphics.newFont(11)
        love.graphics.setFont(nameFont)
        love.graphics.printf(item.data.name or "Item", -w/2 + 2, -h/2 + 8, w - 4, "center")
        
        love.graphics.pop()
    end
    
    -- Price tag
    local canAfford = gameState.money >= item.cost
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", item.x - 25, item.y + h/2 * scale + 5, 50, 22, 6)
    
    if canAfford then
        love.graphics.setColor(1, 0.85, 0.4, 1)
    else
        love.graphics.setColor(0.6, 0.4, 0.4, 1)
    end
    local priceFont = love.graphics.newFont(14)
    love.graphics.setFont(priceFont)
    love.graphics.printf("$" .. item.cost, item.x - 25, item.y + h/2 * scale + 8, 50, "center")
end

function M.drawBoosterPack(pack)
    local pw, ph = CARD_WIDTH, CARD_HEIGHT
    local isHovered = hoveredItem == pack
    local scale = isHovered and 1.05 or 1
    
    -- Get pack position from data
    local posX, posY = 0, 0
    if pack.pos then
        posX = pack.pos.x or 0
        posY = pack.pos.y or 0
    end
    
    local quad, image = Sprites.getQuad("boosters", posX, posY)
    
    love.graphics.push()
    love.graphics.translate(pack.x, pack.y)
    love.graphics.scale(scale, scale)
    
    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", -pw/2 + 4, -ph/2 + 4, pw, ph, 6)
    
    if quad and image then
        -- Draw sprite
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(image, quad, -pw/2, -ph/2)
    else
        -- Fallback to colored rectangle
        local packColors = {
            arcana = {0.6, 0.4, 0.8},
            celestial = {0.3, 0.5, 0.8},
            spectral = {0.5, 0.3, 0.7},
            standard = {0.7, 0.5, 0.4},
            buffoon = {0.8, 0.4, 0.3}
        }
        local col = packColors[pack.packType] or {0.5, 0.5, 0.5}
        love.graphics.setColor(col[1], col[2], col[3], 1)
        love.graphics.rectangle("fill", -pw/2, -ph/2, pw, ph, 6)
        
        -- Name
        love.graphics.setColor(1, 1, 1, 1)
        local nameFont = love.graphics.newFont(12)
        love.graphics.setFont(nameFont)
        love.graphics.printf(pack.name, -pw/2, -ph/2 + 10, pw, "center")
    end
    
    love.graphics.pop()
    
    -- Price
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", pack.x - 25, pack.y + ph/2 * scale + 5, 50, 22, 6)
    
    local canAfford = gameState.money >= pack.cost
    if canAfford then
        love.graphics.setColor(1, 0.85, 0.4, 1)
    else
        love.graphics.setColor(0.6, 0.4, 0.4, 1)
    end
    local priceFont = love.graphics.newFont(14)
    love.graphics.setFont(priceFont)
    love.graphics.printf("$" .. pack.cost, pack.x - 25, pack.y + ph/2 * scale + 8, 50, "center")
end

function M.drawVoucher(voucher)
    if voucher.sold then return end
    
    local vw, vh = CARD_WIDTH, CARD_HEIGHT
    local isHovered = hoveredItem == voucher
    local scale = isHovered and 1.05 or 1
    
    -- Get voucher position from data
    local posX, posY = 0, 0
    if voucher.data and voucher.data.pos then
        posX = voucher.data.pos.x or 0
        posY = voucher.data.pos.y or 0
    end
    
    local quad, image = Sprites.getVoucherQuad(posX, posY)
    
    love.graphics.push()
    love.graphics.translate(voucher.x, voucher.y)
    love.graphics.scale(scale, scale)
    
    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", -vw/2 + 4, -vh/2 + 4, vw, vh, 6)
    
    if quad and image then
        -- Draw sprite
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(image, quad, -vw/2, -vh/2)
    else
        -- Fallback to colored rectangle
        love.graphics.setColor(0.9, 0.7, 0.3, 1)
        love.graphics.rectangle("fill", -vw/2, -vh/2, vw, vh, 6)
        
        -- Border
        love.graphics.setColor(0.7, 0.5, 0.2, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", -vw/2, -vh/2, vw, vh, 6)
        
        -- Name
        love.graphics.setColor(0.3, 0.2, 0.1, 1)
        local nameFont = love.graphics.newFont(11)
        love.graphics.setFont(nameFont)
        love.graphics.printf(voucher.data.name, -vw/2 + 2, -vh/2 + 8, vw - 4, "center")
    end
    
    love.graphics.pop()
    
    -- Price
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", voucher.x - 25, voucher.y + vh/2 * scale + 5, 50, 22, 6)
    
    local canAfford = gameState.money >= voucher.cost
    if canAfford then
        love.graphics.setColor(1, 0.85, 0.4, 1)
    else
        love.graphics.setColor(0.6, 0.4, 0.4, 1)
    end
    local priceFont = love.graphics.newFont(14)
    love.graphics.setFont(priceFont)
    love.graphics.printf("$" .. voucher.cost, voucher.x - 25, voucher.y + vh/2 * scale + 8, 50, "center")
end

function M.drawCardArea(area, label)
    love.graphics.setColor(0.1, 0.1, 0.15, 0.6)
    love.graphics.rectangle("fill", area.x - 10, area.y - 25, area.width + 20, area.height + 30, 8)
    
    if label then
        love.graphics.setColor(0.7, 0.7, 0.8, 0.8)
        local labelFont = love.graphics.newFont(12)
        love.graphics.setFont(labelFont)
        love.graphics.print(label, area.x, area.y - 20)
    end
    
    -- Draw slots
    for i = 1, area.maxCards do
        local x = area.x + area.cardWidth / 2 + 10 + (i - 1) * (area.cardWidth + area.spacing)
        local y = area.y + area.height / 2
        
        love.graphics.setColor(0.2, 0.2, 0.3, 0.4)
        love.graphics.rectangle("fill", x - area.cardWidth/2, y - area.cardHeight/2, 
            area.cardWidth, area.cardHeight, 6)
    end
    
    -- Draw cards using CardRender
    for _, card in ipairs(area:getCards()) do
        local isHovered = card.hovered
        local scale = isHovered and 1.08 or 1
        
        -- Highlight selected card
        if selectedCard == card then
            love.graphics.setColor(1, 0.85, 0.4, 0.3)
            love.graphics.rectangle("fill", card.x - area.cardWidth/2 - 2, card.y - area.cardHeight/2 - 2,
                area.cardWidth + 4, area.cardHeight + 4, 8)
        end
        
        if card.type == Card.TYPE.JOKER then
            CardRender.drawJokerCard(card, card.x, card.y, 
                area.cardWidth * scale, area.cardHeight * scale, elapsedTime)
        elseif card.type == Card.TYPE.TAROT or card.type == Card.TYPE.PLANET or card.type == Card.TYPE.SPECTRAL then
            CardRender.drawConsumableCard(card, card.x, card.y, 
                area.cardWidth * scale, area.cardHeight * scale, elapsedTime)
        end
        
        -- Draw use/sell buttons if selected
        if selectedCard == card then
            local ConsumableEffects = require("micatro.core.consumable_effects")
            local canUse = false
            local selectedCards = {}  -- Empty for shop, would need hand selection in play scene
            
            -- Check if consumable can be used
            if card.type == Card.TYPE.TAROT or card.type == Card.TYPE.PLANET or card.type == Card.TYPE.SPECTRAL then
                canUse = ConsumableEffects.canUse(card, gameState, selectedCards)
            end
            
            local cardW, cardH = area.cardWidth, area.cardHeight
            
            -- Use button (left side, only for consumables that can be used)
            if canUse then
                local useBtnX = card.x - cardW/2 - 50
                local useBtnY = card.y
                local useBtnW, useBtnH = 45, 30
                
                if useButtonHovered then
                    love.graphics.setColor(0.3, 0.7, 0.4, 1)
                else
                    love.graphics.setColor(0.2, 0.5, 0.3, 1)
                end
                love.graphics.rectangle("fill", useBtnX, useBtnY - useBtnH/2, useBtnW, useBtnH, 6)
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.setLineWidth(2)
                love.graphics.rectangle("line", useBtnX, useBtnY - useBtnH/2, useBtnW, useBtnH, 6)
                
                local btnFont = love.graphics.newFont(12)
                love.graphics.setFont(btnFont)
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.printf("USE", useBtnX, useBtnY - 8, useBtnW, "center")
            end
            
            -- Sell button (right side)
            local sellBtnX = card.x + cardW/2 + 5
            local sellBtnY = card.y
            local sellBtnW, sellBtnH = 45, 30
            
            if sellButtonHovered then
                love.graphics.setColor(0.7, 0.3, 0.3, 1)
            else
                love.graphics.setColor(0.5, 0.2, 0.2, 1)
            end
            love.graphics.rectangle("fill", sellBtnX, sellBtnY - sellBtnH/2, sellBtnW, sellBtnH, 6)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", sellBtnX, sellBtnY - sellBtnH/2, sellBtnW, sellBtnH, 6)
            
            local btnFont = love.graphics.newFont(12)
            love.graphics.setFont(btnFont)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf("SELL", sellBtnX, sellBtnY - 8, sellBtnW, "center")
        end
    end
end

function M.drawButtons()
    local w, h = love.graphics.getDimensions()
    
    -- Reroll button
    local rerollX, rerollY = w/2 - 60, h * 0.38
    local rerollW, rerollH = 120, 40
    local isRerollHovered = hoveredButton == "reroll"
    
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", rerollX + 3, rerollY + 3, rerollW, rerollH, 8)
    
    if isRerollHovered then
        love.graphics.setColor(0.4, 0.5, 0.6, 1)
    else
        love.graphics.setColor(0.3, 0.35, 0.45, 1)
    end
    love.graphics.rectangle("fill", rerollX, rerollY, rerollW, rerollH, 8)
    
    love.graphics.setColor(1, 1, 1, 1)
    local btnFont = love.graphics.newFont(14)
    love.graphics.setFont(btnFont)
    love.graphics.printf("Reroll $" .. rerollCost, rerollX, rerollY + 12, rerollW, "center")
    
    -- Next Round button
    local nextX, nextY = w/2 - 80, h * 0.92
    local nextW, nextH = 160, 50
    local isNextHovered = hoveredButton == "next"
    
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", nextX + 3, nextY + 3, nextW, nextH, 8)
    
    if isNextHovered then
        love.graphics.setColor(0.3, 0.6, 0.4, 1)
    else
        love.graphics.setColor(0.2, 0.45, 0.3, 1)
    end
    love.graphics.rectangle("fill", nextX, nextY, nextW, nextH, 8)
    
    love.graphics.setColor(1, 1, 1, 1)
    local nextFont = love.graphics.newFont(20)
    love.graphics.setFont(nextFont)
    love.graphics.printf("NEXT ROUND", nextX, nextY + 15, nextW, "center")
end

function M.mousemoved(x, y)
    local w, h = love.graphics.getDimensions()
    
    hoveredItem = nil
    hoveredButton = nil
    
    -- Check shop items
    for _, item in ipairs(shopItems) do
        if not item.sold then
            local hw, hh = CARD_WIDTH/2, CARD_HEIGHT/2
            if x >= item.x - hw and x <= item.x + hw and
               y >= item.y - hh and y <= item.y + hh then
                hoveredItem = item
                break
            end
        end
    end
    
    -- Check booster packs
    if not hoveredItem then
        for _, pack in ipairs(boosterPacks) do
            local hw, hh = 40, 50
            if x >= pack.x - hw and x <= pack.x + hw and
               y >= pack.y - hh and y <= pack.y + hh then
                hoveredItem = pack
                break
            end
        end
    end
    
    -- Check voucher
    if not hoveredItem and voucherSlot and not voucherSlot.sold then
        local hw, hh = 45, 35
        if x >= voucherSlot.x - hw and x <= voucherSlot.x + hw and
           y >= voucherSlot.y - hh and y <= voucherSlot.y + hh then
            hoveredItem = voucherSlot
        end
    end
    
    -- Check buttons
    local rerollX, rerollY = w/2 - 60, h * 0.38
    if x >= rerollX and x <= rerollX + 120 and y >= rerollY and y <= rerollY + 40 then
        hoveredButton = "reroll"
    end
    
    local nextX, nextY = w/2 - 80, h * 0.92
    if x >= nextX and x <= nextX + 160 and y >= nextY and y <= nextY + 50 then
        hoveredButton = "next"
    end
    
    -- Check card areas
    jokerArea:onMouseMoved(x, y)
    consumableArea:onMouseMoved(x, y)
    
    -- Check use/sell button hovers
    useButtonHovered = false
    sellButtonHovered = false
    
    if selectedCard then
        local cardX, cardY = selectedCard.x, selectedCard.y
        local cardW, cardH = selectedCard.area.cardWidth, selectedCard.area.cardHeight
        
        -- Use button
        local ConsumableEffects = require("micatro.core.consumable_effects")
        local selectedCards = {}
        local canUse = false
        if selectedCard.type == Card.TYPE.TAROT or selectedCard.type == Card.TYPE.PLANET or selectedCard.type == Card.TYPE.SPECTRAL then
            canUse = ConsumableEffects.canUse(selectedCard, gameState, selectedCards)
        end
        
        if canUse then
            local useBtnX = cardX - cardW/2 - 50
            local useBtnY = cardY
            local useBtnW, useBtnH = 45, 30
            if x >= useBtnX and x <= useBtnX + useBtnW and
               y >= useBtnY - useBtnH/2 and y <= useBtnY + useBtnH/2 then
                useButtonHovered = true
            end
        end
        
        -- Sell button
        local sellBtnX = cardX + cardW/2 + 5
        local sellBtnY = cardY
        local sellBtnW, sellBtnH = 45, 30
        if x >= sellBtnX and x <= sellBtnX + sellBtnW and
           y >= sellBtnY - sellBtnH/2 and y <= sellBtnY + sellBtnH/2 then
            sellButtonHovered = true
        end
    end
end

function M.mousepressed(x, y, button)
    if button == 1 then
        -- Buy item
        if hoveredItem and gameState.money >= hoveredItem.cost then
            M.buyItem(hoveredItem)
        end
        
        -- Reroll
        if hoveredButton == "reroll" and gameState.money >= rerollCost then
            GameState.spendMoney(gameState, rerollCost)
            rerollCost = rerollCost + 1
            M.generateShop()
        end
        
        -- Next round
        if hoveredButton == "next" then
            M.exit()
            if switchScene then
                switchScene("micatro_play")
            end
        end
        
        -- Select cards (don't sell directly)
        local jokerCard = jokerArea:getCardAt(x, y)
        if jokerCard then
            if selectedCard == jokerCard then
                selectedCard = nil  -- Deselect if clicking same card
            else
                selectedCard = jokerCard
            end
            return
        end
        
        local consCard = consumableArea:getCardAt(x, y)
        if consCard then
            if selectedCard == consCard then
                selectedCard = nil  -- Deselect if clicking same card
            else
                selectedCard = consCard
            end
            return
        end
        
        -- Check if clicking use/sell buttons
        if selectedCard then
            local cardX, cardY = selectedCard.x, selectedCard.y
            local cardW, cardH = selectedCard.area.cardWidth, selectedCard.area.cardHeight
            
            -- Use button (left side)
            local useBtnX = cardX - cardW/2 - 50
            local useBtnY = cardY
            local useBtnW, useBtnH = 45, 30
            if x >= useBtnX and x <= useBtnX + useBtnW and
               y >= useBtnY - useBtnH/2 and y <= useBtnY + useBtnH/2 then
                M.useCard(selectedCard)
                selectedCard = nil
                return
            end
            
            -- Sell button (right side)
            local sellBtnX = cardX + cardW/2 + 5
            local sellBtnY = cardY
            local sellBtnW, sellBtnH = 45, 30
            if x >= sellBtnX and x <= sellBtnX + sellBtnW and
               y >= sellBtnY - sellBtnH/2 and y <= sellBtnY + sellBtnH/2 then
                M.sellCard(selectedCard, selectedCard.area)
                selectedCard = nil
                return
            end
        end
        
        -- Clicking elsewhere deselects
        selectedCard = nil
    end
end

function M.buyItem(item)
    if item.type == "joker" then
        if jokerArea:hasRoom() then
            GameState.spendMoney(gameState, item.cost)
            local card = Card.newJoker(item.data)
            jokerArea:addCard(card)
            item.sold = true
        end
    elseif item.type == "consumable" then
        if consumableArea:hasRoom() then
            GameState.spendMoney(gameState, item.cost)
            local card = Card.newConsumable(item.data)
            consumableArea:addCard(card)
            item.sold = true
        end
    elseif item.type == "voucher" then
        GameState.spendMoney(gameState, item.cost)
        gameState.vouchers[item.data.key] = true
        item.sold = true
    elseif item.type == "pack" then
        -- Open pack scene
        GameState.spendMoney(gameState, item.cost)
        _G.MICATRO_PACK = item
        if switchScene then
            switchScene("micatro_pack")
        end
    end
end

function M.sellCard(card, area)
    local sellValue = card.sell_value or 1
    GameState.addMoney(gameState, sellValue)
    area:removeCard(card)
    selectedCard = nil
end

function M.useCard(card)
    -- Only consumables can be used in shop
    if card.type ~= Card.TYPE.TAROT and card.type ~= Card.TYPE.PLANET and card.type ~= Card.TYPE.SPECTRAL then
        return
    end
    
    local ConsumableEffects = require("micatro.core.consumable_effects")
    
    -- Get selected cards from hand (if we're in play scene, but for shop we'll use empty for now)
    -- In shop, consumables typically don't need selected cards, but some tarots do
    local selectedCards = {}
    
    -- Check if can use
    if not ConsumableEffects.canUse(card, gameState, selectedCards) then
        print("Cannot use this consumable")
        return
    end
    
    -- Use the consumable
    local success, message, effects = ConsumableEffects.use(card, gameState, selectedCards, nil)
    
    if success then
        -- Process effects
        if effects then
            -- Create joker (Judgement, The Soul, etc.)
            if effects.create_joker then
                GameState.addJoker(gameState, effects.create_joker)
                -- Add to joker area if there's room
                if jokerArea:hasRoom() then
                    local newJoker = Card.newJoker(effects.create_joker)
                    jokerArea:addCard(newJoker)
                end
                print("Created joker: " .. (effects.create_joker.name or "unknown"))
            end
            
            -- Create consumables (High Priestess, Emperor, etc.)
            if effects.created then
                for _, consumableData in ipairs(effects.created) do
                    GameState.addConsumable(gameState, consumableData)
                    -- Add to consumable area if there's room
                    if consumableArea:hasRoom() then
                        local newCard = Card.newConsumable(consumableData)
                        consumableArea:addCard(newCard)
                    end
                end
            end
        end
        
        -- Remove from area
        card.area:removeCard(card)
        -- Remove from game state
        for i, cons in ipairs(gameState.consumables) do
            if cons.data.key == card.data.key then
                table.remove(gameState.consumables, i)
                break
            end
        end
        print("Used: " .. (message or "consumable"))
        selectedCard = nil
    else
        print("Failed to use: " .. (message or "unknown error"))
    end
end

function M.keypressed(key)
    if key == "escape" then
        M.exit()
        if switchScene then
            switchScene("micatro_play")
        end
    elseif key == "space" or key == "return" then
        M.exit()
        if switchScene then
            switchScene("micatro_play")
        end
    end
end

function M.setGameState(state)
    gameState = state
end

return M

