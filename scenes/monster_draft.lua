-- Monster Draft Scene
-- Pick 1 of 3 Pokemon, repeat 6 times to build a team

local pokemonBuilder = require('data.monster.pokemonBuilder')
local types = require('data.monster.types')
local spriteLoader = require('data.monster.spriteLoader')

local draft = {}

-- Colors
local colors = {
    background = {0.05, 0.08, 0.12},
    backgroundGrad = {0.08, 0.12, 0.18},
    title = {0.4, 0.8, 1.0},
    text = {0.85, 0.9, 0.95},
    accent = {0.3, 0.7, 0.95},
    cardBg = {0.1, 0.14, 0.2},
    cardBorder = {0.3, 0.5, 0.7},
    cardHover = {0.15, 0.22, 0.32},
    statBar = {0.2, 0.5, 0.8},
    hp = {0.3, 0.8, 0.4}
}

-- State
local playerTeam = {}
local currentOptions = {}
local hoveredOption = nil
local pickCount = 0
local TEAM_SIZE = 6
local LEVEL = 50

-- Get drafted Pokemon IDs to exclude
local function getExcludedIds()
    local ids = {}
    for _, p in ipairs(playerTeam) do
        table.insert(ids, p.id)
    end
    return ids
end

-- Generate new options
local function generateOptions()
    currentOptions = pokemonBuilder.getDraftOptions(LEVEL, getExcludedIds())
    hoveredOption = nil
end

-- Draw a single stat bar
local function drawStatBar(x, y, width, label, value, maxVal)
    local barHeight = 12
    local labelWidth = 35
    
    -- Label
    love.graphics.setColor(colors.text[1], colors.text[2], colors.text[3], 0.7)
    local font = love.graphics.newFont(10)
    love.graphics.setFont(font)
    love.graphics.print(label, x, y)
    
    -- Bar background
    love.graphics.setColor(0.15, 0.18, 0.22)
    love.graphics.rectangle('fill', x + labelWidth, y, width - labelWidth, barHeight, 3, 3)
    
    -- Bar fill
    local fillWidth = ((value / maxVal) * (width - labelWidth - 20))
    love.graphics.setColor(colors.statBar)
    love.graphics.rectangle('fill', x + labelWidth, y, fillWidth, barHeight, 3, 3)
    
    -- Value
    love.graphics.setColor(colors.text)
    love.graphics.print(tostring(value), x + width - 20, y)
end

-- Draw a Pokemon card
local function drawPokemonCard(pokemon, x, y, width, height, isHovered)
    -- Card background
    if isHovered then
        love.graphics.setColor(colors.cardHover)
    else
        love.graphics.setColor(colors.cardBg)
    end
    love.graphics.rectangle('fill', x, y, width, height, 10, 10)
    
    -- Card border
    local typeColor = types.colors[pokemon.types[1]] or colors.cardBorder
    if isHovered then
        love.graphics.setColor(typeColor[1], typeColor[2], typeColor[3], 0.9)
        love.graphics.setLineWidth(3)
    else
        love.graphics.setColor(typeColor[1], typeColor[2], typeColor[3], 0.6)
        love.graphics.setLineWidth(2)
    end
    love.graphics.rectangle('line', x, y, width, height, 10, 10)
    
    local padding = 15
    local innerX = x + padding
    local innerY = y + padding
    local innerWidth = width - padding * 2
    
    -- Sprite area (top portion)
    local spriteAreaHeight = 100
    local spriteCenterX = x + width / 2
    local spriteCenterY = innerY + spriteAreaHeight / 2 + 10
    
    -- Sprite background circle
    love.graphics.setColor(typeColor[1] * 0.3, typeColor[2] * 0.3, typeColor[3] * 0.3, 0.5)
    love.graphics.circle('fill', spriteCenterX, spriteCenterY, 45)
    love.graphics.setColor(typeColor[1], typeColor[2], typeColor[3], 0.4)
    love.graphics.setLineWidth(2)
    love.graphics.circle('line', spriteCenterX, spriteCenterY, 45)
    
    -- Draw the sprite (maxSize matches the background circle diameter)
    spriteLoader.drawSprite(pokemon, spriteCenterX, spriteCenterY, 1.0, {maxSize = 80})
    
    -- Content below sprite
    local contentY = innerY + spriteAreaHeight + 15
    
    -- Name
    local nameFont = love.graphics.newFont(20)
    love.graphics.setFont(nameFont)
    love.graphics.setColor(colors.text)
    local nameWidth = nameFont:getWidth(pokemon.name)
    love.graphics.print(pokemon.name, x + (width - nameWidth) / 2, contentY)
    
    -- Types
    local typeY = contentY + 28
    local typeWidth = 65
    local typeTotalWidth = #pokemon.types * typeWidth + (#pokemon.types - 1) * 5
    local typeStartX = x + (width - typeTotalWidth) / 2
    for i, pType in ipairs(pokemon.types) do
        local tc = types.colors[pType] or {0.5, 0.5, 0.5}
        love.graphics.setColor(tc[1], tc[2], tc[3], 0.8)
        love.graphics.rectangle('fill', typeStartX + (i-1) * 70, typeY, typeWidth, 20, 4, 4)
        
        local typeFont = love.graphics.newFont(11)
        love.graphics.setFont(typeFont)
        love.graphics.setColor(1, 1, 1)
        local tw = typeFont:getWidth(pType)
        love.graphics.print(pType, typeStartX + (i-1) * 70 + (typeWidth - tw) / 2, typeY + 3)
    end
    
    -- Ability
    local abilY = typeY + 30
    local smallFont = love.graphics.newFont(11)
    love.graphics.setFont(smallFont)
    love.graphics.setColor(colors.text[1], colors.text[2], colors.text[3], 0.6)
    love.graphics.print("Ability: " .. pokemon.ability, innerX, abilY)
    
    -- Stats (compact)
    local statsY = abilY + 22
    local statHeight = 14
    drawStatBar(innerX, statsY, innerWidth, "HP", pokemon.stats.hp, 300)
    drawStatBar(innerX, statsY + statHeight, innerWidth, "Atk", pokemon.stats.atk, 200)
    drawStatBar(innerX, statsY + statHeight * 2, innerWidth, "Def", pokemon.stats.def, 200)
    drawStatBar(innerX, statsY + statHeight * 3, innerWidth, "SpA", pokemon.stats.spa, 200)
    drawStatBar(innerX, statsY + statHeight * 4, innerWidth, "SpD", pokemon.stats.spd, 200)
    drawStatBar(innerX, statsY + statHeight * 5, innerWidth, "Spe", pokemon.stats.spe, 200)
    
    -- Moves (compact list)
    local movesY = statsY + statHeight * 6 + 10
    local moveFont = love.graphics.newFont(10)
    love.graphics.setFont(moveFont)
    for i, move in ipairs(pokemon.moves) do
        local moveY = movesY + (i - 1) * 15
        local moveTypeColor = types.colors[move.type] or {0.5, 0.5, 0.5}
        love.graphics.setColor(moveTypeColor)
        love.graphics.circle('fill', innerX + 4, moveY + 5, 3)
        love.graphics.setColor(colors.text)
        love.graphics.print(move.name, innerX + 12, moveY)
        if move.basePower > 0 then
            love.graphics.setColor(colors.text[1], colors.text[2], colors.text[3], 0.5)
            love.graphics.print(tostring(move.basePower), innerX + innerWidth - 25, moveY)
        end
    end
    
    -- "Click to select" hint
    if isHovered then
        love.graphics.setColor(colors.accent)
        local hintFont = love.graphics.newFont(14)
        love.graphics.setFont(hintFont)
        local hint = "Click to select"
        local hw = hintFont:getWidth(hint)
        love.graphics.print(hint, x + (width - hw) / 2, y + height - 28)
    end
end

-- Draw team preview
local function drawTeamPreview(x, y)
    love.graphics.setColor(colors.text[1], colors.text[2], colors.text[3], 0.6)
    local font = love.graphics.newFont(14)
    love.graphics.setFont(font)
    love.graphics.print("Your Team:", x, y)
    
    for i = 1, TEAM_SIZE do
        local slotX = x + (i - 1) * 90
        local slotY = y + 25
        
        if playerTeam[i] then
            -- Filled slot
            local p = playerTeam[i]
            local typeColor = types.colors[p.types[1]] or {0.5, 0.5, 0.5}
            love.graphics.setColor(typeColor[1], typeColor[2], typeColor[3], 0.3)
            love.graphics.rectangle('fill', slotX, slotY, 80, 60, 6, 6)
            love.graphics.setColor(typeColor)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle('line', slotX, slotY, 80, 60, 6, 6)
            
            -- Draw sprite
            spriteLoader.drawSprite(p, slotX + 40, slotY + 25, 1.0, {maxSize = 40})
            
            love.graphics.setColor(colors.text)
            local nameFont = love.graphics.newFont(9)
            love.graphics.setFont(nameFont)
            local name = string.sub(p.name, 1, 10)
            local nw = nameFont:getWidth(name)
            love.graphics.print(name, slotX + (80 - nw) / 2, slotY + 48)
        else
            -- Empty slot
            love.graphics.setColor(0.15, 0.18, 0.22)
            love.graphics.rectangle('fill', slotX, slotY, 80, 60, 6, 6)
            love.graphics.setColor(colors.cardBorder[1], colors.cardBorder[2], colors.cardBorder[3], 0.5)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle('line', slotX, slotY, 80, 60, 6, 6)
            
            love.graphics.setColor(colors.text[1], colors.text[2], colors.text[3], 0.3)
            local emptyFont = love.graphics.newFont(10)
            love.graphics.setFont(emptyFont)
            love.graphics.print("Empty", slotX + 22, slotY + 22)
        end
    end
end

function draft.load() end

function draft.enter()
    playerTeam = {}
    pickCount = 0
    generateOptions()
end

function draft.exit() end

function draft.update(dt) end

function draft.draw()
    local w, h = love.graphics.getDimensions()
    
    -- Background gradient
    for i = 0, h do
        local t = i / h
        love.graphics.setColor(
            colors.background[1] + (colors.backgroundGrad[1] - colors.background[1]) * t,
            colors.background[2] + (colors.backgroundGrad[2] - colors.background[2]) * t,
            colors.background[3] + (colors.backgroundGrad[3] - colors.background[3]) * t
        )
        love.graphics.line(0, i, w, i)
    end
    
    -- Title
    local titleFont = love.graphics.newFont(32)
    love.graphics.setFont(titleFont)
    love.graphics.setColor(colors.title)
    local titleText = "Draft Your Team"
    local titleWidth = titleFont:getWidth(titleText)
    love.graphics.print(titleText, (w - titleWidth) / 2, 20)
    
    -- Pick counter
    local counterFont = love.graphics.newFont(20)
    love.graphics.setFont(counterFont)
    love.graphics.setColor(colors.text[1], colors.text[2], colors.text[3], 0.7)
    local counterText = "Pick " .. (pickCount + 1) .. " of " .. TEAM_SIZE
    local counterWidth = counterFont:getWidth(counterText)
    love.graphics.print(counterText, (w - counterWidth) / 2, 60)
    
    -- Team preview
    drawTeamPreview((w - 540) / 2, h - 100)
    
    -- Pokemon cards
    local cardWidth = 280
    local cardHeight = 380
    local cardSpacing = 30
    local totalWidth = cardWidth * 3 + cardSpacing * 2
    local startX = (w - totalWidth) / 2
    local cardY = 100
    
    for i, pokemon in ipairs(currentOptions) do
        local cardX = startX + (i - 1) * (cardWidth + cardSpacing)
        local isHovered = hoveredOption == i
        drawPokemonCard(pokemon, cardX, cardY, cardWidth, cardHeight, isHovered)
    end
end

function draft.mousemoved(x, y)
    local w, h = love.graphics.getDimensions()
    
    local cardWidth = 280
    local cardHeight = 380
    local cardSpacing = 30
    local totalWidth = cardWidth * 3 + cardSpacing * 2
    local startX = (w - totalWidth) / 2
    local cardY = 100
    
    hoveredOption = nil
    for i = 1, #currentOptions do
        local cardX = startX + (i - 1) * (cardWidth + cardSpacing)
        if x >= cardX and x <= cardX + cardWidth and y >= cardY and y <= cardY + cardHeight then
            hoveredOption = i
            break
        end
    end
end

function draft.mousepressed(x, y, button) end

function draft.mousereleased(x, y, button)
    if button == 1 and hoveredOption then
        -- Add selected Pokemon to team
        table.insert(playerTeam, currentOptions[hoveredOption])
        pickCount = pickCount + 1
        
        if pickCount >= TEAM_SIZE then
            -- Team complete, start battle
            -- Store team in a global for the battle scene
            _G.monsterPlayerTeam = playerTeam
            _G.monsterBattleNumber = 1
            switchScene("monster_battle")
        else
            -- Generate new options
            generateOptions()
        end
    end
end

function draft.keypressed(key)
    if key == "escape" then
        switchScene("monster_menu")
    end
end

function draft.resize() end

return draft

