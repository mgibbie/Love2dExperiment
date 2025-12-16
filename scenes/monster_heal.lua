-- Monster Heal Scene
-- Between battle healing and progression

local battleState = require('data.monster.battleState')
local types = require('data.monster.types')
local spriteLoader = require('data.monster.spriteLoader')

local heal = {}

-- Colors
local colors = {
    background = {0.05, 0.08, 0.12},
    backgroundGrad = {0.08, 0.12, 0.18},
    title = {0.4, 0.8, 1.0},
    text = {0.85, 0.9, 0.95},
    accent = {0.3, 0.7, 0.95},
    hpGreen = {0.3, 0.8, 0.4},
    panelBg = {0.1, 0.14, 0.2},
    buttonBg = {0.12, 0.16, 0.22},
    buttonHover = {0.18, 0.24, 0.32},
    buttonBorder = {0.3, 0.5, 0.7}
}

local continueButton = { x = 0, y = 0, width = 250, height = 55, hovered = false }
local healAnimation = 0

function heal.load() end

function heal.enter()
    healAnimation = 0
    
    -- Heal the player's team
    local playerTeam = _G.monsterPlayerTeam
    if playerTeam then
        battleState.healTeam(playerTeam)
    end
end

function heal.exit() end

function heal.update(dt)
    healAnimation = healAnimation + dt
    
    local w, h = love.graphics.getDimensions()
    continueButton.x = (w - continueButton.width) / 2
    continueButton.y = h - 120
end

function heal.draw()
    local w, h = love.graphics.getDimensions()
    local playerTeam = _G.monsterPlayerTeam
    local battleNum = _G.monsterBattleNumber or 1
    
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
    local titleFont = love.graphics.newFont(36)
    love.graphics.setFont(titleFont)
    love.graphics.setColor(colors.title)
    local titleText = "Victory!"
    local titleWidth = titleFont:getWidth(titleText)
    love.graphics.print(titleText, (w - titleWidth) / 2, 40)
    
    -- Progress text
    local progressFont = love.graphics.newFont(20)
    love.graphics.setFont(progressFont)
    love.graphics.setColor(colors.text[1], colors.text[2], colors.text[3], 0.7)
    local progressText = "Battle " .. (battleNum - 1) .. " complete! " .. (10 - battleNum + 1) .. " battles remaining."
    local progressWidth = progressFont:getWidth(progressText)
    love.graphics.print(progressText, (w - progressWidth) / 2, 90)
    
    -- Heal message
    local glowIntensity = (math.sin(healAnimation * 3) + 1) / 2 * 0.5 + 0.5
    love.graphics.setColor(colors.hpGreen[1], colors.hpGreen[2], colors.hpGreen[3], glowIntensity)
    local healFont = love.graphics.newFont(24)
    love.graphics.setFont(healFont)
    local healText = "Your team has been fully healed!"
    local healWidth = healFont:getWidth(healText)
    love.graphics.print(healText, (w - healWidth) / 2, 130)
    
    -- Team display
    if playerTeam then
        local cardWidth = 160
        local cardHeight = 220
        local spacing = 15
        local totalWidth = #playerTeam * cardWidth + (#playerTeam - 1) * spacing
        local startX = (w - totalWidth) / 2
        local cardY = 180
        
        for i, pokemon in ipairs(playerTeam) do
            local cardX = startX + (i - 1) * (cardWidth + spacing)
            
            -- Card background
            love.graphics.setColor(colors.panelBg)
            love.graphics.rectangle('fill', cardX, cardY, cardWidth, cardHeight, 8, 8)
            
            -- Type-colored border
            local typeColor = types.colors[pokemon.types[1]] or {0.5, 0.5, 0.5}
            love.graphics.setColor(typeColor[1], typeColor[2], typeColor[3], 0.7)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle('line', cardX, cardY, cardWidth, cardHeight, 8, 8)
            
            -- Sprite area
            local spriteCenterX = cardX + cardWidth / 2
            local spriteCenterY = cardY + 50
            
            -- Healing glow effect
            local glowIntensity = (math.sin(healAnimation * 4 + i * 0.5) + 1) / 2 * 0.4 + 0.2
            love.graphics.setColor(colors.hpGreen[1], colors.hpGreen[2], colors.hpGreen[3], glowIntensity)
            love.graphics.circle('fill', spriteCenterX, spriteCenterY, 35)
            
            -- Sprite background
            love.graphics.setColor(typeColor[1] * 0.3, typeColor[2] * 0.3, typeColor[3] * 0.3, 0.5)
            love.graphics.circle('fill', spriteCenterX, spriteCenterY, 32)
            
            -- Draw sprite
            spriteLoader.drawSprite(pokemon, spriteCenterX, spriteCenterY, 1.0, {maxSize = 55})
            
            -- Pokemon name
            local nameFont = love.graphics.newFont(13)
            love.graphics.setFont(nameFont)
            love.graphics.setColor(colors.text)
            local name = pokemon.name
            if #name > 12 then name = string.sub(name, 1, 11) .. "." end
            local nameWidth = nameFont:getWidth(name)
            love.graphics.print(name, cardX + (cardWidth - nameWidth) / 2, cardY + 88)
            
            -- Level
            love.graphics.setColor(colors.text[1], colors.text[2], colors.text[3], 0.6)
            local lvlFont = love.graphics.newFont(10)
            love.graphics.setFont(lvlFont)
            love.graphics.print("Lv." .. pokemon.level, cardX + cardWidth - 40, cardY + 8)
            
            -- Type badges
            local typeTotalWidth = #pokemon.types * 50 + (#pokemon.types - 1) * 5
            local typeStartX = cardX + (cardWidth - typeTotalWidth) / 2
            for j, pType in ipairs(pokemon.types) do
                local tc = types.colors[pType] or {0.5, 0.5, 0.5}
                love.graphics.setColor(tc[1], tc[2], tc[3], 0.8)
                love.graphics.rectangle('fill', typeStartX + (j-1) * 55, cardY + 105, 50, 16, 3, 3)
                
                local typeFont = love.graphics.newFont(9)
                love.graphics.setFont(typeFont)
                love.graphics.setColor(1, 1, 1)
                local tw = typeFont:getWidth(pType)
                love.graphics.print(pType, typeStartX + (j-1) * 55 + (50 - tw) / 2, cardY + 107)
            end
            
            -- HP Bar (full with animation)
            local hpBarY = cardY + 128
            love.graphics.setColor(0.15, 0.18, 0.22)
            love.graphics.rectangle('fill', cardX + 10, hpBarY, cardWidth - 20, 12, 3, 3)
            
            local hpFill = math.min(1, healAnimation / 0.5)
            love.graphics.setColor(colors.hpGreen)
            love.graphics.rectangle('fill', cardX + 10, hpBarY, (cardWidth - 20) * hpFill, 12, 3, 3)
            
            -- HP text
            love.graphics.setColor(colors.text)
            local hpFont = love.graphics.newFont(9)
            love.graphics.setFont(hpFont)
            local hpText = pokemon.currentHP .. "/" .. pokemon.maxHP
            local hpTextWidth = hpFont:getWidth(hpText)
            love.graphics.print(hpText, cardX + (cardWidth - hpTextWidth) / 2, hpBarY + 1)
            
            -- Moves (compact)
            local moveY = cardY + 148
            local moveFont = love.graphics.newFont(8)
            love.graphics.setFont(moveFont)
            for mi, move in ipairs(pokemon.moves) do
                local moveTypeColor = types.colors[move.type] or {0.5, 0.5, 0.5}
                love.graphics.setColor(moveTypeColor[1], moveTypeColor[2], moveTypeColor[3], 0.6)
                love.graphics.circle('fill', cardX + 12, moveY + (mi - 1) * 14 + 4, 3)
                
                love.graphics.setColor(colors.text[1], colors.text[2], colors.text[3], 0.7)
                local moveName = move.name
                if #moveName > 14 then moveName = string.sub(moveName, 1, 12) .. ".." end
                love.graphics.print(moveName, cardX + 20, moveY + (mi - 1) * 14)
            end
        end
    end
    
    -- Continue button
    if continueButton.hovered then
        love.graphics.setColor(colors.buttonHover)
    else
        love.graphics.setColor(colors.buttonBg)
    end
    love.graphics.rectangle('fill', continueButton.x, continueButton.y, continueButton.width, continueButton.height, 8, 8)
    
    love.graphics.setColor(continueButton.hovered and colors.accent or colors.buttonBorder)
    love.graphics.setLineWidth(continueButton.hovered and 3 or 2)
    love.graphics.rectangle('line', continueButton.x, continueButton.y, continueButton.width, continueButton.height, 8, 8)
    
    local btnFont = love.graphics.newFont(20)
    love.graphics.setFont(btnFont)
    love.graphics.setColor(colors.text)
    local btnText = "Continue to Battle " .. battleNum
    local btnTextWidth = btnFont:getWidth(btnText)
    love.graphics.print(btnText, continueButton.x + (continueButton.width - btnTextWidth) / 2, continueButton.y + 15)
end

function heal.mousemoved(x, y)
    continueButton.hovered = x >= continueButton.x and x <= continueButton.x + continueButton.width and
                             y >= continueButton.y and y <= continueButton.y + continueButton.height
end

function heal.mousepressed(x, y, button) end

function heal.mousereleased(x, y, button)
    if button == 1 and continueButton.hovered then
        switchScene("monster_battle")
    end
end

function heal.keypressed(key)
    if key == "return" or key == "space" then
        switchScene("monster_battle")
    elseif key == "escape" then
        switchScene("monster_menu")
    end
end

function heal.resize() end

return heal

