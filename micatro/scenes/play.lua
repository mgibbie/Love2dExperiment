-- Play Scene
-- Main gameplay screen with hand, jokers, and scoring

local GameState = require("micatro.core.game_state")
local Card = require("micatro.core.card")
local CardArea = require("micatro.core.card_area")
local Scoring = require("micatro.core.scoring")
local Events = require("micatro.core.events")
local Blinds = require("micatro.data.blinds")
local Hands = require("micatro.data.hands")
local Sprites = require("micatro.core.sprites")
local CardRender = require("micatro.ui.card_render")
local Enhancements = require("micatro.data.enhancements")
local Tooltip = require("micatro.ui.tooltip")

local M = {}

-- Game state
local gameState = nil
local eventManager = nil

-- Card areas
local handArea = nil
local playArea = nil
local jokerArea = nil
local consumableArea = nil

-- UI state
local hoveredButton = nil
local isScoring = false
local scoreDisplay = {chips = 0, mult = 0, score = 0}
local lastHandResult = nil
local selectedConsumable = nil  -- Currently selected consumable for use
local useButtonHovered = false
local lastMessage = nil  -- For on-screen debug messages
local messageTimer = 0
local hoveredCard = nil  -- Card currently being hovered for tooltip
local hoveredCardTimer = 0  -- Time hovered (for delay)
local scoringSequence = nil  -- For sequential card scoring
local cardAnimations = {}  -- Track card animations (sliding left/right)

-- Animation
local elapsedTime = 0

-- Shaders
local bgShader = nil

-- Layout constants
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
    
    -- Get or create game state
    if not gameState then
        -- Check for global game state first
        if _G.MICATRO_GAME_STATE then
            gameState = _G.MICATRO_GAME_STATE
        else
            -- Get selected deck or default
            local deckKey = _G.MICATRO_DECK or "b_red"
            gameState = GameState.new(deckKey)
        end
    end
    
    eventManager = Events.new()
    
    -- Set up card areas
    local w, h = love.graphics.getDimensions()
    
    handArea = CardArea.new(CardArea.TYPE.HAND, {
        x = w * 0.1,
        y = h * 0.6,
        width = w * 0.8,
        height = 150,
        cardWidth = CARD_WIDTH,
        cardHeight = CARD_HEIGHT,
        maxCards = gameState.hand_size,
        maxSelected = 5,
        allowDrag = true  -- Enable dragging for hand
    })
    
    playArea = CardArea.new(CardArea.TYPE.PLAY, {
        x = w * 0.25,
        y = h * 0.35,
        width = w * 0.5,
        height = 120,
        cardWidth = CARD_WIDTH,
        cardHeight = CARD_HEIGHT,
        maxCards = 5
    })
    
    jokerArea = CardArea.new(CardArea.TYPE.JOKER, {
        x = w * 0.05,
        y = h * 0.08,
        width = w * 0.5,
        height = 100,
        cardWidth = CARD_WIDTH,
        cardHeight = CARD_HEIGHT,
        maxCards = gameState.joker_slots,
        spacing = 15,
        allowDrag = true  -- Enable dragging for jokers
    })
    
    consumableArea = CardArea.new(CardArea.TYPE.CONSUMABLE, {
        x = w * 0.6,
        y = h * 0.08,
        width = w * 0.35,
        height = 100,
        cardWidth = CARD_WIDTH * 0.9,
        cardHeight = CARD_HEIGHT * 0.9,
        maxCards = gameState.consumable_slots,
        spacing = 10
    })
    
    -- Populate jokers from game state
    for _, jokerData in ipairs(gameState.jokers) do
        local card = Card.newJoker(jokerData.data)
        card.ability = jokerData.ability
        card.edition = jokerData.edition
        card.sell_value = jokerData.sell_value
        jokerArea:addCard(card)
    end
    
    -- Populate consumables from game state
    for _, consData in ipairs(gameState.consumables) do
        local card = Card.newConsumable(consData.data)
        card.edition = consData.edition
        consumableArea:addCard(card)
    end
    
    -- Start first round
    M.startRound()
end

function M.startRound()
    -- Get blind info
    local blindMult = 1
    if gameState.round == 1 then
        gameState.current_blind = Blinds.BLINDS.bl_small
    elseif gameState.round == 2 then
        gameState.current_blind = Blinds.BLINDS.bl_big
    else
        gameState.current_blind = Blinds.getRandomBoss(gameState.ante)
        gameState.is_boss_blind = true
    end
    
    blindMult = gameState.current_blind.mult or 1
    gameState.blind_chips = Blinds.getBlindChips(gameState.ante, blindMult)
    
    -- Start the round
    GameState.startRound(gameState)
    
    -- Clear areas
    handArea:clear()
    playArea:clear()
    
    -- Create card objects for hand
    for _, cardData in ipairs(gameState.hand) do
        local card = Card.newPlaying(cardData.rank, cardData.suit, cardData.id)
        card.enhancement = cardData.enhancement
        card.edition = cardData.edition
        card.seal = cardData.seal
        card.bonus_chips = cardData.bonus_chips or 0
        handArea:addCard(card)
    end
    
    -- Reset score display
    scoreDisplay = {chips = 0, mult = 0, score = 0}
    lastHandResult = nil
    isScoring = false
end

function M.exit()
    -- Sync jokers and consumables back to game state
    if gameState then
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
        
        -- Store game state globally
        _G.MICATRO_GAME_STATE = gameState
    end
end

function M.update(dt)
    elapsedTime = elapsedTime + dt
    
    -- Update message timer
    if lastMessage then
        messageTimer = messageTimer + dt
        if messageTimer > 3 then
            lastMessage = nil
            messageTimer = 0
        end
    end
    
    -- Update tooltip timer
    if hoveredCard then
        hoveredCardTimer = hoveredCardTimer + dt
        if hoveredCardTimer > 0.3 then
            local mx, my = love.mouse.getPosition()
            M.showCardTooltip(hoveredCard, mx, my)
        end
    else
        hoveredCardTimer = 0
    end
    
    -- Update scoring sequence
    if scoringSequence then
        M.updateScoringSequence(dt)
    end
    
    -- Update card animations (sliding left/right)
    M.updateCardAnimations(dt)
    
    -- Update background shader (with error handling)
    if bgShader then
        local success1, err1 = pcall(bgShader.send, bgShader, "iTime", elapsedTime)
        if not success1 then
            print("WARNING: Failed to send iTime to shader: " .. tostring(err1))
        end
        
        local w, h = love.graphics.getDimensions()
        local success2, err2 = pcall(bgShader.send, bgShader, "iResolution", {w, h})
        if not success2 then
            print("WARNING: Failed to send iResolution to shader: " .. tostring(err2))
        end
    end
    
    -- Update event manager
    if eventManager then
        eventManager:update(dt)
    end
    
    -- Update card areas (with nil checks)
    if handArea then
        local success, err = pcall(handArea.update, handArea, dt)
        if not success then
            print("ERROR updating handArea: " .. tostring(err))
        end
    end
    if playArea then
        local success, err = pcall(playArea.update, playArea, dt)
        if not success then
            print("ERROR updating playArea: " .. tostring(err))
        end
    end
    if jokerArea then
        local success, err = pcall(jokerArea.update, jokerArea, dt)
        if not success then
            print("ERROR updating jokerArea: " .. tostring(err))
        end
    end
    if consumableArea then
        local success, err = pcall(consumableArea.update, consumableArea, dt)
        if not success then
            print("ERROR updating consumableArea: " .. tostring(err))
        end
    end
end

function M.draw()
    local w, h = love.graphics.getDimensions()
    
    -- Draw background
    if bgShader then
        love.graphics.setShader(bgShader)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", 0, 0, w, h)
        love.graphics.setShader()
    else
        love.graphics.setColor(0.15, 0.1, 0.2, 1)
        love.graphics.rectangle("fill", 0, 0, w, h)
    end
    
    -- Draw UI panels
    M.drawInfoPanel()
    M.drawBlindPanel()
    M.drawScorePanel()
    
    -- Draw card areas (non-dragged cards first)
    M.drawCardArea(jokerArea, "Jokers")
    M.drawCardArea(consumableArea, "Consumables")
    M.drawCardArea(playArea, nil)
    M.drawCardArea(handArea, nil)
    
    -- Draw debug message (at top center, above everything)
    if lastMessage then
        love.graphics.setColor(0, 0, 0, 0.7)
        local msgFont = love.graphics.newFont(20)
        love.graphics.setFont(msgFont)
        local msgW = msgFont:getWidth(lastMessage) + 20
        local msgH = 40
        love.graphics.rectangle("fill", w/2 - msgW/2, 20, msgW, msgH, 8)
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.printf(lastMessage, 0, 30, w, "center")
    end
    
    -- Draw tooltip (on top of everything)
    Tooltip.drawGlobal()
    
    -- Draw drop indicators
    handArea:drawDropIndicator()
    jokerArea:drawDropIndicator()
    
    -- Draw dragged cards on top
    M.drawDraggedCards()
    
    -- Draw animating cards (sliding left/right) on top of everything
    for _, anim in ipairs(cardAnimations) do
        if anim.card then
            CardRender.draw(anim.card, anim.card.x, anim.card.y, 
                handArea.cardWidth, handArea.cardHeight, elapsedTime)
        end
    end
    
    -- Draw buttons
    M.drawButtons()
    
    -- Draw hand result
    if lastHandResult then
        M.drawHandResult()
    end
end

function M.drawDraggedCards()
    -- Draw dragged card on top of everything
    if handArea.draggedCard then
        CardRender.draw(handArea.draggedCard, handArea.draggedCard.x, handArea.draggedCard.y,
            handArea.cardWidth, handArea.cardHeight, elapsedTime)
    end
    if jokerArea.draggedCard then
        CardRender.draw(jokerArea.draggedCard, jokerArea.draggedCard.x, jokerArea.draggedCard.y,
            jokerArea.cardWidth, jokerArea.cardHeight, elapsedTime)
    end
end

function M.drawInfoPanel()
    local w, h = love.graphics.getDimensions()
    
    -- Money display
    love.graphics.setColor(0.1, 0.1, 0.15, 0.8)
    love.graphics.rectangle("fill", w - 150, h * 0.08, 130, 40, 8)
    
    love.graphics.setColor(1, 0.85, 0.4, 1)
    local moneyFont = love.graphics.newFont(24)
    love.graphics.setFont(moneyFont)
    love.graphics.printf("$" .. gameState.money, w - 145, h * 0.08 + 8, 120, "center")
    
    -- Ante/Round display
    love.graphics.setColor(0.1, 0.1, 0.15, 0.8)
    love.graphics.rectangle("fill", w - 150, h * 0.08 + 50, 130, 30, 8)
    
    love.graphics.setColor(0.8, 0.8, 0.9, 1)
    local smallFont = love.graphics.newFont(16)
    love.graphics.setFont(smallFont)
    love.graphics.printf("Ante " .. gameState.ante .. " • Round " .. gameState.round, 
        w - 145, h * 0.08 + 55, 120, "center")
end

function M.drawBlindPanel()
    local w, h = love.graphics.getDimensions()
    
    -- Blind info panel
    love.graphics.setColor(0.1, 0.1, 0.15, 0.8)
    love.graphics.rectangle("fill", 10, h * 0.25, 150, 80, 8)
    
    local blind = gameState.current_blind
    if blind then
        -- Blind name
        love.graphics.setColor(1, 1, 1, 1)
        local nameFont = love.graphics.newFont(16)
        love.graphics.setFont(nameFont)
        love.graphics.printf(blind.name, 15, h * 0.25 + 10, 140, "center")
        
        -- Target chips
        love.graphics.setColor(0.4, 0.7, 1, 1)
        local targetFont = love.graphics.newFont(20)
        love.graphics.setFont(targetFont)
        love.graphics.printf(M.formatNumber(gameState.blind_chips), 15, h * 0.25 + 35, 140, "center")
        
        -- Progress
        local progress = math.min(gameState.chips / gameState.blind_chips, 1)
        love.graphics.setColor(0.3, 0.3, 0.4, 1)
        love.graphics.rectangle("fill", 20, h * 0.25 + 60, 130, 10, 5)
        love.graphics.setColor(0.3, 0.7, 0.4, 1)
        love.graphics.rectangle("fill", 20, h * 0.25 + 60, 130 * progress, 10, 5)
    end
end

function M.drawScorePanel()
    local w, h = love.graphics.getDimensions()
    
    -- Current score panel
    love.graphics.setColor(0.1, 0.1, 0.15, 0.8)
    love.graphics.rectangle("fill", w / 2 - 100, h * 0.22, 200, 60, 8)
    
    -- Chips x Mult display
    love.graphics.setColor(0.4, 0.7, 1, 1)
    local chipsFont = love.graphics.newFont(22)
    love.graphics.setFont(chipsFont)
    love.graphics.printf(M.formatNumber(math.floor(scoreDisplay.chips)), 
        w / 2 - 95, h * 0.22 + 8, 90, "right")
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("×", w / 2 - 5, h * 0.22 + 8, 20, "center")
    
    love.graphics.setColor(1, 0.4, 0.3, 1)
    love.graphics.printf(M.formatNumber(math.floor(scoreDisplay.mult)), 
        w / 2 + 15, h * 0.22 + 8, 90, "left")
    
    -- Total score
    love.graphics.setColor(1, 1, 1, 1)
    local scoreFont = love.graphics.newFont(18)
    love.graphics.setFont(scoreFont)
    love.graphics.printf("Score: " .. M.formatNumber(gameState.chips), 
        w / 2 - 95, h * 0.22 + 38, 190, "center")
end

function M.drawCardArea(area, label)
    -- Draw label if provided
    if label then
        love.graphics.setColor(0.6, 0.6, 0.7, 0.7)
        local labelFont = love.graphics.newFont(14)
        love.graphics.setFont(labelFont)
        love.graphics.print(label, area.x, area.y - 20)
    end
    
    -- Draw slot indicators for joker/consumable areas
    if area.showSlots or area.type == CardArea.TYPE.JOKER or area.type == CardArea.TYPE.CONSUMABLE then
        local slotCount = area.maxCards
        local startX = area.x + area.cardWidth / 2 + 10
        
        for i = 1, slotCount do
            local x = startX + (i - 1) * (area.cardWidth + area.spacing)
            local y = area.y + area.height / 2
            
            love.graphics.setColor(0.2, 0.2, 0.3, 0.3)
            love.graphics.rectangle("fill",
                x - area.cardWidth / 2,
                y - area.cardHeight / 2,
                area.cardWidth, area.cardHeight, 6)
        end
    end
    
    -- Draw cards (skip dragged cards - they're drawn on top)
    for _, card in ipairs(area:getCards()) do
        if not card.dragging then
            CardRender.draw(card, card.x, card.y, area.cardWidth, area.cardHeight, elapsedTime)
            
            -- Draw selection indicator for hand cards when consumable is selected
            if area.type == CardArea.TYPE.HAND and selectedConsumable and card.selected then
                love.graphics.setColor(0.4, 0.7, 1, 0.5)
                love.graphics.setLineWidth(4)
                love.graphics.rectangle("line",
                    card.x - area.cardWidth / 2 - 3,
                    card.y - area.cardHeight / 2 - 3,
                    area.cardWidth + 6, area.cardHeight + 6, 6)
            end
        end
    end
    
    -- Draw selection highlight for consumable area
    if area.type == CardArea.TYPE.CONSUMABLE and selectedConsumable then
        local card = selectedConsumable
        love.graphics.setColor(0.4, 0.7, 1, 0.3)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line",
            card.x - area.cardWidth / 2 - 2,
            card.y - area.cardHeight / 2 - 2,
            area.cardWidth + 4, area.cardHeight + 4, 6)
    end
    
    -- Draw USE button for selected consumable
    if area.type == CardArea.TYPE.CONSUMABLE and selectedConsumable then
        local selectedHandCards = handArea:getSelected()
        local ConsumableEffects = require("micatro.core.consumable_effects")
        local canUse = ConsumableEffects.canUse(selectedConsumable, gameState, selectedHandCards)
        
        if canUse then
            -- Position button below the consumable area, centered
            local useBtnW, useBtnH = 70, 40
            local useBtnX = area.x + (area.width - useBtnW) / 2
            local useBtnY = area.y + area.height + 15
            
            -- Shadow
            love.graphics.setColor(0, 0, 0, 0.3)
            love.graphics.rectangle("fill", useBtnX + 2, useBtnY + 2, useBtnW, useBtnH, 6)
            
            if useButtonHovered then
                love.graphics.setColor(0.3, 0.7, 0.4, 1)
            else
                love.graphics.setColor(0.2, 0.5, 0.3, 1)
            end
            love.graphics.rectangle("fill", useBtnX, useBtnY, useBtnW, useBtnH, 6)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", useBtnX, useBtnY, useBtnW, useBtnH, 6)
            
            local btnFont = love.graphics.newFont(16)
            love.graphics.setFont(btnFont)
            love.graphics.printf("USE", useBtnX, useBtnY + 12, useBtnW, "center")
        end
    end
end

function M.drawButtons()
    local w, h = love.graphics.getDimensions()
    
    local btnW, btnH = 100, 45
    local btnY = h * 0.85
    local btnSpacing = 20
    local totalWidth = btnW * 4 + btnSpacing * 3
    local startX = (w - totalWidth) / 2
    
    local buttons = {
        {id = "play", label = "PLAY", enabled = gameState.hands_remaining > 0 and handArea.selectedCount > 0},
        {id = "discard", label = "DISCARD", enabled = gameState.discards_remaining > 0 and handArea.selectedCount > 0},
        {id = "sort_rank", label = "RANK", enabled = true},
        {id = "sort_suit", label = "SUIT", enabled = true}
    }
    
    for i, btn in ipairs(buttons) do
        local x = startX + (i - 1) * (btnW + btnSpacing)
        local isHovered = hoveredButton == btn.id
        local alpha = btn.enabled and 1 or 0.5
        
        -- Shadow
        love.graphics.setColor(0, 0, 0, 0.3 * alpha)
        love.graphics.rectangle("fill", x + 3, btnY + 3, btnW, btnH, 8)
        
        -- Background
        if btn.id == "play" then
            love.graphics.setColor(0.2 * alpha, 0.5 * alpha, 0.3 * alpha, alpha)
        elseif btn.id == "discard" then
            love.graphics.setColor(0.5 * alpha, 0.3 * alpha, 0.2 * alpha, alpha)
        else
            love.graphics.setColor(0.3 * alpha, 0.3 * alpha, 0.4 * alpha, alpha)
        end
        
        if isHovered and btn.enabled then
            love.graphics.setColor(0.4, 0.5, 0.6, 1)
        end
        
        love.graphics.rectangle("fill", x, btnY, btnW, btnH, 8)
        
        -- Border
        love.graphics.setColor(0.5, 0.5, 0.6, alpha)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x, btnY, btnW, btnH, 8)
        
        -- Label
        love.graphics.setColor(1, 1, 1, alpha)
        local btnFont = love.graphics.newFont(16)
        love.graphics.setFont(btnFont)
        love.graphics.printf(btn.label, x, btnY + btnH/2 - 8, btnW, "center")
    end
    
    -- Hands/Discards remaining
    love.graphics.setColor(0.8, 0.8, 0.9, 0.8)
    local infoFont = love.graphics.newFont(14)
    love.graphics.setFont(infoFont)
    love.graphics.printf(
        "Hands: " .. gameState.hands_remaining .. " • Discards: " .. gameState.discards_remaining,
        0, btnY - 25, w, "center")
end

function M.drawHandResult()
    if not lastHandResult then return end
    
    local w, h = love.graphics.getDimensions()
    
    love.graphics.setColor(0.1, 0.1, 0.15, 0.9)
    love.graphics.rectangle("fill", w/2 - 120, h * 0.48, 240, 50, 8)
    
    love.graphics.setColor(1, 1, 1, 1)
    local resultFont = love.graphics.newFont(18)
    love.graphics.setFont(resultFont)
    love.graphics.printf(lastHandResult.hand_name, w/2 - 115, h * 0.48 + 5, 230, "center")
    
    love.graphics.setColor(0.9, 0.8, 0.4, 1)
    local scoreFont = love.graphics.newFont(16)
    love.graphics.setFont(scoreFont)
    love.graphics.printf("+" .. M.formatNumber(lastHandResult.final_score) .. " chips", 
        w/2 - 115, h * 0.48 + 28, 230, "center")
end

function M.formatNumber(n)
    if n >= 1000000 then
        return string.format("%.1fM", n / 1000000)
    elseif n >= 1000 then
        return string.format("%.1fK", n / 1000)
    end
    return tostring(math.floor(n))
end

function M.mousemoved(x, y, dx, dy)
    -- Update card areas (handles drag updates too)
    handArea:onMouseMoved(x, y)
    playArea:onMouseMoved(x, y)
    jokerArea:onMouseMoved(x, y)
    consumableArea:onMouseMoved(x, y)
    
    -- Check for hovered cards (for tooltips)
    local newHoveredCard = nil
    
    -- Check consumable area FIRST (before joker area to avoid conflicts)
    local consumableCard = consumableArea:getCardAt(x, y)
    if consumableCard and consumableCard.data and consumableCard.data.key then
        newHoveredCard = consumableCard
    else
        -- Check joker area
        local jokerCard = jokerArea:getCardAt(x, y)
        if jokerCard and jokerCard.data and jokerCard.data.key then
            newHoveredCard = jokerCard
        end
    end
    
    -- Update hovered card
    if newHoveredCard ~= hoveredCard then
        hoveredCard = newHoveredCard
        hoveredCardTimer = 0
        if not hoveredCard then
            Tooltip.hideGlobal()
        end
    end
    
    -- Check USE button hover if consumable is selected
    useButtonHovered = false
    if selectedConsumable then
        local selectedHandCards = handArea:getSelected()
        local ConsumableEffects = require("micatro.core.consumable_effects")
        local canUse = ConsumableEffects.canUse(selectedConsumable, gameState, selectedHandCards)
        
        if canUse then
            local useBtnW, useBtnH = 70, 40
            local useBtnX = consumableArea.x + (consumableArea.width - useBtnW) / 2
            local useBtnY = consumableArea.y + consumableArea.height + 15
            if x >= useBtnX and x <= useBtnX + useBtnW and
               y >= useBtnY and y <= useBtnY + useBtnH then
                useButtonHovered = true
            end
        end
    end
    
    -- Update button hovers (only when not dragging)
    if not handArea:isDragging() and not jokerArea:isDragging() then
        local w, h = love.graphics.getDimensions()
        local btnW, btnH = 100, 45
        local btnY = h * 0.85
        local btnSpacing = 20
        local totalWidth = btnW * 4 + btnSpacing * 3
        local startX = (w - totalWidth) / 2
        
        hoveredButton = nil
        local buttons = {"play", "discard", "sort_rank", "sort_suit"}
        for i, id in ipairs(buttons) do
            local bx = startX + (i - 1) * (btnW + btnSpacing)
            if x >= bx and x <= bx + btnW and y >= btnY and y <= btnY + btnH then
                hoveredButton = id
                break
            end
        end
    end
end

function M.mousepressed(x, y, button)
    if button == 1 then
        -- Check USE button first (before anything else, including hand area)
        if selectedConsumable then
            local selectedHandCards = handArea:getSelected()
            local ConsumableEffects = require("micatro.core.consumable_effects")
            local canUse = ConsumableEffects.canUse(selectedConsumable, gameState, selectedHandCards)
            
            if canUse then
                local useBtnW, useBtnH = 70, 40
                local useBtnX = consumableArea.x + (consumableArea.width - useBtnW) / 2
                local useBtnY = consumableArea.y + consumableArea.height + 15
                
                -- Check if clicking USE button
                if x >= useBtnX and x <= useBtnX + useBtnW and
                   y >= useBtnY and y <= useBtnY + useBtnH then
                    lastMessage = "Using " .. (selectedConsumable.data.name or "consumable") .. "..."
                    messageTimer = 0
                    M.useConsumable(selectedConsumable)
                    return true  -- Consume the click, don't process hand area
                end
            end
        end
        
        -- Check buttons
        if hoveredButton == "play" and gameState.hands_remaining > 0 then
            M.playHand()
            return
        elseif hoveredButton == "discard" and gameState.discards_remaining > 0 then
            M.discardCards()
            return
        elseif hoveredButton == "sort_rank" then
            handArea:sortByRank()
            return
        elseif hoveredButton == "sort_suit" then
            handArea:sortBySuit()
            return
        end
        
        -- Check if clicking on consumable area FIRST (before hand area)
        local consumableCard = consumableArea:getCardAt(x, y)
        if consumableCard and consumableCard.data then
            -- Verify we have valid card data with a key and name
            local cardData = consumableCard.data
            if not cardData.key or not cardData.name then
                return  -- Invalid card data, ignore
            end
            
            -- Ensure card type matches data.set (this fixes type mismatches)
            if cardData.set == "Planet" then
                consumableCard.type = Card.TYPE.PLANET
            elseif cardData.set == "Tarot" then
                consumableCard.type = Card.TYPE.TAROT
            elseif cardData.set == "Spectral" then
                consumableCard.type = Card.TYPE.SPECTRAL
            end
            
            -- Read card name and key directly from the data (don't cache, read fresh)
            -- Double-check we have the right card by verifying the key matches
            local cardName = cardData.name
            local cardKey = cardData.key
            
            -- Verify the card data is correct (sanity check)
            if not cardName or not cardKey then
                return  -- Invalid data, ignore
            end
            
            if selectedConsumable == consumableCard then
                selectedConsumable = nil  -- Deselect
                lastMessage = "Deselected " .. cardName
                messageTimer = 0
            else
                selectedConsumable = consumableCard  -- Select
                local maxCards = (cardData.config and cardData.config.max_highlighted) or 1
                -- Read name again right before using it to ensure it's correct
                local finalName = consumableCard.data and consumableCard.data.name or cardName
                lastMessage = "Selected " .. finalName .. " (select " .. maxCards .. " card" .. (maxCards > 1 and "s" or "") .. ")"
                messageTimer = 0
            end
            return
        end
        
        -- Record potential drag start on hand area (actual drag/select happens on release/move)
        -- BUT only if we didn't click on the USE button
        local handCard = handArea:onMousePressed(x, y, button)
        
        -- Record potential drag start on joker area
        jokerArea:onMousePressed(x, y, button)
        
        -- Clicking elsewhere deselects consumable (but not if clicking on hand cards)
        if selectedConsumable and not handCard then
            selectedConsumable = nil
            lastMessage = nil
        end
    end
end

function M.mousereleased(x, y, button)
    if button == 1 then
        -- Always call onMouseReleased - it handles both drag end AND click selection
        handArea:onMouseReleased(x, y, button)
        jokerArea:onMouseReleased(x, y, button)
    end
end

function M.keypressed(key)
    if key == "escape" then
        if switchScene then
            switchScene("micatro_menu")
        end
    elseif key == "space" and gameState.hands_remaining > 0 then
        M.playHand()
    elseif key == "d" and gameState.discards_remaining > 0 then
        M.discardCards()
    elseif key == "s" then
        handArea:sortBySuit()
    elseif key == "r" then
        handArea:sortByRank()
    end
end

function M.playHand()
    local selected = handArea:getSelected()
    if #selected == 0 then return end
    if gameState.hands_remaining <= 0 then return end
    
    -- Deselect all cards first to reset selection state
    -- This ensures selectedCount is reset even if cards are removed
    handArea:deselectAll()
    
    -- Move cards to play area (sorted by original position for left-to-right scoring)
    local playedCards = {}
    local playedCardObjects = {}
    for _, card in ipairs(selected) do
        local index = handArea:getCardIndex(card)
        table.insert(playedCards, {card = card, index = index})
    end
    table.sort(playedCards, function(a, b) return a.index < b.index end)
    
    -- Move cards to play area
    for _, item in ipairs(playedCards) do
        handArea:removeCard(item.card)
        playArea:addCard(item.card)
        table.insert(playedCardObjects, item.card)
    end
    
    -- Get cards still in hand (for in-hand effects like steel, gold) - in order (left to right)
    local handCards = {}
    for _, card in ipairs(handArea:getCards()) do
        table.insert(handCards, {
            rank = card.rank,
            suit = card.suit,
            enhancement = card.enhancement,
            edition = card.edition,
            seal = card.seal,
            bonus_chips = card.bonus_chips or 0
        })
    end
    
    -- Build card data for scoring
    local playedCardsData = {}
    for _, card in ipairs(playedCardObjects) do
        table.insert(playedCardsData, {
            rank = card.rank,
            suit = card.suit,
            enhancement = card.enhancement,
            edition = card.edition,
            seal = card.seal,
            bonus_chips = card.bonus_chips or 0
        })
    end
    
    -- Start sequential scoring (cards score one at a time from left to right)
    scoringSequence = {
        cards = playedCardObjects,
        currentIndex = 1,
        timer = 0,
        cardDelay = 0.2,  -- Delay between each card scoring
        onComplete = function()
            -- All cards scored, calculate final result
            local result = Scoring.calculateScore(gameState, playedCardsData, {})
            result = Scoring.applyJokerEffects(gameState, result, {handCards = handCards})
            
            -- Update displays
            scoreDisplay.chips = result.final_chips
            scoreDisplay.mult = result.final_mult
            gameState.chips = gameState.chips + result.final_score
            gameState.hands_remaining = gameState.hands_remaining - 1
            lastHandResult = result
            
            -- Show message if gold cards gave money
            if result.gold_dollars and result.gold_dollars > 0 then
                lastMessage = "+$" .. result.gold_dollars .. " from Gold cards!"
                messageTimer = 0
            end
            
            -- Animate played cards sliding left, then draw new cards
            local cardsToAnimate = #playedCardObjects
            local cardsAnimated = 0
            
            for i, card in ipairs(playedCardObjects) do
                M.animateCardLeft(card, 0.3, function()
                    cardsAnimated = cardsAnimated + 1
                    if cardsAnimated == cardsToAnimate then
                        -- All cards animated, remove from play area and draw new
                        playArea:clear()
                        
                        -- Update game state (discard played cards)
                        local cardIds = {}
                        for _, c in ipairs(playedCardObjects) do
                            table.insert(cardIds, c.id)
                        end
                        GameState.discardCards(gameState, cardIds)
                        
                        -- Draw new cards
                        GameState.drawToHandSize(gameState)
                        
                        -- Add new cards from right
                        M.drawNewCardsFromRight()
                    end
                end)
            end
            
            -- Check if blind is beaten
            if gameState.chips >= gameState.blind_chips then
                -- Round won!
                eventManager:addDelay(2.0, function()
                    M.onRoundWon()
                end)
            end
        end
    }
end

-- Draw new cards sliding in from the right
function M.drawNewCardsFromRight()
    -- Get current card IDs in hand area
    local existingIds = {}
    for _, card in ipairs(handArea:getCards()) do
        existingIds[card.id] = true
    end
    
    -- Create card objects for new cards (ones not already in hand)
    local newCards = {}
    for _, cardData in ipairs(gameState.hand) do
        if not existingIds[cardData.id] then
            local card = Card.newPlaying(cardData.rank, cardData.suit, cardData.id)
            card.enhancement = cardData.enhancement
            card.edition = cardData.edition
            card.seal = cardData.seal
            card.bonus_chips = cardData.bonus_chips or 0
            table.insert(newCards, card)
        end
    end
    
    -- Add cards to hand area first (so layout calculates positions)
    for _, card in ipairs(newCards) do
        handArea:addCard(card)
    end
    
    -- Update layout to get target positions
    handArea:updateLayout()
    
    -- Animate cards sliding in from right
    for _, card in ipairs(newCards) do
        M.animateCardInFromRight(card, card.targetX, card.targetY, 0.3)
    end
end

function M.discardCards()
    local selected = handArea:getSelected()
    if #selected == 0 then return end
    if gameState.discards_remaining <= 0 then return end
    
    -- Animate cards sliding right
    local cardIds = {}
    local cardsToAnimate = #selected
    local cardsAnimated = 0
    
    -- Deselect all cards first
    handArea:deselectAll()
    
    for _, card in ipairs(selected) do
        table.insert(cardIds, card.id)
        M.animateCardRight(card, 0.3, function()
            cardsAnimated = cardsAnimated + 1
            -- Remove card from hand area (this updates layout)
            handArea:removeCard(card)
            
            if cardsAnimated == cardsToAnimate then
                -- All cards animated, update game state
                GameState.discardCards(gameState, cardIds)
                gameState.discards_remaining = gameState.discards_remaining - 1
                
                -- Draw new cards
                GameState.drawToHandSize(gameState)
                
                -- Add new cards from right
                M.drawNewCardsFromRight()
                
                -- Ensure layout is updated for remaining cards
                handArea:updateLayout()
            end
        end)
    end
end

function M.useConsumable(card)
    if not card or not card.data then 
        lastMessage = "ERROR: Invalid consumable"
        messageTimer = 0
        return 
    end
    
    local ConsumableEffects = require("micatro.core.consumable_effects")
    local selectedHandCards = handArea:getSelected()
    
    -- Check if can use
    local canUse = ConsumableEffects.canUse(card, gameState, selectedHandCards)
    if not canUse then
        local maxCards = card.data.config and card.data.config.max_highlighted or 1
        lastMessage = "Cannot use: Need " .. maxCards .. " selected card" .. (maxCards > 1 and "s" or "")
        messageTimer = 0
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
            bonus_chips = handCard.bonus_chips,
            id = handCard.id
        })
    end
    
    -- Use the consumable
    local success, message, effects = ConsumableEffects.use(card, gameState, selectedCardsData, handArea)
    
    if success then
        -- Always use the card's name for consistency
        local cardName = card.data and card.data.name or "consumable"
        lastMessage = "Used " .. cardName .. "!"
        messageTimer = 0
        
        -- Process effects and sync back to hand cards and game state
        if effects then
            -- Handle rank_up (Strength)
            if effects.rank_up then
                local updatedCount = 0
                for _, modifiedCard in ipairs(effects.rank_up) do
                    -- Find matching card in hand area
                    for _, handCard in ipairs(handArea:getCards()) do
                        if handCard.id == modifiedCard.id then
                            handCard.rank = modifiedCard.rank
                            -- Update in game state
                            for _, cardData in ipairs(gameState.hand) do
                                if cardData.id == handCard.id then
                                    cardData.rank = modifiedCard.rank
                                    break
                                end
                            end
                            updatedCount = updatedCount + 1
                            break
                        end
                    end
                end
                if updatedCount > 0 then
                    lastMessage = "Rank increased on " .. updatedCount .. " card(s)!"
                    messageTimer = 0
                end
            end
            
            -- Handle enhanced cards (Magician, Empress, Chariot, etc.)
            if effects.enhanced then
                local updatedCount = 0
                for _, modifiedCard in ipairs(effects.enhanced) do
                    -- Find matching card in hand area
                    for _, handCard in ipairs(handArea:getCards()) do
                        if handCard.id == modifiedCard.id then
                            handCard.enhancement = modifiedCard.enhancement
                            -- Update in game state
                            for _, cardData in ipairs(gameState.hand) do
                                if cardData.id == handCard.id then
                                    cardData.enhancement = modifiedCard.enhancement
                                    break
                                end
                            end
                            updatedCount = updatedCount + 1
                            break
                        end
                    end
                end
                if updatedCount > 0 then
                    local enhancementName = nil
                    if #effects.enhanced > 0 then
                        local enh = Enhancements.get(effects.enhanced[1].enhancement)
                        enhancementName = enh and enh.name or effects.enhanced[1].enhancement
                    end
                    lastMessage = "Applied " .. (enhancementName or "enhancement") .. " to " .. updatedCount .. " card(s)!"
                    messageTimer = 0
                end
            end
            
            -- Handle converted cards (suit changes)
            if effects.converted then
                for _, modifiedCard in ipairs(effects.converted) do
                    -- Find matching card in hand area
                    for _, handCard in ipairs(handArea:getCards()) do
                        if handCard.id == modifiedCard.id then
                            handCard.suit = modifiedCard.suit
                            -- Update in game state
                            for _, cardData in ipairs(gameState.hand) do
                                if cardData.id == handCard.id then
                                    cardData.suit = modifiedCard.suit
                                    break
                                end
                            end
                            break
                        end
                    end
                end
            end
            
            -- Handle destroyed cards (Hanged Man)
            if effects.destroyed then
                local destroyedIds = {}
                for _, destroyedCard in ipairs(effects.destroyed) do
                    table.insert(destroyedIds, destroyedCard.id)
                    -- Find and remove card from hand area
                    for _, handCard in ipairs(handArea:getCards()) do
                        if handCard.id == destroyedCard.id then
                            handArea:removeCard(handCard)
                            break
                        end
                    end
                end
                -- Remove destroyed cards from game state (but don't draw new ones)
                GameState.discardCards(gameState, destroyedIds)
                -- Also remove from gameState.hand array
                for i = #gameState.hand, 1, -1 do
                    local found = false
                    for _, destroyedId in ipairs(destroyedIds) do
                        if gameState.hand[i].id == destroyedId then
                            found = true
                            break
                        end
                    end
                    if found then
                        table.remove(gameState.hand, i)
                    end
                end
                -- Don't draw new cards - hand stays smaller until next discard/play
            end
            
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
            
            -- Create consumables (High Priestess, Emperor, Fool, etc.)
            if effects.created then
                local createdCount = 0
                for _, consumableData in ipairs(effects.created) do
                    GameState.addConsumable(gameState, consumableData)
                    -- Add to consumable area if there's room
                    if consumableArea:hasRoom() then
                        local newCard = Card.newConsumable(consumableData)
                        consumableArea:addCard(newCard)
                        createdCount = createdCount + 1
                    end
                end
                if createdCount > 0 then
                    lastMessage = "Created " .. createdCount .. " consumable" .. (createdCount > 1 and "s" or "") .. "!"
                    messageTimer = 0
                end
            end
        end
        
        -- Remove consumable from area
        consumableArea:removeCard(card)
        -- Remove from game state
        for i, cons in ipairs(gameState.consumables) do
            if cons.data.key == card.data.key then
                table.remove(gameState.consumables, i)
                break
            end
        end
        
        -- Deselect
        selectedConsumable = nil
        handArea:deselectAll()
    else
        lastMessage = "Failed: " .. (message or "unknown error")
        messageTimer = 0
    end
end

-- Update scoring sequence (cards score one at a time)
function M.updateScoringSequence(dt)
    if not scoringSequence then return end
    
    scoringSequence.timer = scoringSequence.timer + dt
    
    if scoringSequence.timer >= scoringSequence.cardDelay then
        -- Score next card
        local cardIndex = scoringSequence.currentIndex
        if cardIndex <= #scoringSequence.cards then
            local card = scoringSequence.cards[cardIndex]
            if card then
                card:highlight()
            end
            
            -- Move to next card
            scoringSequence.currentIndex = cardIndex + 1
            scoringSequence.timer = 0
        else
            -- All cards scored, finish
            local onComplete = scoringSequence.onComplete
            scoringSequence = nil
            if onComplete then
                onComplete()
            end
        end
    end
end

-- Update card animations (sliding left/right)
function M.updateCardAnimations(dt)
    for i = #cardAnimations, 1, -1 do
        local anim = cardAnimations[i]
        anim.timer = anim.timer + dt
        
        if anim.timer >= anim.duration then
            -- Animation complete
            -- Clear the animating flag before calling onComplete
            if anim.card then
                anim.card.animatingAway = false
            end
            if anim.onComplete then
                anim.onComplete()
            end
            table.remove(cardAnimations, i)
        else
            -- Update card position
            local progress = anim.timer / anim.duration
            local ease = progress * (2 - progress)  -- Ease out
            anim.card.x = anim.startX + (anim.endX - anim.startX) * ease
            anim.card.y = anim.startY + (anim.endY - anim.startY) * ease
        end
    end
end

-- Animate card sliding left (for discards/played cards)
function M.animateCardLeft(card, duration, onComplete)
    duration = duration or 0.3
    local startX = card.x
    local startY = card.y
    local w, h = love.graphics.getDimensions()
    local endX = -200  -- Off screen left
    local endY = card.y
    
    -- Deselect card before animating
    if card.selected then
        card:deselect()
    end
    
    -- Mark card as being animated (so it doesn't interfere with selection)
    card.animatingAway = true
    
    table.insert(cardAnimations, {
        card = card,
        startX = startX,
        startY = startY,
        endX = endX,
        endY = endY,
        timer = 0,
        duration = duration,
        onComplete = onComplete
    })
end

-- Animate card sliding right (for discarded cards)
function M.animateCardRight(card, duration, onComplete)
    duration = duration or 0.3
    local startX = card.x
    local startY = card.y
    local w, h = love.graphics.getDimensions()
    local endX = w + 200  -- Off screen right
    local endY = card.y
    
    -- Deselect card before animating
    if card.selected then
        card:deselect()
    end
    
    -- Mark card as being animated (so it doesn't interfere with selection)
    card.animatingAway = true
    
    table.insert(cardAnimations, {
        card = card,
        startX = startX,
        startY = startY,
        endX = endX,
        endY = endY,
        timer = 0,
        duration = duration,
        onComplete = onComplete
    })
end

-- Animate card sliding in from right
function M.animateCardInFromRight(card, targetX, targetY, duration)
    duration = duration or 0.3
    local w, h = love.graphics.getDimensions()
    card:setPosition(w + 100, targetY)  -- Start off screen right
    card:setTarget(targetX, targetY)
end

-- Show tooltip for a card
function M.showCardTooltip(card, x, y)
    if not card or not card.data then
        Tooltip.hideGlobal()
        return
    end
    
    local data = card.data
    -- Verify we have the right card by checking the key
    if not data.key or not data.name then
        Tooltip.hideGlobal()
        return
    end
    
    -- Ensure card type matches data.set (fix any mismatches)
    if data.set == "Planet" then
        card.type = Card.TYPE.PLANET
    elseif data.set == "Tarot" then
        card.type = Card.TYPE.TAROT
    elseif data.set == "Spectral" then
        card.type = Card.TYPE.SPECTRAL
    end
    
    local tooltipData = {
        title = data.name or "Card",
        description = data.description or "",
        stats = {},
        rarity = data.rarity
    }
    
    -- Add stats based on card type
    if card.type == Card.TYPE.JOKER then
        -- Joker stats
        if data.config and data.config.mult then
            table.insert(tooltipData.stats, {
                label = "Mult",
                value = "+" .. data.config.mult,
                color = {0.8, 0.6, 0.9}
            })
        end
        if data.config and data.config.Xmult then
            table.insert(tooltipData.stats, {
                label = "X Mult",
                value = "x" .. data.config.Xmult,
                color = {0.9, 0.7, 0.3}
            })
        end
        if data.config and data.config.chips then
            table.insert(tooltipData.stats, {
                label = "Chips",
                value = "+" .. data.config.chips,
                color = {0.3, 0.7, 0.9}
            })
        end
        if data.cost then
            table.insert(tooltipData.stats, {
                label = "Cost",
                value = "$" .. data.cost,
                color = {0.7, 0.7, 0.7}
            })
        end
    elseif card.type == Card.TYPE.TAROT or card.type == Card.TYPE.PLANET or card.type == Card.TYPE.SPECTRAL then
        -- Consumable stats
        if data.cost then
            table.insert(tooltipData.stats, {
                label = "Cost",
                value = "$" .. data.cost,
                color = {0.7, 0.7, 0.7}
            })
        end
        if data.config and data.config.max_highlighted then
            table.insert(tooltipData.stats, {
                label = "Select",
                value = data.config.max_highlighted .. " card" .. (data.config.max_highlighted > 1 and "s" or ""),
                color = {0.5, 0.8, 0.5}
            })
        end
        if data.effect then
            table.insert(tooltipData.stats, {
                label = "Effect",
                value = data.effect,
                color = {0.8, 0.8, 0.5}
            })
        end
    end
    
    Tooltip.showGlobal(x + 15, y + 15, tooltipData)
end

function M.onRoundWon()
    -- Calculate earnings
    local interest = GameState.calculateInterest(gameState)
    local handBonus = gameState.hands_remaining
    local blind_reward = gameState.current_blind.dollars or 3
    
    local total = blind_reward + interest + handBonus
    GameState.addMoney(gameState, total)
    
    -- Progress to next blind
    GameState.nextBlind(gameState)
    
    -- Store game state globally before switching
    _G.MICATRO_GAME_STATE = gameState
    
    -- Go to shop or next round
    if switchScene then
        switchScene("micatro_shop")
    else
        M.startRound()
    end
end

function M.resize(w, h)
    -- Update area positions
    if handArea then
        handArea.x = w * 0.1
        handArea.y = h * 0.6
        handArea.width = w * 0.8
        handArea:updateLayout()
    end
    
    if playArea then
        playArea.x = w * 0.25
        playArea.y = h * 0.35
        playArea.width = w * 0.5
        playArea:updateLayout()
    end
    
    if jokerArea then
        jokerArea.x = w * 0.05
        jokerArea.y = h * 0.08
        jokerArea.width = w * 0.5
        jokerArea:updateLayout()
    end
    
    if consumableArea then
        consumableArea.x = w * 0.6
        consumableArea.y = h * 0.08
        consumableArea.width = w * 0.35
        consumableArea:updateLayout()
    end
end

return M
