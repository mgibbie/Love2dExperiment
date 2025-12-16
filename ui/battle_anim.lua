-- Battle Animation System
-- Handles attack animations and turn sequencing

local battleAnim = {}

-- Animation state
local animations = {}
local actionQueue = {}
local currentAction = nil
local actionTimer = 0
local isAnimating = false

-- Loaded assets
local boomSprite = nil

-- Animation constants
local ATTACK_DURATION = 0.3    -- Time for attack animation
local HIT_DURATION = 0.4       -- Time to show boom effect
local PAUSE_DURATION = 0.5     -- Pause after each attack
local SWITCH_OUT_DURATION = 0.35  -- Time for Pokemon to exit
local SWITCH_IN_DURATION = 0.4    -- Time for Pokemon to enter

-- Switch animation state (tracked separately for player/enemy)
local switchState = {
    player = { active = false, phase = nil, timer = 0 },
    enemy = { active = false, phase = nil, timer = 0 }
}

-- Initialize (load assets)
function battleAnim.init()
    local success, img = pcall(love.graphics.newImage, "assets/sprites/boom.png")
    if success then
        boomSprite = img
    else
        print("[BattleAnim] Failed to load boom.png")
    end
end

-- Clear all animations and queue
function battleAnim.reset()
    animations = {}
    actionQueue = {}
    currentAction = nil
    actionTimer = 0
    isAnimating = false
    switchState = {
        player = { active = false, phase = nil, timer = 0 },
        enemy = { active = false, phase = nil, timer = 0 }
    }
end

-- Check if animations are playing
function battleAnim.isAnimating()
    return isAnimating or #actionQueue > 0 or currentAction ~= nil
end

-- Queue an attack action
-- action = { type = "attack", attacker = pokemon, defender = pokemon, move = move, isPlayer = bool, onComplete = function }
function battleAnim.queueAction(action)
    table.insert(actionQueue, action)
    if not isAnimating then
        battleAnim.startNextAction()
    end
end

-- Start the next queued action
function battleAnim.startNextAction()
    if #actionQueue == 0 then
        isAnimating = false
        currentAction = nil
        return
    end
    
    currentAction = table.remove(actionQueue, 1)
    actionTimer = 0
    isAnimating = true
    
    if currentAction.type == "attack" then
        -- Start attack animation
        currentAction.phase = "windup"
        currentAction.startX = currentAction.attackerX or 0
        currentAction.startY = currentAction.attackerY or 0
    elseif currentAction.type == "message" then
        currentAction.phase = "show"
    elseif currentAction.type == "switch_out" then
        currentAction.phase = "exit"
        local side = currentAction.isPlayer and "player" or "enemy"
        switchState[side].active = true
        switchState[side].phase = "exit"
        switchState[side].timer = 0
    elseif currentAction.type == "switch_in" then
        currentAction.phase = "enter"
        local side = currentAction.isPlayer and "player" or "enemy"
        switchState[side].active = true
        switchState[side].phase = "enter"
        switchState[side].timer = 0
    end
end

-- Update animations
function battleAnim.update(dt)
    if not isAnimating or not currentAction then
        return
    end
    
    actionTimer = actionTimer + dt
    
    if currentAction.type == "attack" then
        battleAnim.updateAttack(dt)
    elseif currentAction.type == "message" then
        if actionTimer >= (currentAction.duration or 0.5) then
            if currentAction.onComplete then
                currentAction.onComplete()
            end
            battleAnim.startNextAction()
        end
    elseif currentAction.type == "switch_out" then
        battleAnim.updateSwitchOut(dt)
    elseif currentAction.type == "switch_in" then
        battleAnim.updateSwitchIn(dt)
    end
    
    -- Update active animations (boom effects, etc.)
    for i = #animations, 1, -1 do
        local anim = animations[i]
        anim.timer = anim.timer + dt
        if anim.timer >= anim.duration then
            table.remove(animations, i)
        end
    end
end

-- Update attack animation
function battleAnim.updateAttack(dt)
    local action = currentAction
    
    if action.phase == "windup" then
        -- Quick movement toward target
        if actionTimer >= ATTACK_DURATION then
            action.phase = "hit"
            actionTimer = 0
            
            -- Add boom effect at defender position
            table.insert(animations, {
                type = "boom",
                x = action.defenderX or 0,
                y = action.defenderY or 0,
                timer = 0,
                duration = HIT_DURATION,
                scale = 1.0
            })
            
            -- Execute the actual attack logic
            if action.onExecute then
                action.onExecute()
            end
        end
    elseif action.phase == "hit" then
        -- Show hit effect
        if actionTimer >= HIT_DURATION then
            action.phase = "recover"
            actionTimer = 0
        end
    elseif action.phase == "recover" then
        -- Pause before next action
        if actionTimer >= PAUSE_DURATION then
            if action.onComplete then
                action.onComplete()
            end
            battleAnim.startNextAction()
        end
    end
end

-- Update switch out animation (Pokemon exits)
function battleAnim.updateSwitchOut(dt)
    local action = currentAction
    local side = action.isPlayer and "player" or "enemy"
    switchState[side].timer = switchState[side].timer + dt
    
    if switchState[side].timer >= SWITCH_OUT_DURATION then
        switchState[side].active = false
        switchState[side].phase = nil
        
        -- Execute the switch logic
        if action.onExecute then
            action.onExecute()
        end
        
        if action.onComplete then
            action.onComplete()
        end
        battleAnim.startNextAction()
    end
end

-- Update switch in animation (Pokemon enters)
function battleAnim.updateSwitchIn(dt)
    local action = currentAction
    local side = action.isPlayer and "player" or "enemy"
    switchState[side].timer = switchState[side].timer + dt
    
    if switchState[side].timer >= SWITCH_IN_DURATION then
        switchState[side].active = false
        switchState[side].phase = nil
        
        if action.onComplete then
            action.onComplete()
        end
        battleAnim.startNextAction()
    end
end

-- Get switch animation offset and alpha for a Pokemon (returns dx, dy, alpha)
function battleAnim.getSwitchOffset(isPlayer)
    local side = isPlayer and "player" or "enemy"
    local switchInfo = switchState[side]
    
    if not switchInfo.active then
        return 0, 0, 1
    end
    
    local direction = isPlayer and -1 or 1  -- Player exits left, enemy exits right
    
    if switchInfo.phase == "exit" then
        local progress = math.min(1, switchInfo.timer / SWITCH_OUT_DURATION)
        local eased = progress * progress  -- Ease in (accelerate)
        local offsetX = direction * eased * 200
        local alpha = 1 - progress
        return offsetX, 0, alpha
    elseif switchInfo.phase == "enter" then
        local progress = math.min(1, switchInfo.timer / SWITCH_IN_DURATION)
        local eased = 1 - (1 - progress) * (1 - progress)  -- Ease out (decelerate)
        local offsetX = direction * (1 - eased) * 200
        local alpha = progress
        return offsetX, 0, alpha
    end
    
    return 0, 0, 1
end

-- Get attacker offset for animation (returns dx, dy)
function battleAnim.getAttackerOffset(isPlayer)
    if not currentAction or currentAction.type ~= "attack" then
        return 0, 0
    end
    
    local isThisAttacker = (isPlayer and currentAction.isPlayer) or (not isPlayer and not currentAction.isPlayer)
    if not isThisAttacker then
        return 0, 0
    end
    
    local progress = 0
    local direction = isPlayer and 1 or -1  -- Player moves right, enemy moves left
    
    if currentAction.phase == "windup" then
        -- Move toward target
        progress = actionTimer / ATTACK_DURATION
        local eased = math.sin(progress * math.pi / 2)
        return direction * eased * 50, -eased * 20
    elseif currentAction.phase == "hit" or currentAction.phase == "recover" then
        -- Return to position
        local returnProgress = 0
        if currentAction.phase == "hit" then
            returnProgress = actionTimer / HIT_DURATION
        else
            returnProgress = 1
        end
        local remaining = 1 - returnProgress
        return direction * remaining * 50, -remaining * 20
    end
    
    return 0, 0
end

-- Get defender shake for hit effect (returns dx, dy)
function battleAnim.getDefenderShake(isPlayer)
    if not currentAction or currentAction.type ~= "attack" then
        return 0, 0
    end
    
    local isThisDefender = (isPlayer and not currentAction.isPlayer) or (not isPlayer and currentAction.isPlayer)
    if not isThisDefender then
        return 0, 0
    end
    
    if currentAction.phase == "hit" then
        local intensity = (1 - actionTimer / HIT_DURATION) * 8
        return math.random(-1, 1) * intensity, math.random(-1, 1) * intensity * 0.5
    end
    
    return 0, 0
end

-- Draw all active animations
function battleAnim.draw()
    for _, anim in ipairs(animations) do
        if anim.type == "boom" and boomSprite then
            local progress = anim.timer / anim.duration
            local scale = anim.scale * (0.5 + progress * 0.5)
            local alpha = 1 - progress
            
            local w, h = boomSprite:getDimensions()
            love.graphics.setColor(1, 1, 1, alpha)
            love.graphics.draw(boomSprite, 
                anim.x - (w * scale) / 2, 
                anim.y - (h * scale) / 2, 
                0, scale, scale)
        end
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

-- Draw boom at specific position (for testing)
function battleAnim.drawBoomAt(x, y, scale)
    if boomSprite then
        local w, h = boomSprite:getDimensions()
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(boomSprite, x - (w * scale) / 2, y - (h * scale) / 2, 0, scale, scale)
    end
end

return battleAnim

