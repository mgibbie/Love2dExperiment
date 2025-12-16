-- Game Scene (Hub)

local game = {}

-- Button state
local battlecardsButton = {
    x = 0, y = 0, width = 280, height = 60, hovered = false, pressed = false
}

local monsterBattleButton = {
    x = 0, y = 0, width = 280, height = 60, hovered = false, pressed = false
}

local micatroButton = {
    x = 0, y = 0, width = 280, height = 60, hovered = false, pressed = false
}

-- Colors matching splash screen aesthetic
local colors = {
    background = {0.08, 0.04, 0.12},
    backgroundGrad = {0.12, 0.06, 0.18},
    text = {0.9, 0.85, 0.75},
    accent = {0.3, 0.85, 0.9},
    buttonBg = {0.15, 0.08, 0.2},
    buttonBorder = {0.7, 0.4, 0.2},
    buttonHover = {0.25, 0.12, 0.35},
    buttonText = {0.95, 0.9, 0.8},
    title = {0.95, 0.85, 0.6}
}

local function drawButton(btn, text)
    -- Button background
    if btn.pressed then
        love.graphics.setColor(0.1, 0.05, 0.15)
    elseif btn.hovered then
        love.graphics.setColor(colors.buttonHover[1], colors.buttonHover[2], colors.buttonHover[3])
    else
        love.graphics.setColor(colors.buttonBg[1], colors.buttonBg[2], colors.buttonBg[3])
    end
    
    -- Rounded rectangle for button
    love.graphics.rectangle("fill", btn.x, btn.y, btn.width, btn.height, 8, 8)
    
    -- Button border with glow when hovered
    if btn.hovered then
        love.graphics.setColor(colors.accent[1], colors.accent[2], colors.accent[3], 0.8)
        love.graphics.setLineWidth(3)
    else
        love.graphics.setColor(colors.buttonBorder[1], colors.buttonBorder[2], colors.buttonBorder[3])
        love.graphics.setLineWidth(2)
    end
    love.graphics.rectangle("line", btn.x, btn.y, btn.width, btn.height, 8, 8)
    
    -- Button text
    local buttonFont = love.graphics.newFont(24)
    love.graphics.setFont(buttonFont)
    local textWidth = buttonFont:getWidth(text)
    local textHeight = buttonFont:getHeight()
    
    if btn.hovered then
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.setColor(colors.buttonText[1], colors.buttonText[2], colors.buttonText[3])
    end
    
    love.graphics.print(text, 
        btn.x + (btn.width - textWidth) / 2, 
        btn.y + (btn.height - textHeight) / 2)
end

function game.load()
    -- Initialize game resources here
end

function game.enter()
    -- Called when entering the game scene
end

function game.exit()
    -- Called when leaving the game scene
end

function game.update(dt)
    -- Update button positions (centered, stacked)
    local w, h = love.graphics.getDimensions()
    battlecardsButton.x = (w - battlecardsButton.width) / 2
    battlecardsButton.y = h / 2 - 50
    monsterBattleButton.x = (w - monsterBattleButton.width) / 2
    monsterBattleButton.y = h / 2 + 30
    micatroButton.x = (w - micatroButton.width) / 2
    micatroButton.y = h / 2 + 110
end

function game.draw()
    local w, h = love.graphics.getDimensions()
    
    -- Draw gradient background
    for i = 0, h do
        local t = i / h
        local r = colors.background[1] + (colors.backgroundGrad[1] - colors.background[1]) * t
        local g = colors.background[2] + (colors.backgroundGrad[2] - colors.background[2]) * t
        local b = colors.background[3] + (colors.backgroundGrad[3] - colors.background[3]) * t
        love.graphics.setColor(r, g, b)
        love.graphics.line(0, i, w, i)
    end
    
    -- Draw title
    love.graphics.setColor(colors.title[1], colors.title[2], colors.title[3])
    local titleFont = love.graphics.newFont(48)
    love.graphics.setFont(titleFont)
    local titleText = "Game Hub"
    local titleWidth = titleFont:getWidth(titleText)
    love.graphics.print(titleText, (w - titleWidth) / 2, h / 2 - 130)
    
    -- Draw Battle Cards button
    drawButton(battlecardsButton, "Battle Cards")
    
    -- Draw Monster Battle button
    drawButton(monsterBattleButton, "Monster Battle")
    
    -- Draw Micatro button
    drawButton(micatroButton, "Micatro")
    
    -- Instructions at bottom
    love.graphics.setColor(colors.accent[1], colors.accent[2], colors.accent[3], 0.5)
    local smallFont = love.graphics.newFont(14)
    love.graphics.setFont(smallFont)
    local helpText = "Press ESC to return to menu"
    local helpWidth = smallFont:getWidth(helpText)
    love.graphics.print(helpText, (w - helpWidth) / 2, h - 50)
end

function game.mousemoved(x, y, dx, dy)
    -- Check button hover
    battlecardsButton.hovered = x >= battlecardsButton.x and x <= battlecardsButton.x + battlecardsButton.width and
                                y >= battlecardsButton.y and y <= battlecardsButton.y + battlecardsButton.height
    monsterBattleButton.hovered = x >= monsterBattleButton.x and x <= monsterBattleButton.x + monsterBattleButton.width and
                                  y >= monsterBattleButton.y and y <= monsterBattleButton.y + monsterBattleButton.height
    micatroButton.hovered = x >= micatroButton.x and x <= micatroButton.x + micatroButton.width and
                            y >= micatroButton.y and y <= micatroButton.y + micatroButton.height
end

function game.mousepressed(x, y, button)
    if button == 1 then
        if battlecardsButton.hovered then battlecardsButton.pressed = true end
        if monsterBattleButton.hovered then monsterBattleButton.pressed = true end
        if micatroButton.hovered then micatroButton.pressed = true end
    end
end

function game.mousereleased(x, y, button)
    if button == 1 then
        if battlecardsButton.pressed and battlecardsButton.hovered then
            switchScene("battlecards_menu")
        end
        if monsterBattleButton.pressed and monsterBattleButton.hovered then
            switchScene("monster_menu")
        end
        if micatroButton.pressed and micatroButton.hovered then
            switchScene("micatro")
        end
        battlecardsButton.pressed = false
        monsterBattleButton.pressed = false
        micatroButton.pressed = false
    end
end

function game.keypressed(key)
    if key == "escape" then
        switchScene("splash")
    end
end

function game.resize(w, h)
    -- Button position will be updated in update()
end

return game
