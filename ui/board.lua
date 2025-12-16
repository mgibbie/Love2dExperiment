-- Board UI
-- Display and interaction for battlefield creatures

local cardUI = require('ui.card')
local board = {}

-- Board layout constants
board.CREATURE_SPACING = 80
board.PLAYER_BOARD_Y = 380
board.ENEMY_BOARD_Y = 180
board.HERO_SIZE = 80

-- Get centered hero positions (positioned to not overlap with hands)
function board.getHeroPositions()
    local w, h = love.graphics.getDimensions()
    local heroSize = board.HERO_SIZE
    local cardHeight = cardUI.CARD_HEIGHT or 140
    local handY = h - cardHeight - 20
    -- Player hero: between player board and hand
    local playerHeroY = board.PLAYER_BOARD_Y + cardUI.MINI_CARD_HEIGHT + 15
    return {
        enemy = { x = (w - heroSize) / 2, y = 90 },
        player = { x = (w - heroSize) / 2, y = playerHeroY }
    }
end

-- Check if point is in hero bounds
function board.isPointInHero(mx, my, heroX, heroY)
    return mx >= heroX and mx <= heroX + board.HERO_SIZE and
           my >= heroY and my <= heroY + board.HERO_SIZE
end

-- Draw creatures on a board
function board.drawCreatures(creatures, y, options)
    options = options or {}
    local hoveredIndex = options.hoveredIndex
    local selectedIndex = options.selectedIndex
    local attackingId = options.attackingId
    local isValidTargets = options.isValidTargets or {}
    local isPlayerBoard = options.isPlayerBoard
    
    local w = love.graphics.getWidth()
    local creatureWidth = cardUI.MINI_CARD_WIDTH
    local spacing = board.CREATURE_SPACING
    
    local totalWidth = (#creatures - 1) * spacing + creatureWidth
    local startX = (w - totalWidth) / 2
    
    for i, creature in ipairs(creatures) do
        local x = startX + (i - 1) * spacing
        local isHovered = hoveredIndex == i
        local isSelected = selectedIndex == i or creature.instanceId == attackingId
        local canAttack = isPlayerBoard and creature.canAttack and not creature.hasAttacked
        local isValidTarget = isValidTargets[creature.instanceId]
        
        cardUI.drawMiniCreature(creature, x, y, {
            hovered = isHovered,
            selected = isSelected,
            canAttack = canAttack,
            isValidTarget = isValidTarget
        })
    end
end

-- Draw placement slots for player board
function board.drawPlacementSlots(creatureCount, y, hoveredSlot)
    local w = love.graphics.getWidth()
    local slotWidth = 30
    local spacing = board.CREATURE_SPACING
    
    -- There are n+1 slots for n creatures
    local numSlots = creatureCount + 1
    local creatureWidth = cardUI.MINI_CARD_WIDTH
    
    -- Calculate positions based on where creatures would be
    local totalCreatureWidth = (creatureCount - 1) * spacing + creatureWidth
    local startCreatureX = (w - totalCreatureWidth) / 2
    
    for i = 1, numSlots do
        local x
        if i == 1 then
            x = startCreatureX - slotWidth - 10
        elseif i == numSlots then
            x = startCreatureX + totalCreatureWidth + 10
        else
            x = startCreatureX + (i - 2) * spacing + creatureWidth + (spacing - creatureWidth - slotWidth) / 2
        end
        
        local isHovered = hoveredSlot == i
        
        if isHovered then
            love.graphics.setColor(0.3, 0.9, 0.4, 0.6)
        else
            love.graphics.setColor(0.3, 0.7, 0.4, 0.3)
        end
        
        love.graphics.rectangle('fill', x, y, slotWidth, cardUI.MINI_CARD_HEIGHT, 4, 4)
        love.graphics.setColor(0.4, 0.9, 0.5, 0.8)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle('line', x, y, slotWidth, cardUI.MINI_CARD_HEIGHT, 4, 4)
        
        -- Plus icon
        love.graphics.setColor(0.5, 1, 0.6, isHovered and 1 or 0.6)
        love.graphics.setLineWidth(3)
        love.graphics.line(x + slotWidth/2 - 8, y + cardUI.MINI_CARD_HEIGHT/2, x + slotWidth/2 + 8, y + cardUI.MINI_CARD_HEIGHT/2)
        love.graphics.line(x + slotWidth/2, y + cardUI.MINI_CARD_HEIGHT/2 - 8, x + slotWidth/2, y + cardUI.MINI_CARD_HEIGHT/2 + 8)
    end
end

-- Get creature at position
function board.getCreatureAtPosition(creatures, mx, my, boardY)
    local w = love.graphics.getWidth()
    local creatureWidth = cardUI.MINI_CARD_WIDTH
    local creatureHeight = cardUI.MINI_CARD_HEIGHT
    local spacing = board.CREATURE_SPACING
    
    local totalWidth = (#creatures - 1) * spacing + creatureWidth
    local startX = (w - totalWidth) / 2
    
    for i, creature in ipairs(creatures) do
        local x = startX + (i - 1) * spacing
        
        if mx >= x and mx <= x + creatureWidth and my >= boardY and my <= boardY + creatureHeight then
            return i, creature
        end
    end
    
    return nil, nil
end

-- Get placement slot at position
function board.getPlacementSlotAtPosition(creatureCount, mx, my, boardY)
    local w = love.graphics.getWidth()
    local slotWidth = 30
    local spacing = board.CREATURE_SPACING
    local numSlots = creatureCount + 1
    local creatureWidth = cardUI.MINI_CARD_WIDTH
    local slotHeight = cardUI.MINI_CARD_HEIGHT
    
    local totalCreatureWidth = (creatureCount - 1) * spacing + creatureWidth
    local startCreatureX = (w - totalCreatureWidth) / 2
    
    for i = 1, numSlots do
        local x
        if i == 1 then
            x = startCreatureX - slotWidth - 10
        elseif i == numSlots then
            x = startCreatureX + totalCreatureWidth + 10
        else
            x = startCreatureX + (i - 2) * spacing + creatureWidth + (spacing - creatureWidth - slotWidth) / 2
        end
        
        if mx >= x and mx <= x + slotWidth and my >= boardY and my <= boardY + slotHeight then
            return i
        end
    end
    
    return nil
end

-- Draw hero portrait
function board.drawHero(hero, x, y, options)
    options = options or {}
    local isPlayer = options.isPlayer
    local isTargetable = options.isTargetable
    local hovered = options.hovered
    
    local size = 80
    
    -- Background
    love.graphics.setColor(0.15, 0.1, 0.2)
    love.graphics.rectangle('fill', x, y, size, size, 8, 8)
    
    -- Border
    local borderColor = {0.4, 0.3, 0.5}
    if isTargetable then
        borderColor = {0.9, 0.3, 0.3}
    elseif hovered then
        borderColor = {0.6, 0.5, 0.7}
    end
    love.graphics.setColor(borderColor[1], borderColor[2], borderColor[3])
    love.graphics.setLineWidth(3)
    love.graphics.rectangle('line', x, y, size, size, 8, 8)
    
    -- Hero icon
    love.graphics.setColor(1, 1, 1)
    local iconFont = love.graphics.newFont(32)
    love.graphics.setFont(iconFont)
    local icon = hero.heroIcon or '🦸'
    local iconWidth = iconFont:getWidth(icon)
    love.graphics.print(icon, x + (size - iconWidth) / 2, y + 10)
    
    -- Health display
    local healthFont = love.graphics.newFont(14)
    love.graphics.setFont(healthFont)
    
    -- Health bar background
    love.graphics.setColor(0.2, 0.1, 0.1)
    love.graphics.rectangle('fill', x + 5, y + size - 25, size - 10, 20, 3, 3)
    
    -- Health bar fill
    local healthPercent = hero.life / hero.maxLife
    if healthPercent > 0.5 then
        love.graphics.setColor(0.3, 0.8, 0.3)
    elseif healthPercent > 0.25 then
        love.graphics.setColor(0.9, 0.7, 0.2)
    else
        love.graphics.setColor(0.9, 0.2, 0.2)
    end
    love.graphics.rectangle('fill', x + 5, y + size - 25, (size - 10) * healthPercent, 20, 3, 3)
    
    -- Health text
    love.graphics.setColor(1, 1, 1)
    local healthText = hero.life .. "/" .. hero.maxLife
    local healthWidth = healthFont:getWidth(healthText)
    love.graphics.print(healthText, x + (size - healthWidth) / 2, y + size - 23)
end

-- Draw mana display
function board.drawMana(current, max, x, y)
    -- Background panel
    local panelW = 100
    local panelH = 50
    love.graphics.setColor(0.1, 0.08, 0.15, 0.9)
    love.graphics.rectangle('fill', x, y, panelW, panelH, 6, 6)
    love.graphics.setColor(0.3, 0.5, 0.8, 0.6)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', x, y, panelW, panelH, 6, 6)
    
    -- Mana text (large)
    local font = love.graphics.newFont(22)
    love.graphics.setFont(font)
    love.graphics.setColor(0.4, 0.7, 1)
    local text = current .. " / " .. max
    local textW = font:getWidth(text)
    love.graphics.print(text, x + (panelW - textW) / 2, y + 5)
    
    -- Label
    local smallFont = love.graphics.newFont(11)
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.6, 0.75, 0.9, 0.8)
    love.graphics.print("MANA", x + (panelW - smallFont:getWidth("MANA")) / 2, y + 32)
end

-- Draw deck/graveyard counts
function board.drawDeckInfo(deckCount, graveyardCount, x, y)
    local font = love.graphics.newFont(12)
    love.graphics.setFont(font)
    
    -- Deck
    love.graphics.setColor(0.4, 0.3, 0.5)
    love.graphics.rectangle('fill', x, y, 40, 55, 4, 4)
    love.graphics.setColor(0.6, 0.5, 0.7)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', x, y, 40, 55, 4, 4)
    
    love.graphics.setColor(1, 1, 1)
    local deckText = tostring(deckCount)
    local deckWidth = font:getWidth(deckText)
    love.graphics.print(deckText, x + (40 - deckWidth) / 2, y + 20)
    
    -- Graveyard
    love.graphics.setColor(0.3, 0.2, 0.3)
    love.graphics.rectangle('fill', x, y + 65, 40, 55, 4, 4)
    love.graphics.setColor(0.5, 0.4, 0.5)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', x, y + 65, 40, 55, 4, 4)
    
    love.graphics.setColor(0.8, 0.7, 0.8)
    local gyText = tostring(graveyardCount)
    local gyWidth = font:getWidth(gyText)
    love.graphics.print(gyText, x + (40 - gyWidth) / 2, y + 85)
end

return board

