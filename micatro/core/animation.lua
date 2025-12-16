-- Animation Utilities
-- Easing functions and animation helpers

local M = {}

-- =====================
-- EASING FUNCTIONS
-- =====================

-- Linear (no easing)
function M.linear(t)
    return t
end

-- Quad easing
function M.easeInQuad(t)
    return t * t
end

function M.easeOutQuad(t)
    return t * (2 - t)
end

function M.easeInOutQuad(t)
    if t < 0.5 then
        return 2 * t * t
    else
        return -1 + (4 - 2 * t) * t
    end
end

-- Cubic easing
function M.easeInCubic(t)
    return t * t * t
end

function M.easeOutCubic(t)
    t = t - 1
    return t * t * t + 1
end

function M.easeInOutCubic(t)
    if t < 0.5 then
        return 4 * t * t * t
    else
        t = t - 1
        return 1 + 4 * t * t * t
    end
end

-- Quart easing
function M.easeInQuart(t)
    return t * t * t * t
end

function M.easeOutQuart(t)
    t = t - 1
    return 1 - t * t * t * t
end

function M.easeInOutQuart(t)
    if t < 0.5 then
        return 8 * t * t * t * t
    else
        t = t - 1
        return 1 - 8 * t * t * t * t
    end
end

-- Elastic easing
function M.easeOutElastic(t)
    if t == 0 or t == 1 then return t end
    local p = 0.3
    local s = p / 4
    return math.pow(2, -10 * t) * math.sin((t - s) * (2 * math.pi) / p) + 1
end

function M.easeInElastic(t)
    if t == 0 or t == 1 then return t end
    local p = 0.3
    local s = p / 4
    t = t - 1
    return -math.pow(2, 10 * t) * math.sin((t - s) * (2 * math.pi) / p)
end

-- Bounce easing
function M.easeOutBounce(t)
    if t < 1/2.75 then
        return 7.5625 * t * t
    elseif t < 2/2.75 then
        t = t - 1.5/2.75
        return 7.5625 * t * t + 0.75
    elseif t < 2.5/2.75 then
        t = t - 2.25/2.75
        return 7.5625 * t * t + 0.9375
    else
        t = t - 2.625/2.75
        return 7.5625 * t * t + 0.984375
    end
end

function M.easeInBounce(t)
    return 1 - M.easeOutBounce(1 - t)
end

-- Back easing (overshoots)
function M.easeOutBack(t)
    local s = 1.70158
    t = t - 1
    return t * t * ((s + 1) * t + s) + 1
end

function M.easeInBack(t)
    local s = 1.70158
    return t * t * ((s + 1) * t - s)
end

-- =====================
-- LERP FUNCTIONS
-- =====================

-- Linear interpolation
function M.lerp(a, b, t)
    return a + (b - a) * t
end

-- Smooth damp (for smooth camera/value following)
function M.damp(current, target, speed, dt)
    return M.lerp(current, target, 1 - math.exp(-speed * dt))
end

-- Smooth spring
function M.spring(current, target, velocity, stiffness, damping, dt)
    local force = (target - current) * stiffness
    local dampForce = velocity * damping
    local acceleration = force - dampForce
    
    local newVelocity = velocity + acceleration * dt
    local newCurrent = current + newVelocity * dt
    
    return newCurrent, newVelocity
end

-- =====================
-- TWEEN CLASS
-- =====================

local Tween = {}
Tween.__index = Tween

function M.newTween(target, properties, duration, easing, onComplete)
    local tween = setmetatable({
        target = target,
        properties = {},
        duration = duration or 1,
        elapsed = 0,
        easing = easing or M.easeOutQuad,
        onComplete = onComplete,
        complete = false,
        paused = false
    }, Tween)
    
    -- Store start and end values
    for key, endValue in pairs(properties) do
        tween.properties[key] = {
            start = target[key],
            finish = endValue
        }
    end
    
    return tween
end

function Tween:update(dt)
    if self.complete or self.paused then return end
    
    self.elapsed = self.elapsed + dt
    local progress = math.min(self.elapsed / self.duration, 1)
    local easedProgress = self.easing(progress)
    
    -- Update all properties
    for key, prop in pairs(self.properties) do
        self.target[key] = M.lerp(prop.start, prop.finish, easedProgress)
    end
    
    -- Check completion
    if progress >= 1 then
        self.complete = true
        if self.onComplete then
            self.onComplete()
        end
    end
end

function Tween:pause()
    self.paused = true
end

function Tween:resume()
    self.paused = false
end

function Tween:reset()
    self.elapsed = 0
    self.complete = false
    for key, prop in pairs(self.properties) do
        self.target[key] = prop.start
    end
end

-- =====================
-- TWEEN MANAGER
-- =====================

local TweenManager = {
    tweens = {}
}

function M.addTween(...)
    local tween = M.newTween(...)
    table.insert(TweenManager.tweens, tween)
    return tween
end

function M.updateTweens(dt)
    for i = #TweenManager.tweens, 1, -1 do
        local tween = TweenManager.tweens[i]
        tween:update(dt)
        if tween.complete then
            table.remove(TweenManager.tweens, i)
        end
    end
end

function M.clearTweens()
    TweenManager.tweens = {}
end

-- =====================
-- PARTICLE-LIKE EFFECTS
-- =====================

-- Score popup particles
local scorePopups = {}

function M.addScorePopup(value, x, y, color, isChips)
    local prefix = isChips and "+" or "×"
    table.insert(scorePopups, {
        text = prefix .. tostring(math.floor(value)),
        x = x,
        y = y,
        color = color or (isChips and {0.4, 0.7, 1} or {1, 0.4, 0.3}),
        alpha = 1,
        scale = 1.5,
        vy = -80,
        life = 0
    })
end

function M.updatePopups(dt)
    for i = #scorePopups, 1, -1 do
        local p = scorePopups[i]
        p.life = p.life + dt
        p.y = p.y + p.vy * dt
        p.vy = p.vy * 0.95
        p.alpha = math.max(0, 1 - p.life / 1.2)
        p.scale = 1 + 0.5 * M.easeOutBack(math.min(p.life * 3, 1))
        
        if p.alpha <= 0 then
            table.remove(scorePopups, i)
        end
    end
end

function M.drawPopups()
    for _, p in ipairs(scorePopups) do
        love.graphics.push()
        love.graphics.translate(p.x, p.y)
        love.graphics.scale(p.scale, p.scale)
        
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.alpha)
        local font = love.graphics.newFont(18)
        love.graphics.setFont(font)
        love.graphics.printf(p.text, -50, -10, 100, "center")
        
        love.graphics.pop()
    end
end

function M.clearPopups()
    scorePopups = {}
end

-- =====================
-- SHAKE EFFECT
-- =====================

local shake = {
    intensity = 0,
    duration = 0,
    elapsed = 0,
    offsetX = 0,
    offsetY = 0
}

function M.startShake(intensity, duration)
    shake.intensity = intensity or 5
    shake.duration = duration or 0.3
    shake.elapsed = 0
end

function M.updateShake(dt)
    if shake.elapsed < shake.duration then
        shake.elapsed = shake.elapsed + dt
        local progress = shake.elapsed / shake.duration
        local decay = 1 - M.easeOutQuad(progress)
        local amount = shake.intensity * decay
        
        shake.offsetX = (math.random() * 2 - 1) * amount
        shake.offsetY = (math.random() * 2 - 1) * amount
    else
        shake.offsetX = 0
        shake.offsetY = 0
    end
end

function M.getShakeOffset()
    return shake.offsetX, shake.offsetY
end

function M.applyShake()
    love.graphics.translate(shake.offsetX, shake.offsetY)
end

return M

