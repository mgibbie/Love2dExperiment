-- Monster Battle Menu Scene
-- Entry point for the Monster Battle game mode

local menu = {}

-- Colors
local colors = {
    background = {0.05, 0.08, 0.12},
    backgroundGrad = {0.08, 0.12, 0.18},
    title = {0.4, 0.8, 1.0},
    titleGlow = {0.2, 0.6, 0.9},
    text = {0.85, 0.9, 0.95},
    accent = {0.3, 0.7, 0.95},
    buttonBg = {0.1, 0.15, 0.22},
    buttonBorder = {0.3, 0.5, 0.7},
    buttonHover = {0.15, 0.22, 0.32}
}

-- Buttons
local buttons = {
    startRun = { x = 0, y = 0, width = 300, height = 60, hovered = false, pressed = false, label = "Start New Run" },
    back = { x = 0, y = 0, width = 300, height = 50, hovered = false, pressed = false, label = "Back" }
}

local titleGlow = 0

local function drawButton(btn)
    if btn.pressed then
        love.graphics.setColor(0.05, 0.08, 0.12)
    elseif btn.hovered then
        love.graphics.setColor(colors.buttonHover[1], colors.buttonHover[2], colors.buttonHover[3])
    else
        love.graphics.setColor(colors.buttonBg[1], colors.buttonBg[2], colors.buttonBg[3])
    end
    love.graphics.rectangle("fill", btn.x, btn.y, btn.width, btn.height, 8, 8)
    
    if btn.hovered then
        love.graphics.setColor(colors.accent[1], colors.accent[2], colors.accent[3], 0.9)
        love.graphics.setLineWidth(3)
    else
        love.graphics.setColor(colors.buttonBorder[1], colors.buttonBorder[2], colors.buttonBorder[3])
        love.graphics.setLineWidth(2)
    end
    love.graphics.rectangle("line", btn.x, btn.y, btn.width, btn.height, 8, 8)
    
    local font = love.graphics.newFont(btn == buttons.back and 20 or 24)
    love.graphics.setFont(font)
    local tw = font:getWidth(btn.label)
    love.graphics.setColor(btn.hovered and {1, 1, 1} or colors.text)
    love.graphics.print(btn.label, btn.x + (btn.width - tw) / 2, btn.y + (btn.height - font:getHeight()) / 2)
end

function menu.load() end

function menu.enter()
    titleGlow = 0
end

function menu.exit() end

function menu.update(dt)
    titleGlow = titleGlow + dt
    
    local w, h = love.graphics.getDimensions()
    local centerX = w / 2
    
    buttons.startRun.x = centerX - buttons.startRun.width / 2
    buttons.startRun.y = h / 2 + 20
    
    buttons.back.x = centerX - buttons.back.width / 2
    buttons.back.y = h / 2 + 100
end

function menu.draw()
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
    
    -- Title with glow
    local titleY = h / 2 - 150
    local glowIntensity = (math.sin(titleGlow * 2) + 1) / 2 * 0.3 + 0.2
    
    local titleFont = love.graphics.newFont(48)
    love.graphics.setFont(titleFont)
    local titleText = "Monster Battle"
    local titleWidth = titleFont:getWidth(titleText)
    
    -- Glow effect
    for offset = 6, 2, -2 do
        love.graphics.setColor(colors.titleGlow[1], colors.titleGlow[2], colors.titleGlow[3], glowIntensity * 0.15)
        love.graphics.print(titleText, (w - titleWidth) / 2 + offset, titleY)
        love.graphics.print(titleText, (w - titleWidth) / 2 - offset, titleY)
        love.graphics.print(titleText, (w - titleWidth) / 2, titleY + offset)
        love.graphics.print(titleText, (w - titleWidth) / 2, titleY - offset)
    end
    
    love.graphics.setColor(colors.title)
    love.graphics.print(titleText, (w - titleWidth) / 2, titleY)
    
    -- Subtitle
    local subFont = love.graphics.newFont(18)
    love.graphics.setFont(subFont)
    love.graphics.setColor(colors.text[1], colors.text[2], colors.text[3], 0.7)
    local subText = "Draft your team and battle through 10 rounds!"
    local subWidth = subFont:getWidth(subText)
    love.graphics.print(subText, (w - subWidth) / 2, titleY + 60)
    
    -- Info text
    love.graphics.setColor(colors.text[1], colors.text[2], colors.text[3], 0.5)
    local infoFont = love.graphics.newFont(14)
    love.graphics.setFont(infoFont)
    local infoText = "1000+ Pokemon • Random abilities & movesets • Type-based combat"
    local infoWidth = infoFont:getWidth(infoText)
    love.graphics.print(infoText, (w - infoWidth) / 2, titleY + 90)
    
    -- Buttons
    drawButton(buttons.startRun)
    drawButton(buttons.back)
end

function menu.mousemoved(x, y)
    for _, btn in pairs(buttons) do
        btn.hovered = x >= btn.x and x <= btn.x + btn.width and y >= btn.y and y <= btn.y + btn.height
    end
end

function menu.mousepressed(x, y, button)
    if button == 1 then
        for _, btn in pairs(buttons) do
            if btn.hovered then btn.pressed = true end
        end
    end
end

function menu.mousereleased(x, y, button)
    if button == 1 then
        if buttons.startRun.pressed and buttons.startRun.hovered then
            switchScene("monster_draft")
        end
        if buttons.back.pressed and buttons.back.hovered then
            switchScene("game")
        end
        
        for _, btn in pairs(buttons) do
            btn.pressed = false
        end
    end
end

function menu.keypressed(key)
    if key == "escape" then
        switchScene("game")
    end
end

function menu.resize() end

return menu

