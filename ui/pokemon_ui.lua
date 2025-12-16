-- Pokemon UI Components
-- Reusable drawing functions for Pokemon displays

local types = require('data.monster.types')
local spriteLoader = require('data.monster.spriteLoader')

local ui = {}

-- Re-export spriteLoader for convenience
ui.spriteLoader = spriteLoader

-- Colors
ui.colors = {
    text = {0.85, 0.9, 0.95},
    accent = {0.3, 0.7, 0.95},
    hpGreen = {0.3, 0.8, 0.4},
    hpYellow = {0.9, 0.8, 0.2},
    hpRed = {0.9, 0.3, 0.3},
    buttonBg = {0.12, 0.16, 0.22},
    buttonHover = {0.18, 0.24, 0.32},
    buttonBorder = {0.3, 0.5, 0.7},
    panelBg = {0.08, 0.1, 0.14, 0.9},
    -- Status condition colors
    statusParalysis = {0.95, 0.85, 0.2},
    statusBurn = {0.95, 0.4, 0.2},
    statusPoison = {0.7, 0.3, 0.8},
    statusSleep = {0.6, 0.6, 0.7},
    statusFreeze = {0.4, 0.8, 0.95},
    -- Stat boost colors
    statBoost = {0.3, 0.85, 0.5},
    statDrop = {0.95, 0.35, 0.35}
}

-- Status condition display info
ui.statusInfo = {
    paralysis = { color = ui.colors.statusParalysis, label = "PAR", fullName = "Paralyzed" },
    burn = { color = ui.colors.statusBurn, label = "BRN", fullName = "Burned" },
    poison = { color = ui.colors.statusPoison, label = "PSN", fullName = "Poisoned" },
    badpoison = { color = ui.colors.statusPoison, label = "TOX", fullName = "Badly Poisoned" },
    sleep = { color = ui.colors.statusSleep, label = "SLP", fullName = "Asleep" },
    freeze = { color = ui.colors.statusFreeze, label = "FRZ", fullName = "Frozen" }
}

-- Get HP bar color based on percentage
function ui.getHPColor(current, max)
    local pct = current / max
    if pct > 0.5 then return ui.colors.hpGreen end
    if pct > 0.2 then return ui.colors.hpYellow end
    return ui.colors.hpRed
end

-- Draw a Pokemon's status display
function ui.drawPokemonStatus(pokemon, x, y, width)
    local height = 80
    
    -- Background panel
    love.graphics.setColor(ui.colors.panelBg)
    love.graphics.rectangle('fill', x, y, width, height, 8, 8)
    love.graphics.setColor(ui.colors.buttonBorder)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', x, y, width, height, 8, 8)
    
    local padding = 10
    
    -- Name and Level
    local nameFont = love.graphics.newFont(18)
    love.graphics.setFont(nameFont)
    love.graphics.setColor(ui.colors.text)
    love.graphics.print(pokemon.name, x + padding, y + padding)
    
    local lvlFont = love.graphics.newFont(14)
    love.graphics.setFont(lvlFont)
    love.graphics.setColor(ui.colors.text[1], ui.colors.text[2], ui.colors.text[3], 0.7)
    love.graphics.print("Lv." .. pokemon.level, x + width - 50, y + padding + 2)
    
    -- Status condition badge (next to level)
    if pokemon.status and ui.statusInfo[pokemon.status] then
        local statusData = ui.statusInfo[pokemon.status]
        local statusX = x + width - 95
        love.graphics.setColor(statusData.color[1], statusData.color[2], statusData.color[3], 0.9)
        love.graphics.rectangle('fill', statusX, y + padding, 38, 18, 3, 3)
        local statusFont = love.graphics.newFont(11)
        love.graphics.setFont(statusFont)
        love.graphics.setColor(0, 0, 0)
        local sw = statusFont:getWidth(statusData.label)
        love.graphics.print(statusData.label, statusX + (38 - sw) / 2, y + padding + 2)
    end
    
    -- Type badges
    local typeY = y + padding + 25
    for i, pType in ipairs(pokemon.types) do
        local typeColor = types.colors[pType] or {0.5, 0.5, 0.5}
        love.graphics.setColor(typeColor[1], typeColor[2], typeColor[3], 0.8)
        love.graphics.rectangle('fill', x + padding + (i-1) * 55, typeY, 50, 16, 3, 3)
        
        local typeFont = love.graphics.newFont(10)
        love.graphics.setFont(typeFont)
        love.graphics.setColor(1, 1, 1)
        local tw = typeFont:getWidth(pType)
        love.graphics.print(pType, x + padding + (i-1) * 55 + (50 - tw) / 2, typeY + 2)
    end
    
    -- Stat boost indicators (right of type badges)
    ui.drawStatBoosts(pokemon, x + padding + 115, typeY, width - padding - 125)
    
    -- HP Bar
    local hpBarY = y + height - 25
    local hpBarWidth = width - padding * 2 - 60
    
    love.graphics.setColor(0.15, 0.18, 0.22)
    love.graphics.rectangle('fill', x + padding, hpBarY, hpBarWidth, 16, 4, 4)
    
    local hpPct = pokemon.currentHP / pokemon.maxHP
    local hpColor = ui.getHPColor(pokemon.currentHP, pokemon.maxHP)
    love.graphics.setColor(hpColor)
    love.graphics.rectangle('fill', x + padding, hpBarY, hpBarWidth * hpPct, 16, 4, 4)
    
    -- HP Text
    love.graphics.setColor(ui.colors.text)
    local hpFont = love.graphics.newFont(12)
    love.graphics.setFont(hpFont)
    love.graphics.print(pokemon.currentHP .. "/" .. pokemon.maxHP, x + padding + hpBarWidth + 5, hpBarY + 1)
end

-- Draw stat boost indicators
function ui.drawStatBoosts(pokemon, x, y, maxWidth)
    if not pokemon.statBoosts then return end
    
    local statLabels = { "ATK", "DEF", "SPA", "SPD", "SPE" }
    local statKeys = { "atk", "def", "spa", "spd", "spe" }
    
    local boostFont = love.graphics.newFont(8)
    love.graphics.setFont(boostFont)
    
    local offsetX = 0
    local spacing = 28
    
    for i, key in ipairs(statKeys) do
        local boost = pokemon.statBoosts[key] or 0
        if boost ~= 0 then
            local label = statLabels[i]
            local color = boost > 0 and ui.colors.statBoost or ui.colors.statDrop
            local arrow = boost > 0 and "▲" or "▼"
            local absBoost = math.abs(boost)
            
            -- Draw stat indicator
            love.graphics.setColor(color[1], color[2], color[3], 0.9)
            love.graphics.rectangle('fill', x + offsetX, y, 26, 16, 2, 2)
            
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(label, x + offsetX + 2, y + 1)
            
            -- Draw arrows (stacked for multiple stages)
            love.graphics.setColor(color[1] * 0.7, color[2] * 0.7, color[3] * 0.7)
            local arrowText = absBoost > 2 and arrow .. absBoost or string.rep(arrow, math.min(absBoost, 2))
            love.graphics.print(arrowText, x + offsetX + 14, y + 1)
            
            offsetX = offsetX + spacing
            if offsetX > maxWidth - spacing then break end
        end
    end
end

-- Draw move button
function ui.drawMoveButton(move, x, y, width, height, isHovered, isDisabled)
    -- Background
    if isDisabled then
        love.graphics.setColor(0.1, 0.1, 0.12, 0.5)
    elseif isHovered then
        love.graphics.setColor(ui.colors.buttonHover)
    else
        love.graphics.setColor(ui.colors.buttonBg)
    end
    love.graphics.rectangle('fill', x, y, width, height, 6, 6)
    
    -- Border with type color
    local typeColor = types.colors[move.type] or ui.colors.buttonBorder
    if isHovered and not isDisabled then
        love.graphics.setColor(typeColor[1], typeColor[2], typeColor[3], 0.9)
        love.graphics.setLineWidth(3)
    else
        love.graphics.setColor(typeColor[1], typeColor[2], typeColor[3], 0.6)
        love.graphics.setLineWidth(2)
    end
    love.graphics.rectangle('line', x, y, width, height, 6, 6)
    
    -- Move name
    local nameFont = love.graphics.newFont(14)
    love.graphics.setFont(nameFont)
    love.graphics.setColor(isDisabled and {0.5, 0.5, 0.5} or ui.colors.text)
    love.graphics.print(move.name, x + 10, y + 8)
    
    -- PP
    local ppFont = love.graphics.newFont(11)
    love.graphics.setFont(ppFont)
    love.graphics.setColor(move.pp == 0 and ui.colors.hpRed or {0.6, 0.65, 0.7})
    love.graphics.print("PP: " .. move.pp .. "/" .. move.maxPP, x + 10, y + height - 18)
    
    -- Power
    if move.basePower > 0 then
        love.graphics.setColor(ui.colors.text[1], ui.colors.text[2], ui.colors.text[3], 0.6)
        love.graphics.print("Pwr: " .. move.basePower, x + width - 60, y + height - 18)
    end
    
    -- Type indicator
    love.graphics.setColor(typeColor)
    love.graphics.rectangle('fill', x + width - 55, y + 8, 45, 16, 3, 3)
    local typeFont = love.graphics.newFont(9)
    love.graphics.setFont(typeFont)
    love.graphics.setColor(1, 1, 1)
    local tw = typeFont:getWidth(move.type)
    love.graphics.print(move.type, x + width - 55 + (45 - tw) / 2, y + 10)
end

-- Draw action button
function ui.drawActionButton(btn, isHovered)
    if isHovered then
        love.graphics.setColor(ui.colors.buttonHover)
    else
        love.graphics.setColor(ui.colors.buttonBg)
    end
    love.graphics.rectangle('fill', btn.x, btn.y, btn.width, btn.height, 6, 6)
    
    love.graphics.setColor(isHovered and ui.colors.accent or ui.colors.buttonBorder)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', btn.x, btn.y, btn.width, btn.height, 6, 6)
    
    local font = love.graphics.newFont(16)
    love.graphics.setFont(font)
    love.graphics.setColor(ui.colors.text)
    local tw = font:getWidth(btn.label)
    love.graphics.print(btn.label, btn.x + (btn.width - tw) / 2, btn.y + (btn.height - font:getHeight()) / 2)
end

-- Draw team indicator dots
function ui.drawTeamBar(team, x, y, activeIndex)
    for i, pokemon in ipairs(team) do
        local dotX = x + (i - 1) * 25
        
        if pokemon.fainted then
            love.graphics.setColor(0.3, 0.15, 0.15)
        elseif i == activeIndex then
            love.graphics.setColor(ui.colors.accent)
        else
            love.graphics.setColor(ui.colors.hpGreen)
        end
        
        love.graphics.circle('fill', dotX, y, 8)
        love.graphics.setColor(0.2, 0.25, 0.3)
        love.graphics.setLineWidth(2)
        love.graphics.circle('line', dotX, y, 8)
    end
end

-- Draw a Pokemon sprite with background
function ui.drawPokemonSprite(pokemon, x, y, scale, options)
    scale = scale or 1
    options = options or {}
    
    -- Draw background circle
    local radius = 55 * scale
    local typeColor = types.colors[pokemon.types[1]] or {0.5, 0.5, 0.5}
    
    -- Outer glow
    love.graphics.setColor(typeColor[1], typeColor[2], typeColor[3], 0.2)
    love.graphics.circle('fill', x, y, radius + 5)
    
    -- Background
    love.graphics.setColor(0.1, 0.12, 0.16, 0.9)
    love.graphics.circle('fill', x, y, radius)
    
    -- Border
    love.graphics.setColor(typeColor[1], typeColor[2], typeColor[3], 0.7)
    love.graphics.setLineWidth(2)
    love.graphics.circle('line', x, y, radius)
    
    -- Draw sprite using spriteLoader
    spriteLoader.drawSprite(pokemon, x, y, scale, options)
end

-- Draw full Pokemon display (sprite + status)
function ui.drawPokemonDisplay(pokemon, x, y, isEnemy, scale)
    scale = scale or 1
    
    -- Sprite position
    local spriteX = x + 70 * scale
    local spriteY = y + 60 * scale
    
    ui.drawPokemonSprite(pokemon, spriteX, spriteY, scale, {back = not isEnemy})
    
    -- Status display
    local statusX = x + 140 * scale
    local statusWidth = 220 * scale
    ui.drawPokemonStatus(pokemon, statusX, y + 10 * scale, statusWidth)
end

-- Draw a Pokemon card for selection (draft/switch)
function ui.drawPokemonCard(pokemon, x, y, width, height, isHovered, isSelected)
    -- Background
    local typeColor = types.colors[pokemon.types[1]] or {0.5, 0.5, 0.5}
    
    if isSelected then
        love.graphics.setColor(typeColor[1] * 0.4, typeColor[2] * 0.4, typeColor[3] * 0.4, 0.95)
    elseif isHovered then
        love.graphics.setColor(0.15, 0.18, 0.24, 0.95)
    else
        love.graphics.setColor(0.1, 0.12, 0.16, 0.9)
    end
    love.graphics.rectangle('fill', x, y, width, height, 8, 8)
    
    -- Border
    if isSelected or isHovered then
        love.graphics.setColor(typeColor)
        love.graphics.setLineWidth(3)
    else
        love.graphics.setColor(typeColor[1], typeColor[2], typeColor[3], 0.5)
        love.graphics.setLineWidth(2)
    end
    love.graphics.rectangle('line', x, y, width, height, 8, 8)
    
    -- Sprite
    local spriteX = x + 50
    local spriteY = y + 55
    spriteLoader.drawSprite(pokemon, spriteX, spriteY, 0.8)
    
    -- Name
    local nameFont = love.graphics.newFont(16)
    love.graphics.setFont(nameFont)
    love.graphics.setColor(ui.colors.text)
    love.graphics.print(pokemon.name, x + 10, y + 100)
    
    -- Level
    local lvlFont = love.graphics.newFont(12)
    love.graphics.setFont(lvlFont)
    love.graphics.setColor(0.6, 0.65, 0.7)
    love.graphics.print("Lv." .. pokemon.level, x + width - 45, y + 10)
    
    -- Types
    local typeY = y + height - 30
    for i, pType in ipairs(pokemon.types) do
        local tc = types.colors[pType] or {0.5, 0.5, 0.5}
        love.graphics.setColor(tc[1], tc[2], tc[3], 0.8)
        love.graphics.rectangle('fill', x + 10 + (i-1) * 45, typeY, 42, 14, 3, 3)
        
        local tf = love.graphics.newFont(9)
        love.graphics.setFont(tf)
        love.graphics.setColor(1, 1, 1)
        local tw = tf:getWidth(pType)
        love.graphics.print(pType, x + 10 + (i-1) * 45 + (42 - tw) / 2, typeY + 2)
    end
    
    -- HP bar (if has currentHP)
    if pokemon.currentHP then
        local hpY = y + 120
        local hpWidth = width - 20
        love.graphics.setColor(0.15, 0.18, 0.22)
        love.graphics.rectangle('fill', x + 10, hpY, hpWidth, 8, 2, 2)
        
        local hpPct = pokemon.currentHP / pokemon.maxHP
        local hpColor = ui.getHPColor(pokemon.currentHP, pokemon.maxHP)
        love.graphics.setColor(hpColor)
        love.graphics.rectangle('fill', x + 10, hpY, hpWidth * hpPct, 8, 2, 2)
    end
end

-- Draw battle log
function ui.drawBattleLog(log, x, y, width, height)
    love.graphics.setColor(ui.colors.panelBg)
    love.graphics.rectangle('fill', x, y, width, height, 6, 6)
    love.graphics.setColor(ui.colors.buttonBorder[1], ui.colors.buttonBorder[2], ui.colors.buttonBorder[3], 0.5)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle('line', x, y, width, height, 6, 6)
    
    love.graphics.setScissor(x, y, width, height)
    
    local font = love.graphics.newFont(12)
    love.graphics.setFont(font)
    local lineHeight = 16
    local padding = 8
    
    local maxLines = math.floor((height - padding * 2) / lineHeight)
    local startIdx = math.max(1, #log - maxLines + 1)
    
    for i = startIdx, #log do
        local lineY = y + padding + (i - startIdx) * lineHeight
        love.graphics.setColor(ui.colors.text[1], ui.colors.text[2], ui.colors.text[3], 0.8)
        love.graphics.print(log[i], x + padding, lineY)
    end
    
    love.graphics.setScissor()
end

return ui

