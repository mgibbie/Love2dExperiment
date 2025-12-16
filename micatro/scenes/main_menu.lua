-- Main Menu Scene
-- Deck selection and game start

local Decks = require("micatro.data.decks")

local M = {}

-- Menu state
local selectedDeck = "b_red"
local decks = {}
local hoveredDeck = nil
local buttonHovered = nil

-- Animation
local elapsedTime = 0

-- Shaders
local bgShader = nil

function M.load()
    -- Load background shader
    local code = love.filesystem.read("shaders/balatro_bg.glsl")
    if code then
        local success, shader = pcall(love.graphics.newShader, code)
        if success then
            bgShader = shader
        end
    end
    
    -- Get available decks
    decks = Decks.getUnlocked()
end

function M.enter()
    elapsedTime = 0
    selectedDeck = "b_red"
end

function M.exit()
    -- Cleanup if needed
end

function M.update(dt)
    elapsedTime = elapsedTime + dt
    
    -- Update background shader
    if bgShader then
        bgShader:send("iTime", elapsedTime)
        local w, h = love.graphics.getDimensions()
        bgShader:send("iResolution", {w, h})
    end
end

function M.draw()
    local w, h = love.graphics.getDimensions()
    
    -- Draw background
    if bgShader then
        love.graphics.setShader(bgShader)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", 0, 0, w, h)
        love.graphics.setShader()
    else
        love.graphics.setColor(0.15, 0.1, 0.2, 1)
        love.graphics.rectangle("fill", 0, 0, w, h)
    end
    
    -- Draw title
    love.graphics.setColor(1, 1, 1, 1)
    local titleFont = love.graphics.newFont(64)
    love.graphics.setFont(titleFont)
    love.graphics.printf("MICATRO", 0, h * 0.1, w, "center")
    
    -- Subtitle
    local subFont = love.graphics.newFont(24)
    love.graphics.setFont(subFont)
    love.graphics.setColor(0.8, 0.8, 0.9, 0.8)
    love.graphics.printf("A Balatro Clone", 0, h * 0.1 + 70, w, "center")
    
    -- Deck selection
    local deckY = h * 0.35
    local deckSpacing = 120
    local totalWidth = #decks * deckSpacing
    local startX = (w - totalWidth) / 2 + deckSpacing / 2
    
    love.graphics.setColor(1, 1, 1, 0.7)
    local labelFont = love.graphics.newFont(20)
    love.graphics.setFont(labelFont)
    love.graphics.printf("Select Deck", 0, deckY - 50, w, "center")
    
    -- Draw deck cards
    local cardW, cardH = 71, 95
    for i, deck in ipairs(decks) do
        local x = startX + (i - 1) * deckSpacing
        local y = deckY + cardH / 2
        
        local isSelected = deck.key == selectedDeck
        local isHovered = hoveredDeck == deck.key
        local scale = isSelected and 1.2 or (isHovered and 1.1 or 1)
        
        -- Card shadow
        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill", 
            x - cardW * scale / 2 + 4, 
            y - cardH * scale / 2 + 4, 
            cardW * scale, cardH * scale, 8)
        
        -- Card background with deck color
        local colors = {
            b_red = {0.9, 0.3, 0.3},
            b_blue = {0.3, 0.5, 0.9},
            b_yellow = {0.9, 0.8, 0.3},
            b_green = {0.3, 0.7, 0.4},
            b_black = {0.2, 0.2, 0.2}
        }
        local col = colors[deck.key] or {0.5, 0.5, 0.5}
        love.graphics.setColor(col[1], col[2], col[3], 1)
        love.graphics.rectangle("fill",
            x - cardW * scale / 2,
            y - cardH * scale / 2,
            cardW * scale, cardH * scale, 8)
        
        -- Border
        if isSelected then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setLineWidth(3)
        else
            love.graphics.setColor(0.3, 0.3, 0.4, 1)
            love.graphics.setLineWidth(2)
        end
        love.graphics.rectangle("line",
            x - cardW * scale / 2,
            y - cardH * scale / 2,
            cardW * scale, cardH * scale, 8)
        
        -- Deck name
        love.graphics.setColor(1, 1, 1, isHovered and 1 or 0.7)
        local nameFont = love.graphics.newFont(14)
        love.graphics.setFont(nameFont)
        love.graphics.printf(deck.name:gsub(" Deck", ""), 
            x - deckSpacing / 2, 
            y + cardH * scale / 2 + 10, 
            deckSpacing, "center")
    end
    
    -- Selected deck description
    local selected = Decks.get(selectedDeck)
    if selected then
        love.graphics.setColor(1, 1, 1, 0.9)
        local descFont = love.graphics.newFont(18)
        love.graphics.setFont(descFont)
        love.graphics.printf(selected.name, 0, deckY + cardH + 50, w, "center")
        
        love.graphics.setColor(0.7, 0.8, 0.9, 0.8)
        local smallFont = love.graphics.newFont(16)
        love.graphics.setFont(smallFont)
        love.graphics.printf(selected.description or "", 
            w * 0.2, deckY + cardH + 80, w * 0.6, "center")
    end
    
    -- Play button
    local btnW, btnH = 200, 60
    local btnX = (w - btnW) / 2
    local btnY = h * 0.75
    
    local isPlayHovered = buttonHovered == "play"
    
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", btnX + 4, btnY + 4, btnW, btnH, 10)
    
    if isPlayHovered then
        love.graphics.setColor(0.3, 0.7, 0.4, 1)
    else
        love.graphics.setColor(0.2, 0.5, 0.3, 1)
    end
    love.graphics.rectangle("fill", btnX, btnY, btnW, btnH, 10)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", btnX, btnY, btnW, btnH, 10)
    
    local btnFont = love.graphics.newFont(28)
    love.graphics.setFont(btnFont)
    love.graphics.printf("PLAY", btnX, btnY + btnH / 2 - 14, btnW, "center")
    
    -- Instructions
    love.graphics.setColor(1, 1, 1, 0.5)
    local hintFont = love.graphics.newFont(14)
    love.graphics.setFont(hintFont)
    love.graphics.printf("Press SPACE to start • ESC to quit", 0, h - 40, w, "center")
end

function M.mousemoved(x, y, dx, dy)
    local w, h = love.graphics.getDimensions()
    
    -- Check deck hovers
    hoveredDeck = nil
    local deckY = h * 0.35
    local deckSpacing = 120
    local totalWidth = #decks * deckSpacing
    local startX = (w - totalWidth) / 2 + deckSpacing / 2
    local cardW, cardH = 71, 95
    
    for i, deck in ipairs(decks) do
        local dx = startX + (i - 1) * deckSpacing
        local dy = deckY + cardH / 2
        
        if x >= dx - cardW / 2 and x <= dx + cardW / 2 and
           y >= dy - cardH / 2 and y <= dy + cardH / 2 then
            hoveredDeck = deck.key
            break
        end
    end
    
    -- Check button hovers
    buttonHovered = nil
    local btnW, btnH = 200, 60
    local btnX = (w - btnW) / 2
    local btnY = h * 0.75
    
    if x >= btnX and x <= btnX + btnW and
       y >= btnY and y <= btnY + btnH then
        buttonHovered = "play"
    end
end

function M.mousepressed(x, y, button)
    if button == 1 then
        -- Check deck selection
        if hoveredDeck then
            selectedDeck = hoveredDeck
        end
        
        -- Check play button
        if buttonHovered == "play" then
            M.startGame()
        end
    end
end

function M.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "space" or key == "return" then
        M.startGame()
    elseif key == "left" then
        -- Previous deck
        for i, deck in ipairs(decks) do
            if deck.key == selectedDeck and i > 1 then
                selectedDeck = decks[i - 1].key
                break
            end
        end
    elseif key == "right" then
        -- Next deck
        for i, deck in ipairs(decks) do
            if deck.key == selectedDeck and i < #decks then
                selectedDeck = decks[i + 1].key
                break
            end
        end
    end
end

function M.startGame()
    -- Start the game with selected deck
    -- This will be connected to the main game flow
    if switchScene then
        -- Store selected deck for the game
        _G.MICATRO_DECK = selectedDeck
        switchScene("micatro_play")
    end
end

return M

