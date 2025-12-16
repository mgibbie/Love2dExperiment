-- Splash Screen Scene

local splash = {}

-- Button state
local startButton = {
    x = 0,
    y = 0,
    width = 280,
    height = 60,
    hovered = false,
    pressed = false
}

-- Animation state
local titleGlow = 0
local particleTime = 0

-- Colors (magepunk aesthetic - deep purples, electric cyan, copper accents)
local colors = {
    background = {0.05, 0.02, 0.08},
    backgroundGrad = {0.12, 0.04, 0.18},
    title = {0.95, 0.85, 0.6},
    titleGlow = {0.4, 0.9, 1.0},
    buttonBg = {0.15, 0.08, 0.2},
    buttonBorder = {0.7, 0.4, 0.2},
    buttonHover = {0.25, 0.12, 0.35},
    buttonText = {0.95, 0.9, 0.8},
    accent = {0.3, 0.85, 0.9}
}

-- Particles for atmosphere
local particles = {}

local function createParticle()
    return {
        x = math.random() * love.graphics.getWidth(),
        y = math.random() * love.graphics.getHeight(),
        size = math.random() * 3 + 1,
        speed = math.random() * 20 + 10,
        alpha = math.random() * 0.4 + 0.1,
        drift = (math.random() - 0.5) * 30
    }
end

local function drawButton()
    local btn = startButton
    
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
    local buttonFont = love.graphics.newFont(28)
    love.graphics.setFont(buttonFont)
    local buttonText = "Start Game"
    local textWidth = buttonFont:getWidth(buttonText)
    local textHeight = buttonFont:getHeight()
    
    if btn.hovered then
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.setColor(colors.buttonText[1], colors.buttonText[2], colors.buttonText[3])
    end
    
    love.graphics.print(buttonText, 
        btn.x + (btn.width - textWidth) / 2, 
        btn.y + (btn.height - textHeight) / 2)
end

function splash.load()
    -- Create initial particles
    for i = 1, 50 do
        table.insert(particles, createParticle())
    end
end

function splash.enter()
    titleGlow = 0
end

function splash.exit()
    -- Cleanup if needed
end

function splash.update(dt)
    -- Animate title glow
    titleGlow = titleGlow + dt
    
    -- Update particle time
    particleTime = particleTime + dt
    
    -- Update particles
    for i, p in ipairs(particles) do
        p.y = p.y - p.speed * dt
        p.x = p.x + p.drift * dt
        
        -- Reset particle when it goes off screen
        if p.y < -10 then
            p.y = love.graphics.getHeight() + 10
            p.x = math.random() * love.graphics.getWidth()
        end
        if p.x < -10 or p.x > love.graphics.getWidth() + 10 then
            p.x = math.random() * love.graphics.getWidth()
        end
    end
    
    -- Update button position (centered)
    local w, h = love.graphics.getDimensions()
    startButton.x = (w - startButton.width) / 2
    startButton.y = h / 2 + 80
end

function splash.draw()
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
    
    -- Draw particles
    for _, p in ipairs(particles) do
        love.graphics.setColor(colors.accent[1], colors.accent[2], colors.accent[3], p.alpha)
        love.graphics.circle("fill", p.x, p.y, p.size)
    end
    
    -- Draw title with glow effect
    local titleY = h / 2 - 100
    local glowIntensity = (math.sin(titleGlow * 2) + 1) / 2 * 0.3 + 0.2
    
    -- Glow layers
    love.graphics.setColor(colors.titleGlow[1], colors.titleGlow[2], colors.titleGlow[3], glowIntensity * 0.3)
    local titleFont = love.graphics.newFont(64)
    love.graphics.setFont(titleFont)
    local titleText = "Magepunk Experimental"
    local titleWidth = titleFont:getWidth(titleText)
    
    -- Draw glow shadows
    for offset = 8, 2, -2 do
        love.graphics.setColor(colors.titleGlow[1], colors.titleGlow[2], colors.titleGlow[3], glowIntensity * 0.1)
        love.graphics.print(titleText, (w - titleWidth) / 2 + offset, titleY)
        love.graphics.print(titleText, (w - titleWidth) / 2 - offset, titleY)
        love.graphics.print(titleText, (w - titleWidth) / 2, titleY + offset)
        love.graphics.print(titleText, (w - titleWidth) / 2, titleY - offset)
    end
    
    -- Main title
    love.graphics.setColor(colors.title[1], colors.title[2], colors.title[3])
    love.graphics.print(titleText, (w - titleWidth) / 2, titleY)
    
    -- Draw decorative line under title
    local lineY = titleY + 80
    local lineWidth = 400
    local lineX = (w - lineWidth) / 2
    
    love.graphics.setColor(colors.buttonBorder[1], colors.buttonBorder[2], colors.buttonBorder[3], 0.6)
    love.graphics.setLineWidth(2)
    love.graphics.line(lineX, lineY, lineX + lineWidth, lineY)
    
    -- Decorative endpoints
    love.graphics.circle("fill", lineX, lineY, 4)
    love.graphics.circle("fill", lineX + lineWidth, lineY, 4)
    
    -- Draw Start Game button
    drawButton()
end

function splash.mousemoved(x, y, dx, dy)
    -- Check button hover
    local btn = startButton
    btn.hovered = x >= btn.x and x <= btn.x + btn.width and
                  y >= btn.y and y <= btn.y + btn.height
end

function splash.mousepressed(x, y, button)
    if button == 1 then
        local btn = startButton
        if btn.hovered then
            btn.pressed = true
        end
    end
end

function splash.mousereleased(x, y, button)
    if button == 1 then
        local btn = startButton
        if btn.pressed and btn.hovered then
            -- Switch to game scene
            switchScene("game")
        end
        btn.pressed = false
    end
end

function splash.keypressed(key)
    if key == "return" or key == "space" then
        switchScene("game")
    end
end

function splash.resize(w, h)
    -- Button position will be updated in update()
end

return splash

