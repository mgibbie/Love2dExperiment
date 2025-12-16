-- Pack Opening Scene
-- Open booster packs and choose cards

local Card = require("micatro.core.card")
local CardArea = require("micatro.core.card_area")
local Tarots = require("micatro.data.tarots")
local Planets = require("micatro.data.planets")
local Spectrals = require("micatro.data.spectrals")
local Jokers = require("micatro.data.jokers")
local CardRender = require("micatro.ui.card_render")
local Sprites = require("micatro.core.sprites")
local GameState = require("micatro.core.game_state")
local ConsumableEffects = require("micatro.core.consumable_effects")

local M = {}

-- Pack data
local packData = nil
local packCards = {}
local selectedCards = {}
local chooseCount = 1
local maxChoose = 1

-- Game state and hand
local gameState = nil
local handArea = nil

-- UI
local hoveredCard = nil
local canConfirm = false
local elapsedTime = 0
local bgShader = nil
local revealProgress = 0
local isRevealing = true
local useButtonHovered = false
local selectedPackCard = nil  -- Card selected for use/take
local debugMessage = nil  -- Debug message for pack type

-- Constants
local CARD_WIDTH = 85
local CARD_HEIGHT = 120

function M.load()
    local code = love.filesystem.read("shaders/balatro_bg.glsl")
    if code then
        local success, shader = pcall(love.graphics.newShader, code)
        if success then
            bgShader = shader
        end
    end
    
    -- Load sprites and shaders for card rendering
    Sprites.load()
    CardRender.loadSprites()
    CardRender.loadShaders()
end

function M.enter()
    elapsedTime = 0
    revealProgress = 0
    isRevealing = true
    selectedCards = {}
    selectedPackCard = nil
    
    -- Get game state
    if _G.MICATRO_GAME_STATE then
        gameState = _G.MICATRO_GAME_STATE
    else
        gameState = GameState.new("b_red")
    end
    
    -- Set up hand area (for selecting cards to use with tarots)
    local w, h = love.graphics.getDimensions()
    handArea = CardArea.new(CardArea.TYPE.HAND, {
        x = w * 0.1,
        y = h * 0.25,
        width = w * 0.8,
        height = 120,
        cardWidth = 71,
        cardHeight = 95,
        maxCards = gameState.hand_size,
        maxSelected = 5,
        allowDrag = true  -- Allow dragging to rearrange cards
    })
    
    -- Populate hand from game state
    for _, cardData in ipairs(gameState.hand) do
        local card = Card.newPlaying(cardData.rank, cardData.suit, cardData.id)
        card.enhancement = cardData.enhancement
        card.edition = cardData.edition
        card.seal = cardData.seal
        card.bonus_chips = cardData.bonus_chips or 0
        handArea:addCard(card)
    end
    
    -- Get pack data
    packData = _G.MICATRO_PACK
    if not packData then
        packData = {
            name = "Arcana Pack",
            packType = "arcana",
            cards = 3,
            choose = 1
        }
    end
    
    -- Debug: ensure packType is set correctly
    if not packData.packType then
        -- Try to infer from pack name
        local name = string.lower(packData.name or "")
        if string.find(name, "celestial") then
            packData.packType = "celestial"
        elseif string.find(name, "spectral") then
            packData.packType = "spectral"
        elseif string.find(name, "buffoon") then
            packData.packType = "buffoon"
        else
            packData.packType = "arcana"  -- Default fallback
        end
    end
    
    -- Debug message to show pack type
    debugMessage = "Pack Type: " .. tostring(packData.packType) .. " (" .. tostring(packData.name) .. ")"
    
    maxChoose = packData.choose or 1
    chooseCount = 0
    
    -- Generate pack cards
    M.generateCards()
end

function M.generateCards()
    packCards = {}
    
    local numCards = packData.cards or 3
    
    for i = 1, numCards do
        local cardData
        
        -- Normalize packType for comparison (case-insensitive)
        local packTypeLower = string.lower(tostring(packData.packType or ""))
        
        if packTypeLower == "arcana" then
            -- Arcana pack: tarot cards
            cardData = Tarots.getRandom()
        elseif packTypeLower == "celestial" then
            -- Celestial pack: planet cards
            cardData = Planets.getRandom()
            -- Ensure we got a valid planet card
            if not cardData then
                -- Fallback: get first planet if random failed (shouldn't happen)
                cardData = Planets.get(Planets.PLANET_KEYS[1])
            end
        elseif packTypeLower == "spectral" then
            -- Spectral pack: spectral cards
            cardData = Spectrals.getRandom()
        elseif packTypeLower == "buffoon" then
            -- Buffoon pack: joker cards
            cardData = Jokers.getRandom()
        else
            -- Standard pack: playing cards with enhancements
            local suits = {"Hearts", "Diamonds", "Clubs", "Spades"}
            local ranks = {"A", "K", "Q", "J", "10", "9", "8", "7", "6", "5", "4", "3", "2"}
            cardData = {
                type = "playing",
                suit = suits[math.random(#suits)],
                rank = ranks[math.random(#ranks)],
                name = "Playing Card"
            }
        end
        
        table.insert(packCards, {
            data = cardData,
            x = 0,
            y = 0,
            rotation = 0,
            scale = 1,
            revealed = false,
            selected = false,
            revealDelay = (i - 1) * 0.15
        })
    end
    
    M.updateCardPositions()
end

function M.updateCardPositions()
    local w, h = love.graphics.getDimensions()
    local numCards = #packCards
    local spacing = CARD_WIDTH + 30
    local totalWidth = (numCards - 1) * spacing + CARD_WIDTH
    local startX = (w - totalWidth) / 2 + CARD_WIDTH / 2
    -- Position pack cards below hand area
    local cardY = h * 0.5
    
    for i, card in ipairs(packCards) do
        card.x = startX + (i - 1) * spacing
        card.y = cardY
    end
end

function M.exit()
    _G.MICATRO_PACK = nil
    -- Store game state when exiting
    if gameState then
        _G.MICATRO_GAME_STATE = gameState
    end
end

function M.update(dt)
    elapsedTime = elapsedTime + dt
    
    if bgShader then
        bgShader:send("iTime", elapsedTime)
        local w, h = love.graphics.getDimensions()
        bgShader:send("iResolution", {w, h})
    end
    
    -- Update hand area
    if handArea then
        handArea:update(dt)
    end
    
    -- Reveal animation
    if isRevealing then
        revealProgress = revealProgress + dt * 2
        
        local allRevealed = true
        for _, card in ipairs(packCards) do
            if revealProgress > card.revealDelay then
                card.revealed = true
            else
                allRevealed = false
            end
        end
        
        if allRevealed then
            isRevealing = false
        end
    end
    
    -- Update selection state
    chooseCount = 0
    for _, card in ipairs(packCards) do
        if card.selected then
            chooseCount = chooseCount + 1
        end
    end
    canConfirm = chooseCount >= maxChoose
end

function M.draw()
    local w, h = love.graphics.getDimensions()
    
    -- Background with vignette
    if bgShader then
        love.graphics.setShader(bgShader)
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.rectangle("fill", 0, 0, w, h)
        love.graphics.setShader()
    end
    
    -- Dark overlay
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    -- Pack name
    love.graphics.setColor(1, 1, 1, 1)
    local titleFont = love.graphics.newFont(32)
    love.graphics.setFont(titleFont)
    love.graphics.printf(packData.name, 0, 50, w, "center")
    
    -- Debug message (show pack type)
    if debugMessage then
        love.graphics.setColor(1, 1, 0, 1)
        local debugFont = love.graphics.newFont(14)
        love.graphics.setFont(debugFont)
        love.graphics.printf(debugMessage, 0, 85, w, "center")
    end
    
    -- Instructions
    love.graphics.setColor(0.8, 0.8, 0.9, 0.8)
    local instFont = love.graphics.newFont(18)
    love.graphics.setFont(instFont)
    love.graphics.printf("Choose " .. maxChoose .. " card" .. (maxChoose > 1 and "s" or ""), 0, 105, w, "center")
    
    -- Draw hand area (for selecting cards to use with tarots)
    if handArea and #handArea:getCards() > 0 then
        love.graphics.setColor(0.6, 0.6, 0.7, 0.7)
        local labelFont = love.graphics.newFont(14)
        love.graphics.setFont(labelFont)
        love.graphics.print("Select cards to use with tarot:", handArea.x, handArea.y - 20)
        
        -- Draw hand cards (non-dragged first)
        for _, card in ipairs(handArea:getCards()) do
            if card ~= handArea.draggedCard then
                local scale = card.hovered and 1.08 or (card.selected and 1.1 or 1)
                CardRender.drawPlayingCard(card, card.x, card.y, 
                    handArea.cardWidth * scale, handArea.cardHeight * scale, elapsedTime)
            end
        end
        
        -- Draw dragged card on top
        if handArea.draggedCard then
            local card = handArea.draggedCard
            CardRender.drawPlayingCard(card, card.x, card.y, 
                handArea.cardWidth, handArea.cardHeight, elapsedTime)
        end
    end
    
    -- Draw pack cards
    for i, card in ipairs(packCards) do
        M.drawPackCard(card, i)
    end
    
    -- Selection indicator
    love.graphics.setColor(1, 1, 1, 0.7)
    local selFont = love.graphics.newFont(16)
    love.graphics.setFont(selFont)
    love.graphics.printf("Selected: " .. chooseCount .. "/" .. maxChoose, 0, h * 0.7, w, "center")
    
    -- Confirm button
    if canConfirm then
        M.drawConfirmButton()
    end
    
    -- Skip button
    M.drawSkipButton()
end

function M.drawPackCard(card, index)
    local isHovered = hoveredCard == index
    local scale = card.scale * (isHovered and 1.08 or 1)
    local yOffset = card.selected and -20 or 0
    
    -- Reveal animation
    if not card.revealed then
        -- Card back
        love.graphics.push()
        love.graphics.translate(card.x, card.y)
        love.graphics.scale(scale, scale)
        
        love.graphics.setColor(0, 0, 0, 0.4)
        love.graphics.rectangle("fill", -CARD_WIDTH/2 + 4, -CARD_HEIGHT/2 + 4, CARD_WIDTH, CARD_HEIGHT, 8)
        
        love.graphics.setColor(0.3, 0.25, 0.4, 1)
        love.graphics.rectangle("fill", -CARD_WIDTH/2, -CARD_HEIGHT/2, CARD_WIDTH, CARD_HEIGHT, 8)
        
        love.graphics.setColor(0.5, 0.4, 0.6, 1)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", -CARD_WIDTH/2, -CARD_HEIGHT/2, CARD_WIDTH, CARD_HEIGHT, 8)
        
        -- Pattern on back
        love.graphics.setColor(0.4, 0.35, 0.5, 0.5)
        for j = 1, 5 do
            love.graphics.circle("fill", 
                math.sin(j * 1.3) * 20, 
                math.cos(j * 1.7) * 30, 
                8)
        end
        
        love.graphics.pop()
        return
    end
    
    -- Create a card object for rendering
    local cardObj
    if card.data.set == "Joker" then
        cardObj = Card.newJoker(card.data)
    elseif card.data.set == "Tarot" or card.data.set == "Planet" or card.data.set == "Spectral" then
        cardObj = Card.newConsumable(card.data)
    else
        -- Fallback for playing cards
        cardObj = {
            type = Card.TYPE.PLAYING,
            rank = card.data.rank,
            suit = card.data.suit,
            data = card.data
        }
    end
    
    -- Set card visual state
    cardObj.x = card.x
    cardObj.y = card.y + yOffset
    cardObj.rotation = card.rotation
    cardObj.scale = scale
    cardObj.selected = card.selected
    cardObj.alpha = 1
    
    -- Draw selection highlight (for TAKE)
    if card.selected then
        love.graphics.setColor(1, 0.85, 0.4, 0.3)
        love.graphics.rectangle("fill", 
            card.x - CARD_WIDTH/2 - 2, 
            card.y + yOffset - CARD_HEIGHT/2 - 2,
            CARD_WIDTH + 4, CARD_HEIGHT + 4, 8)
    end
    
    -- Draw focus highlight (for USE)
    if selectedPackCard == card then
        love.graphics.setColor(0.4, 0.7, 1, 0.3)
        love.graphics.rectangle("fill", 
            card.x - CARD_WIDTH/2 - 4, 
            card.y + yOffset - CARD_HEIGHT/2 - 4,
            CARD_WIDTH + 8, CARD_HEIGHT + 8, 8)
    end
    
    -- Use CardRender to draw the card properly
    if cardObj.type == Card.TYPE.JOKER then
        CardRender.drawJokerCard(cardObj, card.x, card.y + yOffset, 
            CARD_WIDTH * scale, CARD_HEIGHT * scale, elapsedTime)
    elseif cardObj.type == Card.TYPE.TAROT or cardObj.type == Card.TYPE.PLANET or cardObj.type == Card.TYPE.SPECTRAL then
        CardRender.drawConsumableCard(cardObj, card.x, card.y + yOffset, 
            CARD_WIDTH * scale, CARD_HEIGHT * scale, elapsedTime)
        
        -- Draw USE button for consumables when focused (not just selected for TAKE)
        if selectedPackCard == card then
            local selectedHandCards = handArea and handArea:getSelected() or {}
            local canUse = ConsumableEffects.canUse(cardObj, gameState, selectedHandCards)
            
            if canUse then
                local useBtnX = card.x - CARD_WIDTH/2 - 50
                local useBtnY = card.y + yOffset
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
                love.graphics.printf("USE", useBtnX, useBtnY - 8, useBtnW, "center")
            end
        end
    elseif cardObj.type == Card.TYPE.PLAYING then
        CardRender.drawPlayingCard(cardObj, card.x, card.y + yOffset, 
            CARD_WIDTH * scale, CARD_HEIGHT * scale, elapsedTime)
    else
        -- Fallback rendering
        love.graphics.push()
        love.graphics.translate(card.x, card.y + yOffset)
        love.graphics.scale(scale, scale)
        
        love.graphics.setColor(0.98, 0.98, 1, 1)
        love.graphics.rectangle("fill", -CARD_WIDTH/2, -CARD_HEIGHT/2, CARD_WIDTH, CARD_HEIGHT, 8)
        
        love.graphics.setColor(0.3, 0.3, 0.4, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", -CARD_WIDTH/2, -CARD_HEIGHT/2, CARD_WIDTH, CARD_HEIGHT, 8)
        
        love.graphics.setColor(0.15, 0.15, 0.2, 1)
        local nameFont = love.graphics.newFont(13)
        love.graphics.setFont(nameFont)
        love.graphics.printf(card.data.name or "Card", -CARD_WIDTH/2 + 4, -CARD_HEIGHT/2 + 12, CARD_WIDTH - 8, "center")
        
        love.graphics.pop()
    end
end

function M.drawConfirmButton()
    local w, h = love.graphics.getDimensions()
    local btnW, btnH = 160, 50
    local btnX = (w - btnW) / 2
    local btnY = h * 0.82
    
    local isHovered = hoveredCard == "confirm"
    
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", btnX + 4, btnY + 4, btnW, btnH, 10)
    
    if isHovered then
        love.graphics.setColor(0.3, 0.65, 0.4, 1)
    else
        love.graphics.setColor(0.2, 0.5, 0.3, 1)
    end
    love.graphics.rectangle("fill", btnX, btnY, btnW, btnH, 10)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", btnX, btnY, btnW, btnH, 10)
    
    local btnFont = love.graphics.newFont(20)
    love.graphics.setFont(btnFont)
    love.graphics.printf("TAKE", btnX, btnY + 15, btnW, "center")
end

function M.drawSkipButton()
    local w, h = love.graphics.getDimensions()
    local btnW, btnH = 100, 35
    local btnX = w - btnW - 20
    local btnY = h - btnH - 20
    
    local isHovered = hoveredCard == "skip"
    
    if isHovered then
        love.graphics.setColor(0.5, 0.4, 0.35, 1)
    else
        love.graphics.setColor(0.35, 0.3, 0.25, 1)
    end
    love.graphics.rectangle("fill", btnX, btnY, btnW, btnH, 8)
    
    love.graphics.setColor(1, 1, 1, 0.8)
    local skipFont = love.graphics.newFont(14)
    love.graphics.setFont(skipFont)
    love.graphics.printf("Skip", btnX, btnY + 10, btnW, "center")
end

function M.mousemoved(x, y)
    local w, h = love.graphics.getDimensions()
    
    -- Update hand area
    if handArea then
        handArea:onMouseMoved(x, y)
    end
    
    hoveredCard = nil
    useButtonHovered = false
    
    -- Check pack cards
    for i, card in ipairs(packCards) do
        if card.revealed then
            local yOffset = card.selected and -20 or 0
            if x >= card.x - CARD_WIDTH/2 and x <= card.x + CARD_WIDTH/2 and
               y >= card.y + yOffset - CARD_HEIGHT/2 and y <= card.y + yOffset + CARD_HEIGHT/2 then
                hoveredCard = i
                break
            end
        end
    end
    
    -- Check USE button if a consumable is selected
    if selectedPackCard and selectedPackCard.data.set ~= "Joker" then
        local card = selectedPackCard
        local yOffset = card.selected and -20 or 0
        local selectedHandCards = handArea and handArea:getSelected() or {}
        local cardObj = Card.newConsumable(card.data)
        local canUse = ConsumableEffects.canUse(cardObj, gameState, selectedHandCards)
        
        if canUse then
            local useBtnX = card.x - CARD_WIDTH/2 - 50
            local useBtnY = card.y + yOffset
            local useBtnW, useBtnH = 45, 30
            if x >= useBtnX and x <= useBtnX + useBtnW and
               y >= useBtnY - useBtnH/2 and y <= useBtnY + useBtnH/2 then
                useButtonHovered = true
            end
        end
    end
    
    -- Check confirm button
    if canConfirm then
        local btnW, btnH = 160, 50
        local btnX = (w - btnW) / 2
        local btnY = h * 0.82
        if x >= btnX and x <= btnX + btnW and y >= btnY and y <= btnY + btnH then
            hoveredCard = "confirm"
        end
    end
    
    -- Check skip button
    local skipW, skipH = 100, 35
    local skipX = w - skipW - 20
    local skipY = h - skipH - 20
    if x >= skipX and x <= skipX + skipW and y >= skipY and y <= skipY + skipH then
        hoveredCard = "skip"
    end
end

function M.mousepressed(x, y, button)
    if button == 1 then
        -- Check if clicking on hand area first (hand has priority)
        if handArea then
            local handCard = handArea:getCardAt(x, y)
            if handCard then
                handArea:onMousePressed(x, y, button)
                return  -- Hand interaction takes priority
            end
        end
        
        -- Check USE button
        if selectedPackCard and useButtonHovered then
            M.usePackCard(selectedPackCard)
            return
        end
        
        if type(hoveredCard) == "number" then
            local card = packCards[hoveredCard]
            if card.revealed then
                -- Select pack card (for USE or TAKE)
                if selectedPackCard == card then
                    selectedPackCard = nil  -- Deselect
                else
                    selectedPackCard = card
                    -- Also toggle selection for TAKE button
                    if card.selected then
                        card.selected = false
                    elseif chooseCount < maxChoose then
                        card.selected = true
                    end
                end
            end
        elseif hoveredCard == "confirm" and canConfirm then
            M.confirmSelection()
        elseif hoveredCard == "skip" then
            M.skip()
        else
            -- Clicking elsewhere deselects pack card
            selectedPackCard = nil
        end
    end
end

function M.mousereleased(x, y, button)
    if button == 1 then
        -- Handle hand area release first
        if handArea then
            local handled = handArea:onMouseReleased(x, y, button)
            if handled then
                return  -- Hand interaction handled, don't process pack cards
            end
        end
    end
end

function M.keypressed(key)
    if key == "escape" then
        M.skip()
    elseif key == "space" or key == "return" then
        if canConfirm then
            M.confirmSelection()
        end
    end
end

function M.usePackCard(card)
    -- Use the consumable immediately
    if not card or not card.data then return end
    
    local cardObj = Card.newConsumable(card.data)
    local selectedHandCards = handArea and handArea:getSelected() or {}
    
    -- Check if can use
    if not ConsumableEffects.canUse(cardObj, gameState, selectedHandCards) then
        print("Cannot use this consumable")
        return
    end
    
    -- Convert hand cards to data format
    local selectedCardsData = {}
    for _, handCard in ipairs(selectedHandCards) do
        table.insert(selectedCardsData, {
            rank = handCard.rank,
            suit = handCard.suit,
            enhancement = handCard.enhancement,
            edition = handCard.edition,
            seal = handCard.seal,
            bonus_chips = handCard.bonus_chips
        })
    end
    
    -- Use the consumable
    local success, message, effects = ConsumableEffects.use(cardObj, gameState, selectedCardsData, handArea)
    
    if success then
        print("Used: " .. (message or "consumable"))
        
        -- Process effects
        if effects then
            -- Create joker (Judgement, The Soul, etc.)
            if effects.create_joker then
                GameState.addJoker(gameState, effects.create_joker)
                print("Created joker: " .. (effects.create_joker.name or "unknown"))
            end
            
            -- Create consumables (High Priestess, Emperor, etc.)
            if effects.created then
                for _, consumableData in ipairs(effects.created) do
                    GameState.addConsumable(gameState, consumableData)
                end
            end
            
            -- Update hand cards if they were modified
            if effects.enhanced or effects.converted or effects.rank_up or effects.destroyed then
                -- Sync hand cards back to game state
                if handArea then
                    for i, cardData in ipairs(gameState.hand) do
                        for _, handCard in ipairs(handArea:getCards()) do
                            if handCard.id == cardData.id then
                                -- Update game state card with modifications
                                gameState.hand[i].enhancement = handCard.enhancement
                                gameState.hand[i].edition = handCard.edition
                                gameState.hand[i].seal = handCard.seal
                                gameState.hand[i].rank = handCard.rank
                                gameState.hand[i].suit = handCard.suit
                                break
                            end
                        end
                    end
                end
            end
        end
        
        -- Store game state
        _G.MICATRO_GAME_STATE = gameState
        
        -- Clear pack result (no cards taken)
        _G.MICATRO_PACK_RESULT = {}
        
        -- Exit pack scene and return to shop
        M.exit()
        if switchScene then
            switchScene("micatro_shop")
        end
    else
        print("Failed to use: " .. (message or "unknown error"))
    end
end

function M.confirmSelection()
    -- Add selected cards to game state
    selectedCards = {}
    for _, card in ipairs(packCards) do
        if card.selected then
            table.insert(selectedCards, card.data)
        end
    end
    
    -- Store for pickup by shop/play scene
    _G.MICATRO_PACK_RESULT = selectedCards
    
    -- Debug: print what we're storing
    if #selectedCards > 0 then
        print("Pack result stored: " .. #selectedCards .. " card(s)")
        for i, cardData in ipairs(selectedCards) do
            print("  Card " .. i .. ": " .. (cardData.name or "unknown") .. " (set: " .. tostring(cardData.set) .. ")")
        end
    end
    
    -- Store game state
    _G.MICATRO_GAME_STATE = gameState
    
    M.exit()
    if switchScene then
        switchScene("micatro_shop")
    end
end

function M.skip()
    _G.MICATRO_PACK_RESULT = {}
    M.exit()
    if switchScene then
        switchScene("micatro_shop")
    end
end

return M

