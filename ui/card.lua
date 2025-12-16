-- Card Rendering
-- Visual card drawing for Love2D

local cards = require('data.cards')
local cardUI = {}

-- Card dimensions
cardUI.CARD_WIDTH = 100
cardUI.CARD_HEIGHT = 140
cardUI.MINI_CARD_WIDTH = 70
cardUI.MINI_CARD_HEIGHT = 100

-- Draw a full card
function cardUI.draw(cardData, x, y, options)
    options = options or {}
    local scale = options.scale or 1
    local hovered = options.hovered or false
    local playable = options.playable
    local isCreature = options.isCreature or false
    local currentHealth = options.currentHealth
    local currentAttack = options.currentAttack
    local damaged = options.damaged or false
    local canAttack = options.canAttack or false
    
    local w = cardUI.CARD_WIDTH * scale
    local h = cardUI.CARD_HEIGHT * scale
    
    -- Get color scheme for card class
    local colorScheme = cards.colorSchemes[cardData.cardClass] or cards.colorSchemes.neutral
    local rarityColor = cards.rarityColors[cardData.rarity] or cards.rarityColors.common
    
    love.graphics.push()
    love.graphics.translate(x, y)
    
    -- Apply hover effect
    if hovered then
        love.graphics.translate(0, -5 * scale)
    end
    
    -- Card shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle('fill', 3 * scale, 3 * scale, w, h, 6 * scale, 6 * scale)
    
    -- Card background gradient
    local bgColor = colorScheme.primary
    love.graphics.setColor(bgColor[1], bgColor[2], bgColor[3])
    love.graphics.rectangle('fill', 0, 0, w, h, 6 * scale, 6 * scale)
    
    -- Card border
    local borderColor = colorScheme.secondary
    if hovered then
        borderColor = colorScheme.glow
    end
    if canAttack then
        borderColor = {0.2, 0.9, 0.3} -- Green for attackable creatures
    end
    love.graphics.setColor(borderColor[1], borderColor[2], borderColor[3])
    love.graphics.setLineWidth(2 * scale)
    love.graphics.rectangle('line', 0, 0, w, h, 6 * scale, 6 * scale)
    
    -- Playability indicator (dim unplayable cards)
    if playable == false then
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle('fill', 0, 0, w, h, 6 * scale, 6 * scale)
    end
    
    -- Mana cost badge (top left)
    local costSize = 22 * scale
    love.graphics.setColor(0.2, 0.4, 0.9)
    love.graphics.circle('fill', costSize / 2 + 4 * scale, costSize / 2 + 4 * scale, costSize / 2)
    love.graphics.setColor(0.1, 0.2, 0.6)
    love.graphics.setLineWidth(2 * scale)
    love.graphics.circle('line', costSize / 2 + 4 * scale, costSize / 2 + 4 * scale, costSize / 2)
    
    -- Mana cost text
    love.graphics.setColor(1, 1, 1)
    local costFont = love.graphics.newFont(12 * scale)
    love.graphics.setFont(costFont)
    local costText = tostring(cardData.cost)
    local costWidth = costFont:getWidth(costText)
    love.graphics.print(costText, costSize / 2 + 4 * scale - costWidth / 2, costSize / 2 + 4 * scale - costFont:getHeight() / 2)
    
    -- Card name (top)
    love.graphics.setColor(1, 1, 1)
    local nameFont = love.graphics.newFont(math.max(8, 9 * scale))
    love.graphics.setFont(nameFont)
    local nameText = cardData.name
    local nameWidth = nameFont:getWidth(nameText)
    local maxNameWidth = w - 30 * scale
    
    -- Truncate name if too long
    if nameWidth > maxNameWidth then
        while nameWidth > maxNameWidth and #nameText > 3 do
            nameText = string.sub(nameText, 1, -2)
            nameWidth = nameFont:getWidth(nameText .. '..')
        end
        nameText = nameText .. '..'
        nameWidth = nameFont:getWidth(nameText)
    end
    
    love.graphics.print(nameText, (w - nameWidth) / 2 + 8 * scale, 6 * scale)
    
    -- Card art area (center)
    local artY = 26 * scale
    local artH = 50 * scale
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle('fill', 6 * scale, artY, w - 12 * scale, artH, 3 * scale, 3 * scale)
    
    -- Card type icon in art area
    love.graphics.setColor(colorScheme.accent[1], colorScheme.accent[2], colorScheme.accent[3], 0.5)
    local typeFont = love.graphics.newFont(20 * scale)
    love.graphics.setFont(typeFont)
    local typeIcon = cardData.type == 'creature' and '⚔' or '✨'
    local iconWidth = typeFont:getWidth(typeIcon)
    love.graphics.print(typeIcon, (w - iconWidth) / 2, artY + (artH - typeFont:getHeight()) / 2)
    
    -- Rarity gem (below art)
    local gemY = artY + artH + 4 * scale
    local gemSize = 6 * scale
    love.graphics.setColor(rarityColor.gem[1], rarityColor.gem[2], rarityColor.gem[3])
    love.graphics.circle('fill', w / 2, gemY + gemSize / 2, gemSize / 2)
    love.graphics.setColor(rarityColor.glow[1], rarityColor.glow[2], rarityColor.glow[3], 0.5)
    love.graphics.circle('line', w / 2, gemY + gemSize / 2, gemSize / 2 + 1)
    
    -- Card type text
    local typeTextFont = love.graphics.newFont(math.max(6, 7 * scale))
    love.graphics.setFont(typeTextFont)
    love.graphics.setColor(colorScheme.accent[1], colorScheme.accent[2], colorScheme.accent[3])
    local typeText = string.upper(cardData.type)
    local typeTextWidth = typeTextFont:getWidth(typeText)
    love.graphics.print(typeText, (w - typeTextWidth) / 2, gemY + gemSize + 2 * scale)
    
    -- Attack and Health for creatures (bottom corners)
    if cardData.type == 'creature' then
        local statSize = 20 * scale
        local statFont = love.graphics.newFont(11 * scale)
        love.graphics.setFont(statFont)
        
        -- Attack (bottom left) - red
        local attack = currentAttack or cardData.attack or 0
        love.graphics.setColor(0.9, 0.3, 0.3)
        love.graphics.circle('fill', statSize / 2 + 4 * scale, h - statSize / 2 - 4 * scale, statSize / 2)
        love.graphics.setColor(0.6, 0.1, 0.1)
        love.graphics.setLineWidth(2 * scale)
        love.graphics.circle('line', statSize / 2 + 4 * scale, h - statSize / 2 - 4 * scale, statSize / 2)
        
        love.graphics.setColor(1, 1, 1)
        local attackText = tostring(attack)
        local attackWidth = statFont:getWidth(attackText)
        love.graphics.print(attackText, statSize / 2 + 4 * scale - attackWidth / 2, h - statSize / 2 - 4 * scale - statFont:getHeight() / 2)
        
        -- Health (bottom right) - green (red if damaged)
        local health = currentHealth or cardData.health or 1
        local maxHealth = cardData.health or 1
        if damaged or (currentHealth and currentHealth < maxHealth) then
            love.graphics.setColor(0.9, 0.2, 0.2) -- Red for damaged
        else
            love.graphics.setColor(0.3, 0.8, 0.3)
        end
        love.graphics.circle('fill', w - statSize / 2 - 4 * scale, h - statSize / 2 - 4 * scale, statSize / 2)
        
        if damaged or (currentHealth and currentHealth < maxHealth) then
            love.graphics.setColor(0.6, 0.1, 0.1)
        else
            love.graphics.setColor(0.1, 0.5, 0.1)
        end
        love.graphics.setLineWidth(2 * scale)
        love.graphics.circle('line', w - statSize / 2 - 4 * scale, h - statSize / 2 - 4 * scale, statSize / 2)
        
        love.graphics.setColor(1, 1, 1)
        local healthText = tostring(health)
        local healthWidth = statFont:getWidth(healthText)
        love.graphics.print(healthText, w - statSize / 2 - 4 * scale - healthWidth / 2, h - statSize / 2 - 4 * scale - statFont:getHeight() / 2)
    end
    
    -- Keywords indicator (small icons)
    if cardData.keywords and #cardData.keywords > 0 then
        local kwFont = love.graphics.newFont(math.max(6, 7 * scale))
        love.graphics.setFont(kwFont)
        love.graphics.setColor(1, 0.9, 0.5, 0.9)
        
        local kwY = h - 32 * scale
        local kwText = ''
        for _, kw in ipairs(cardData.keywords) do
            if kw == 'Taunt' then kwText = kwText .. '🛡'
            elseif kw == 'Divine Shield' then kwText = kwText .. '✦'
            elseif kw == 'Charge' then kwText = kwText .. '⚡'
            elseif kw == 'Rush' then kwText = kwText .. '💨'
            elseif kw == 'Stealth' then kwText = kwText .. '👁'
            elseif kw == 'Deathtouch' then kwText = kwText .. '☠'
            elseif kw == 'Battlecry' then kwText = kwText .. '📢'
            elseif kw == 'Deathrattle' then kwText = kwText .. '💀'
            end
        end
        if kwText ~= '' then
            local kwWidth = kwFont:getWidth(kwText)
            love.graphics.print(kwText, (w - kwWidth) / 2, kwY)
        end
    end
    
    love.graphics.pop()
end

-- Draw a card back
function cardUI.drawBack(x, y, options)
    options = options or {}
    local scale = options.scale or 1
    
    local w = cardUI.CARD_WIDTH * scale
    local h = cardUI.CARD_HEIGHT * scale
    
    love.graphics.push()
    love.graphics.translate(x, y)
    
    -- Card shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle('fill', 3 * scale, 3 * scale, w, h, 6 * scale, 6 * scale)
    
    -- Card back background
    love.graphics.setColor(0.15, 0.1, 0.25)
    love.graphics.rectangle('fill', 0, 0, w, h, 6 * scale, 6 * scale)
    
    -- Card back pattern
    love.graphics.setColor(0.25, 0.15, 0.35)
    for i = 0, 4 do
        love.graphics.rectangle('fill', 10 * scale + i * 18 * scale, 10 * scale, 8 * scale, h - 20 * scale, 2 * scale, 2 * scale)
    end
    
    -- Border
    love.graphics.setColor(0.4, 0.25, 0.5)
    love.graphics.setLineWidth(2 * scale)
    love.graphics.rectangle('line', 0, 0, w, h, 6 * scale, 6 * scale)
    
    -- Center emblem
    love.graphics.setColor(0.5, 0.35, 0.6)
    love.graphics.circle('fill', w / 2, h / 2, 20 * scale)
    love.graphics.setColor(0.3, 0.2, 0.4)
    love.graphics.circle('line', w / 2, h / 2, 20 * scale)
    
    -- Emblem inner
    love.graphics.setColor(0.6, 0.45, 0.7)
    love.graphics.circle('fill', w / 2, h / 2, 12 * scale)
    
    love.graphics.pop()
end

-- Draw a mini creature card (for board display)
function cardUI.drawMiniCreature(creature, x, y, options)
    options = options or {}
    local hovered = options.hovered or false
    local selected = options.selected or false
    local canAttack = options.canAttack or false
    local isValidTarget = options.isValidTarget or false
    
    local w = cardUI.MINI_CARD_WIDTH
    local h = cardUI.MINI_CARD_HEIGHT
    
    local card = creature.card
    local colorScheme = cards.colorSchemes[card.cardClass] or cards.colorSchemes.neutral
    
    love.graphics.push()
    love.graphics.translate(x, y)
    
    -- Hover/selection effect
    if hovered or selected then
        love.graphics.translate(0, -3)
    end
    
    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle('fill', 2, 2, w, h, 4, 4)
    
    -- Background
    love.graphics.setColor(colorScheme.primary[1], colorScheme.primary[2], colorScheme.primary[3])
    love.graphics.rectangle('fill', 0, 0, w, h, 4, 4)
    
    -- Border color based on state
    local borderColor = colorScheme.secondary
    if selected then
        borderColor = {1, 0.8, 0.2} -- Yellow for selected
    elseif canAttack then
        borderColor = {0.2, 0.9, 0.3} -- Green for can attack
    elseif isValidTarget then
        borderColor = {0.9, 0.3, 0.3} -- Red for valid target
    elseif hovered then
        borderColor = colorScheme.glow
    end
    
    love.graphics.setColor(borderColor[1], borderColor[2], borderColor[3])
    love.graphics.setLineWidth(selected and 3 or 2)
    love.graphics.rectangle('line', 0, 0, w, h, 4, 4)
    
    -- Name
    love.graphics.setColor(1, 1, 1)
    local nameFont = love.graphics.newFont(8)
    love.graphics.setFont(nameFont)
    local name = card.name
    if #name > 10 then
        name = string.sub(name, 1, 8) .. '..'
    end
    local nameWidth = nameFont:getWidth(name)
    love.graphics.print(name, (w - nameWidth) / 2, 4)
    
    -- Art area
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle('fill', 4, 18, w - 8, 40, 2, 2)
    
    -- Type icon
    love.graphics.setColor(colorScheme.accent[1], colorScheme.accent[2], colorScheme.accent[3], 0.6)
    local typeFont = love.graphics.newFont(16)
    love.graphics.setFont(typeFont)
    local icon = '⚔'
    local iconWidth = typeFont:getWidth(icon)
    love.graphics.print(icon, (w - iconWidth) / 2, 26)
    
    -- Keywords icons
    if creature.keywords and #creature.keywords > 0 then
        local kwFont = love.graphics.newFont(8)
        love.graphics.setFont(kwFont)
        love.graphics.setColor(1, 0.9, 0.5)
        local kwText = ''
        for _, kw in ipairs(creature.keywords) do
            if kw == 'Taunt' then kwText = kwText .. '🛡'
            elseif kw == 'Divine Shield' then kwText = kwText .. '✦'
            elseif kw == 'Stealth' then kwText = kwText .. '👁'
            end
        end
        if kwText ~= '' then
            love.graphics.print(kwText, 4, 60)
        end
    end
    
    -- Attack (bottom left)
    local statSize = 18
    local statFont = love.graphics.newFont(10)
    love.graphics.setFont(statFont)
    
    love.graphics.setColor(0.9, 0.3, 0.3)
    love.graphics.circle('fill', statSize / 2 + 3, h - statSize / 2 - 3, statSize / 2)
    love.graphics.setColor(1, 1, 1)
    local atkText = tostring(creature.currentAttack)
    local atkWidth = statFont:getWidth(atkText)
    love.graphics.print(atkText, statSize / 2 + 3 - atkWidth / 2, h - statSize / 2 - 3 - statFont:getHeight() / 2)
    
    -- Health (bottom right)
    local maxHealth = card.health or 1
    if creature.currentHealth < maxHealth then
        love.graphics.setColor(0.9, 0.2, 0.2) -- Red for damaged
    else
        love.graphics.setColor(0.3, 0.8, 0.3)
    end
    love.graphics.circle('fill', w - statSize / 2 - 3, h - statSize / 2 - 3, statSize / 2)
    love.graphics.setColor(1, 1, 1)
    local hpText = tostring(creature.currentHealth)
    local hpWidth = statFont:getWidth(hpText)
    love.graphics.print(hpText, w - statSize / 2 - 3 - hpWidth / 2, h - statSize / 2 - 3 - statFont:getHeight() / 2)
    
    love.graphics.pop()
end

-- Check if point is inside card bounds
function cardUI.isPointInCard(px, py, cardX, cardY, scale)
    scale = scale or 1
    local w = cardUI.CARD_WIDTH * scale
    local h = cardUI.CARD_HEIGHT * scale
    return px >= cardX and px <= cardX + w and py >= cardY and py <= cardY + h
end

-- Check if point is inside mini creature bounds
function cardUI.isPointInMiniCreature(px, py, creatureX, creatureY)
    return px >= creatureX and px <= creatureX + cardUI.MINI_CARD_WIDTH and
           py >= creatureY and py <= creatureY + cardUI.MINI_CARD_HEIGHT
end

return cardUI

