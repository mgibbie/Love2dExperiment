-- Blind Select Scene
-- Choose between small, big, or boss blind (or skip)

local Blinds = require("micatro.data.blinds")
local GameState = require("micatro.core.game_state")

local M = {}

-- Game state reference
local gameState = nil

-- Blind options
local blindOptions = {}
local selectedBlind = nil
local hoveredBlind = nil
local hoveredButton = nil

-- Animation
local elapsedTime = 0
local bgShader = nil

function M.load()
    local code = love.filesystem.read("shaders/balatro_bg.glsl")
    if code then
        local success, shader = pcall(love.graphics.newShader, code)
        if success then
            bgShader = shader
        end
    end
end

function M.enter()
    elapsedTime = 0
    
    -- Get or create game state
    if not gameState then
        gameState = GameState.new("b_red")
    end
    
    -- Generate blind options based on current round
    M.generateBlinds()
end

function M.generateBlinds()
    blindOptions = {}
    
    local ante = gameState.ante
    
    -- Small blind (can skip)
    table.insert(blindOptions, {
        blind = Blinds.BLINDS.bl_small,
        chips = Blinds.getBlindChips(ante, 1),
        reward = 3,
        canSkip = true,
        skipReward = "Tag",
        selected = false
    })
    
    -- Big blind (can skip)
    table.insert(blindOptions, {
        blind = Blinds.BLINDS.bl_big,
        chips = Blinds.getBlindChips(ante, 1.5),
        reward = 4,
        canSkip = true,
        skipReward = "Tag",
        selected = false
    })
    
    -- Boss blind (cannot skip)
    local bossBlind
    if ante >= 8 then
        bossBlind = Blinds.getFinalBoss()
    else
        bossBlind = Blinds.getRandomBoss(ante)
    end
    
    table.insert(blindOptions, {
        blind = bossBlind,
        chips = Blinds.getBlindChips(ante, bossBlind.mult),
        reward = bossBlind.dollars or 5,
        canSkip = false,
        isBoss = true,
        selected = false
    })
    
    selectedBlind = 1  -- Default to small blind
end

function M.exit()
    -- Nothing to cleanup
end

function M.update(dt)
    elapsedTime = elapsedTime + dt
    
    if bgShader then
        bgShader:send("iTime", elapsedTime)
        local w, h = love.graphics.getDimensions()
        bgShader:send("iResolution", {w, h})
    end
end

function M.draw()
    local w, h = love.graphics.getDimensions()
    
    -- Background
    if bgShader then
        love.graphics.setShader(bgShader)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", 0, 0, w, h)
        love.graphics.setShader()
    else
        love.graphics.setColor(0.12, 0.08, 0.18, 1)
        love.graphics.rectangle("fill", 0, 0, w, h)
    end
    
    -- Title
    love.graphics.setColor(1, 1, 1, 1)
    local titleFont = love.graphics.newFont(36)
    love.graphics.setFont(titleFont)
    love.graphics.printf("SELECT BLIND", 0, 30, w, "center")
    
    -- Ante display
    love.graphics.setColor(0.8, 0.8, 0.9, 0.8)
    local anteFont = love.graphics.newFont(20)
    love.graphics.setFont(anteFont)
    love.graphics.printf("Ante " .. gameState.ante, 0, 75, w, "center")
    
    -- Draw blind options
    local optionWidth = 200
    local optionHeight = 280
    local spacing = 40
    local totalWidth = #blindOptions * optionWidth + (#blindOptions - 1) * spacing
    local startX = (w - totalWidth) / 2
    local optionY = h * 0.35
    
    for i, option in ipairs(blindOptions) do
        local x = startX + (i - 1) * (optionWidth + spacing)
        local isHovered = hoveredBlind == i
        local isSelected = selectedBlind == i
        
        M.drawBlindOption(option, x, optionY, optionWidth, optionHeight, isHovered, isSelected, i)
    end
    
    -- Draw buttons
    M.drawButtons()
    
    -- Instructions
    love.graphics.setColor(1, 1, 1, 0.5)
    local hintFont = love.graphics.newFont(14)
    love.graphics.setFont(hintFont)
    love.graphics.printf("Click a blind to select • Press SPACE to play", 0, h - 40, w, "center")
end

function M.drawBlindOption(option, x, y, width, height, isHovered, isSelected, index)
    local blind = option.blind
    local scale = isHovered and 1.02 or 1
    
    love.graphics.push()
    love.graphics.translate(x + width/2, y + height/2)
    love.graphics.scale(scale, scale)
    love.graphics.translate(-(x + width/2), -(y + height/2))
    
    -- Background
    local bgColor
    if option.isBoss then
        bgColor = blind.boss_colour or {0.5, 0.2, 0.2}
    else
        bgColor = {0.15, 0.15, 0.2}
    end
    
    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", x + 5, y + 5, width, height, 12)
    
    -- Card
    love.graphics.setColor(bgColor[1], bgColor[2], bgColor[3], 0.95)
    love.graphics.rectangle("fill", x, y, width, height, 12)
    
    -- Border
    if isSelected then
        love.graphics.setColor(1, 0.85, 0.4, 1)
        love.graphics.setLineWidth(4)
    else
        love.graphics.setColor(0.4, 0.4, 0.5, 1)
        love.graphics.setLineWidth(2)
    end
    love.graphics.rectangle("line", x, y, width, height, 12)
    
    -- Blind name
    love.graphics.setColor(1, 1, 1, 1)
    local nameFont = love.graphics.newFont(20)
    love.graphics.setFont(nameFont)
    love.graphics.printf(blind.name, x, y + 20, width, "center")
    
    -- Chip requirement
    love.graphics.setColor(0.4, 0.7, 1, 1)
    local chipsFont = love.graphics.newFont(28)
    love.graphics.setFont(chipsFont)
    love.graphics.printf(M.formatNumber(option.chips), x, y + 55, width, "center")
    
    love.graphics.setColor(0.6, 0.6, 0.7, 1)
    local labelFont = love.graphics.newFont(12)
    love.graphics.setFont(labelFont)
    love.graphics.printf("chips to win", x, y + 88, width, "center")
    
    -- Reward
    love.graphics.setColor(1, 0.85, 0.4, 1)
    local rewardFont = love.graphics.newFont(18)
    love.graphics.setFont(rewardFont)
    love.graphics.printf("$" .. option.reward, x, y + 120, width, "center")
    
    -- Boss effect
    if option.isBoss and blind.description and blind.description ~= "" then
        love.graphics.setColor(1, 0.5, 0.4, 0.9)
        local effectFont = love.graphics.newFont(12)
        love.graphics.setFont(effectFont)
        love.graphics.printf(blind.description, x + 10, y + 155, width - 20, "center")
    end
    
    -- Skip button (if skippable)
    if option.canSkip then
        local skipY = y + height - 50
        local skipW = width - 40
        local isSkipHovered = hoveredButton == ("skip_" .. index)
        
        if isSkipHovered then
            love.graphics.setColor(0.5, 0.4, 0.3, 1)
        else
            love.graphics.setColor(0.35, 0.3, 0.25, 1)
        end
        love.graphics.rectangle("fill", x + 20, skipY, skipW, 35, 6)
        
        love.graphics.setColor(1, 1, 1, 0.9)
        local skipFont = love.graphics.newFont(14)
        love.graphics.setFont(skipFont)
        love.graphics.printf("Skip for Tag", x + 20, skipY + 10, skipW, "center")
    end
    
    love.graphics.pop()
end

function M.drawButtons()
    local w, h = love.graphics.getDimensions()
    
    -- Play button
    local btnW, btnH = 180, 55
    local btnX = (w - btnW) / 2
    local btnY = h * 0.85
    local isPlayHovered = hoveredButton == "play"
    
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", btnX + 4, btnY + 4, btnW, btnH, 10)
    
    if isPlayHovered then
        love.graphics.setColor(0.3, 0.65, 0.4, 1)
    else
        love.graphics.setColor(0.2, 0.5, 0.3, 1)
    end
    love.graphics.rectangle("fill", btnX, btnY, btnW, btnH, 10)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", btnX, btnY, btnW, btnH, 10)
    
    local btnFont = love.graphics.newFont(24)
    love.graphics.setFont(btnFont)
    love.graphics.printf("PLAY BLIND", btnX, btnY + btnH/2 - 12, btnW, "center")
end

function M.formatNumber(n)
    if n >= 1000000 then
        return string.format("%.1fM", n / 1000000)
    elseif n >= 1000 then
        return string.format("%.1fK", n / 1000)
    end
    return tostring(math.floor(n))
end

function M.mousemoved(x, y)
    local w, h = love.graphics.getDimensions()
    
    hoveredBlind = nil
    hoveredButton = nil
    
    -- Check blind options
    local optionWidth = 200
    local optionHeight = 280
    local spacing = 40
    local totalWidth = #blindOptions * optionWidth + (#blindOptions - 1) * spacing
    local startX = (w - totalWidth) / 2
    local optionY = h * 0.35
    
    for i, option in ipairs(blindOptions) do
        local ox = startX + (i - 1) * (optionWidth + spacing)
        
        if x >= ox and x <= ox + optionWidth and
           y >= optionY and y <= optionY + optionHeight then
            hoveredBlind = i
            
            -- Check skip button
            if option.canSkip then
                local skipY = optionY + optionHeight - 50
                if y >= skipY and y <= skipY + 35 and
                   x >= ox + 20 and x <= ox + optionWidth - 20 then
                    hoveredButton = "skip_" .. i
                end
            end
            break
        end
    end
    
    -- Check play button
    local btnW, btnH = 180, 55
    local btnX = (w - btnW) / 2
    local btnY = h * 0.85
    
    if x >= btnX and x <= btnX + btnW and y >= btnY and y <= btnY + btnH then
        hoveredButton = "play"
    end
end

function M.mousepressed(x, y, button)
    if button == 1 then
        -- Select blind
        if hoveredBlind then
            -- Check if skip button was clicked
            if hoveredButton and hoveredButton:find("skip_") then
                local index = tonumber(hoveredButton:sub(6))
                M.skipBlind(index)
            else
                selectedBlind = hoveredBlind
            end
        end
        
        -- Play button
        if hoveredButton == "play" then
            M.playSelectedBlind()
        end
    end
end

function M.keypressed(key)
    if key == "space" or key == "return" then
        M.playSelectedBlind()
    elseif key == "1" then
        selectedBlind = 1
    elseif key == "2" then
        selectedBlind = 2
    elseif key == "3" then
        selectedBlind = 3
    elseif key == "escape" then
        if switchScene then
            switchScene("micatro_menu")
        end
    end
end

function M.skipBlind(index)
    local option = blindOptions[index]
    if not option or not option.canSkip then return end
    
    -- Award skip reward (tag)
    gameState.blinds_skipped = gameState.blinds_skipped + 1
    
    -- Move to next round
    gameState.round = gameState.round + 1
    
    -- Regenerate blinds for new round
    M.generateBlinds()
end

function M.playSelectedBlind()
    if not selectedBlind or selectedBlind < 1 or selectedBlind > #blindOptions then
        return
    end
    
    local option = blindOptions[selectedBlind]
    
    -- Set current blind in game state
    gameState.current_blind = option.blind
    gameState.blind_chips = option.chips
    gameState.is_boss_blind = option.isBoss or false
    
    -- Pass game state and transition to play scene
    _G.MICATRO_GAME_STATE = gameState
    
    if switchScene then
        switchScene("micatro_play")
    end
end

function M.setGameState(state)
    gameState = state
end

return M

