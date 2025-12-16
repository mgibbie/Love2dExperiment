-- Battlecards Menu Scene
-- Hub for all battlecards game modes

local menu = {}

-- Colors (matching battlecards aesthetic)
local colors = {
    background = {0.05, 0.02, 0.08},
    backgroundGrad = {0.1, 0.04, 0.14},
    title = {0.95, 0.85, 0.6},
    titleGlow = {0.9, 0.6, 0.3},
    text = {0.9, 0.85, 0.75},
    accent = {0.9, 0.6, 0.3},
    buttonBg = {0.15, 0.08, 0.12},
    buttonBorder = {0.7, 0.4, 0.2},
    buttonHover = {0.25, 0.12, 0.18},
    buttonText = {0.95, 0.9, 0.8}
}

-- Buttons
local buttons = {
    battle = { x = 0, y = 0, width = 280, height = 55, hovered = false, pressed = false, label = "Start Battle", scene = "battlecards" },
    deckEditor = { x = 0, y = 0, width = 280, height = 55, hovered = false, pressed = false, label = "Deck Editor", scene = "deck_editor" },
    collection = { x = 0, y = 0, width = 280, height = 55, hovered = false, pressed = false, label = "Collection", scene = "collection" },
    back = { x = 0, y = 0, width = 280, height = 45, hovered = false, pressed = false, label = "Back", scene = "game" }
}

local titleGlow = 0

local function drawButton(btn)
    if btn.pressed then
        love.graphics.setColor(0.08, 0.04, 0.08)
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
    
    local font = love.graphics.newFont(btn == buttons.back and 18 or 22)
    love.graphics.setFont(font)
    local tw = font:getWidth(btn.label)
    love.graphics.setColor(btn.hovered and {1, 1, 1} or colors.buttonText)
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
    local startY = h / 2 - 60
    local spacing = 65
    
    buttons.battle.x = centerX - buttons.battle.width / 2
    buttons.battle.y = startY
    
    buttons.deckEditor.x = centerX - buttons.deckEditor.width / 2
    buttons.deckEditor.y = startY + spacing
    
    buttons.collection.x = centerX - buttons.collection.width / 2
    buttons.collection.y = startY + spacing * 2
    
    buttons.back.x = centerX - buttons.back.width / 2
    buttons.back.y = startY + spacing * 3 + 20
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
    local titleY = h / 2 - 180
    local glowIntensity = (math.sin(titleGlow * 2) + 1) / 2 * 0.3 + 0.2
    
    local titleFont = love.graphics.newFont(52)
    love.graphics.setFont(titleFont)
    local titleText = "Battle Cards"
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
    local subFont = love.graphics.newFont(16)
    love.graphics.setFont(subFont)
    love.graphics.setColor(colors.text[1], colors.text[2], colors.text[3], 0.6)
    local subText = "Roguelike Deckbuilder Card Game"
    local subWidth = subFont:getWidth(subText)
    love.graphics.print(subText, (w - subWidth) / 2, titleY + 60)
    
    -- Decorative line
    love.graphics.setColor(colors.buttonBorder[1], colors.buttonBorder[2], colors.buttonBorder[3], 0.5)
    love.graphics.setLineWidth(2)
    local lineW = 300
    love.graphics.line((w - lineW) / 2, titleY + 95, (w + lineW) / 2, titleY + 95)
    
    -- Draw buttons
    drawButton(buttons.battle)
    drawButton(buttons.deckEditor)
    drawButton(buttons.collection)
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
        for _, btn in pairs(buttons) do
            if btn.pressed and btn.hovered then
                switchScene(btn.scene)
            end
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

