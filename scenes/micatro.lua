-- Micatro Scene
-- Balatro-style visual demo with psychedelic background and holographic cards

local micatro = {}

-- Shaders
local bgShader = nil
local shaders = {
    none = nil,
    polychrome = nil,
    holographic = nil,
    foil = nil,
    negative = nil
}

-- Textures
local jokerTexture = nil
local dummyTexture = nil  -- Full-screen quad for background

-- Time
local elapsedTime = 0

-- Card effect names for labels
local effectNames = {"Normal", "Polychrome", "Holographic", "Foil", "Negative"}
local effectKeys = {"none", "polychrome", "holographic", "foil", "negative"}

-- Cards array
local cards = {}
local cardWidth = 146
local cardHeight = 194
local cardSpacing = 30

-- Lerp helper
local function lerp(a, b, t)
    return a + (b - a) * t
end

-- Damp helper (smooth lerp with delta time)
local function damp(current, target, smoothing, dt)
    return lerp(current, target, 1 - math.exp(-smoothing * dt))
end

-- Safe shader uniform send (won't crash if uniform doesn't exist)
local function safeSend(shader, name, value)
    if shader then
        pcall(shader.send, shader, name, value)
    end
end

-- Create a card object
local function createCard(index, effectKey)
    return {
        index = index,
        effectKey = effectKey,
        x = 0,
        y = 0,
        baseX = 0,
        baseY = 0,
        rotation = 0,
        rotationX = 0,
        rotationY = 0,
        scale = 1,
        targetScale = 1,
        hovered = false,
        dragging = false,
        dragOffsetX = 0,
        dragOffsetY = 0,
        velocityX = 0,
        velocityY = 0,
        prevX = 0,
        prevY = 0,
        shakeTime = 0,
        shakeActive = false
    }
end

-- Check if point is inside a card
local function isInsideCard(card, px, py)
    local halfW = cardWidth * card.scale / 2
    local halfH = cardHeight * card.scale / 2
    return px >= card.x - halfW and px <= card.x + halfW and
           py >= card.y - halfH and py <= card.y + halfH
end

-- Load a shader safely
local function loadShader(path)
    local code = love.filesystem.read(path)
    if code then
        local success, shader = pcall(love.graphics.newShader, code)
        if success then
            return shader
        else
            print("Failed to compile shader " .. path .. ":", shader)
        end
    end
    return nil
end

function micatro.load()
    -- Load background shader
    bgShader = loadShader("shaders/balatro_bg.glsl")
    
    -- Load card shaders
    shaders.polychrome = loadShader("shaders/polychrome.glsl")
    shaders.holographic = loadShader("shaders/holographic.glsl")
    shaders.foil = loadShader("shaders/foil.glsl")
    shaders.negative = loadShader("shaders/negative.glsl")
    
    -- Load joker texture
    local jokerPath = "assets/joker.png"
    if love.filesystem.getInfo(jokerPath) then
        local success, texture = pcall(love.graphics.newImage, jokerPath)
        if success then
            jokerTexture = texture
            jokerTexture:setFilter("linear", "linear")
            -- Update card dimensions based on scaled texture size
            local targetHeight = 200
            local imgScale = targetHeight / jokerTexture:getHeight()
            cardWidth = jokerTexture:getWidth() * imgScale
            cardHeight = targetHeight
        else
            print("Failed to load joker texture:", texture)
        end
    else
        print("Joker texture not found at:", jokerPath)
    end
    
    -- Create a 1x1 white pixel for the background quad
    local imageData = love.image.newImageData(1, 1)
    imageData:setPixel(0, 0, 1, 1, 1, 1)
    dummyTexture = love.graphics.newImage(imageData)
    
    -- Create 5 cards with different effects
    for i = 1, 5 do
        cards[i] = createCard(i, effectKeys[i])
    end
end

function micatro.enter()
    elapsedTime = 0
    
    -- Position cards in a row
    local w, h = love.graphics.getDimensions()
    local totalWidth = 5 * cardWidth + 4 * cardSpacing
    local startX = (w - totalWidth) / 2 + cardWidth / 2
    local centerY = h / 2
    
    for i, card in ipairs(cards) do
        card.x = startX + (i - 1) * (cardWidth + cardSpacing)
        card.y = centerY
        card.baseX = card.x
        card.baseY = card.y
        card.prevX = card.x
        card.prevY = card.y
        card.scale = 1
        card.targetScale = 1
        card.rotation = 0
        card.rotationX = 0
        card.rotationY = 0
        card.hovered = false
        card.dragging = false
        card.shakeActive = false
        card.shakeTime = 0
    end
end

function micatro.exit()
    -- Cleanup if needed
end

function micatro.update(dt)
    elapsedTime = elapsedTime + dt
    
    -- Update background shader
    if bgShader then
        safeSend(bgShader, "iTime", elapsedTime)
        local w, h = love.graphics.getDimensions()
        safeSend(bgShader, "iResolution", {w, h})
    end
    
    -- Update each card
    for _, card in ipairs(cards) do
        -- Update shader uniforms for this card's effect
        local shader = shaders[card.effectKey]
        if shader then
            safeSend(shader, "iTime", elapsedTime)
            safeSend(shader, "uRotation", {card.rotationY * 0.1, -card.rotationX * 0.1})
        end
        
        -- Track previous position
        card.prevX = card.x
        card.prevY = card.y
        
        -- Keep rotation at zero (no spinning)
        card.rotation = 0
        
        -- Return to base position when not dragging
        if not card.dragging then
            card.x = damp(card.x, card.baseX, 8, dt)
            card.y = damp(card.y, card.baseY, 8, dt)
        end
        
        -- Scale animation
        card.scale = damp(card.scale, card.targetScale, 8, dt)
        
        -- Idle animation (gentle wobble when not hovered or dragging)
        if not card.hovered and not card.dragging then
            local offset = card.index * 0.5  -- Offset animation per card
            card.rotationX = damp(card.rotationX, math.sin(elapsedTime * 0.7 + offset) * 0.2, 8, dt)
            card.rotationY = damp(card.rotationY, math.cos(elapsedTime * 0.7 + offset) * 0.2, 8, dt)
        end
        
        -- Shake animation (scale pulse only, no rotation)
        if card.shakeActive then
            card.shakeTime = card.shakeTime + dt
            if card.shakeTime > 0.15 then
                card.shakeActive = false
                card.shakeTime = 0
            end
        end
    end
end

function micatro.draw()
    local w, h = love.graphics.getDimensions()
    
    -- Draw background with shader
    if bgShader then
        love.graphics.setShader(bgShader)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(dummyTexture, 0, 0, 0, w, h)
        love.graphics.setShader()
    else
        -- Fallback gradient background
        for i = 0, h do
            local t = i / h
            love.graphics.setColor(0.85 * (1-t) + 0.1 * t, 0.2 * (1-t), 0.2 * (1-t) + 0.1 * t)
            love.graphics.line(0, i, w, i)
        end
    end
    
    -- Draw each card
    for i, card in ipairs(cards) do
        micatro.drawCard(card, i)
    end
    
    -- Draw UI hints
    love.graphics.setColor(1, 1, 1, 0.7)
    local smallFont = love.graphics.newFont(16)
    love.graphics.setFont(smallFont)
    love.graphics.print("Hover to tilt • Drag to move • SPACE to play full game • ESC to return", 20, h - 40)
    
    -- Title
    love.graphics.setColor(1, 1, 1, 0.9)
    local titleFont = love.graphics.newFont(32)
    love.graphics.setFont(titleFont)
    love.graphics.print("Micatro", 20, 20)
    
    -- Subtitle
    love.graphics.setColor(1, 1, 1, 0.6)
    local subFont = love.graphics.newFont(18)
    love.graphics.setFont(subFont)
    love.graphics.print("Card Shader Effects", 20, 55)
end

function micatro.drawCard(card, index)
    if jokerTexture then
        love.graphics.push()
        love.graphics.translate(card.x, card.y)
        love.graphics.rotate(card.rotation)
        
        -- Scale to fit card size
        local imgScale = cardHeight / jokerTexture:getHeight()
        love.graphics.scale(card.scale * imgScale, card.scale * imgScale)
        
        -- Apply tilt via shear
        love.graphics.shear(card.rotationY * 0.1, card.rotationX * 0.1)
        
        -- Apply shader if this card has one
        local shader = shaders[card.effectKey]
        if shader then
            safeSend(shader, "iTime", elapsedTime)
            safeSend(shader, "uRotation", {card.rotationY, -card.rotationX})
            love.graphics.setShader(shader)
        end
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(
            jokerTexture,
            -jokerTexture:getWidth() / 2,
            -jokerTexture:getHeight() / 2
        )
        
        love.graphics.setShader()
        love.graphics.pop()
    else
        -- Fallback placeholder
        love.graphics.push()
        love.graphics.translate(card.x, card.y)
        love.graphics.rotate(card.rotation)
        love.graphics.scale(card.scale, card.scale)
        
        love.graphics.setColor(0.2, 0.15, 0.3)
        love.graphics.rectangle("fill", -cardWidth/2, -cardHeight/2, cardWidth, cardHeight, 8, 8)
        love.graphics.setColor(0.6, 0.4, 0.8)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", -cardWidth/2, -cardHeight/2, cardWidth, cardHeight, 8, 8)
        
        love.graphics.setColor(1, 1, 1)
        local font = love.graphics.newFont(16)
        love.graphics.setFont(font)
        local text = effectNames[index]
        love.graphics.print(text, -font:getWidth(text)/2, -font:getHeight()/2)
        
        love.graphics.pop()
    end
end

function micatro.mousemoved(x, y, dx, dy)
    for _, card in ipairs(cards) do
        local wasHovered = card.hovered
        card.hovered = isInsideCard(card, x, y)
        
        -- Trigger shake on hover enter
        if card.hovered and not wasHovered and not card.dragging then
            card.shakeActive = true
            card.shakeTime = 0
            card.targetScale = 1.15
        elseif not card.hovered and wasHovered and not card.dragging then
            card.targetScale = 1
        end
        
        -- Tilt based on mouse position when hovered
        if card.hovered and not card.dragging then
            local offsetX = (x - card.x) / (cardWidth * card.scale / 2)
            local offsetY = (y - card.y) / (cardHeight * card.scale / 2)
            
            local maxTilt = 0.4
            card.rotationY = damp(card.rotationY, -offsetX * maxTilt, 12, 1/60)
            card.rotationX = damp(card.rotationX, offsetY * maxTilt, 12, 1/60)
        end
        
        -- Drag update
        if card.dragging then
            card.x = x - card.dragOffsetX
            card.y = y - card.dragOffsetY
        end
    end
end

function micatro.mousepressed(x, y, button)
    if button == 1 then
        -- Find topmost hovered card (last in draw order = on top)
        for i = #cards, 1, -1 do
            local card = cards[i]
            if card.hovered then
                card.dragging = true
                card.dragOffsetX = x - card.x
                card.dragOffsetY = y - card.y
                break  -- Only drag one card
            end
        end
    end
end

function micatro.mousereleased(x, y, button)
    if button == 1 then
        for _, card in ipairs(cards) do
            card.dragging = false
        end
    end
end

function micatro.keypressed(key)
    if key == "escape" then
        switchScene("game")
    elseif key == "space" or key == "return" then
        -- Switch to full Micatro game
        switchScene("micatro_menu")
    end
end

function micatro.resize(w, h)
    -- Reposition cards
    local totalWidth = 5 * cardWidth + 4 * cardSpacing
    local startX = (w - totalWidth) / 2 + cardWidth / 2
    local centerY = h / 2
    
    for i, card in ipairs(cards) do
        card.baseX = startX + (i - 1) * (cardWidth + cardSpacing)
        card.baseY = centerY
    end
end

return micatro
