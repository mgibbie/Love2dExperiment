-- Score Display Component
-- Animated chips x mult display

local ScoreDisplay = {}
ScoreDisplay.__index = ScoreDisplay

function ScoreDisplay.new(config)
    config = config or {}
    
    return setmetatable({
        x = config.x or 0,
        y = config.y or 0,
        width = config.width or 200,
        height = config.height or 60,
        
        -- Values
        chips = 0,
        mult = 0,
        targetChips = 0,
        targetMult = 0,
        totalScore = 0,
        
        -- Animation
        animSpeed = 8,
        popups = {},
        
        -- Colors
        chipsColor = {0.4, 0.7, 1},
        multColor = {1, 0.4, 0.3},
        bgColor = {0.1, 0.1, 0.15, 0.8}
        
    }, ScoreDisplay)
end

function ScoreDisplay:setTarget(chips, mult)
    self.targetChips = chips
    self.targetMult = mult
end

function ScoreDisplay:setInstant(chips, mult)
    self.chips = chips
    self.mult = mult
    self.targetChips = chips
    self.targetMult = mult
end

function ScoreDisplay:addPopup(text, color, x, y)
    table.insert(self.popups, {
        text = text,
        color = color or {1, 1, 1},
        x = x or self.x + self.width / 2,
        y = y or self.y,
        alpha = 1,
        vy = -60,
        life = 1.5
    })
end

function ScoreDisplay:update(dt)
    -- Animate values
    self.chips = self.chips + (self.targetChips - self.chips) * self.animSpeed * dt
    self.mult = self.mult + (self.targetMult - self.mult) * self.animSpeed * dt
    
    -- Snap when close
    if math.abs(self.chips - self.targetChips) < 1 then
        self.chips = self.targetChips
    end
    if math.abs(self.mult - self.targetMult) < 0.1 then
        self.mult = self.targetMult
    end
    
    -- Update popups
    for i = #self.popups, 1, -1 do
        local popup = self.popups[i]
        popup.y = popup.y + popup.vy * dt
        popup.alpha = popup.alpha - dt / popup.life
        popup.vy = popup.vy * 0.98
        
        if popup.alpha <= 0 then
            table.remove(self.popups, i)
        end
    end
end

function ScoreDisplay:draw()
    -- Background
    love.graphics.setColor(self.bgColor[1], self.bgColor[2], self.bgColor[3], self.bgColor[4])
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 8)
    
    -- Chips
    love.graphics.setColor(self.chipsColor[1], self.chipsColor[2], self.chipsColor[3], 1)
    local chipsFont = love.graphics.newFont(24)
    love.graphics.setFont(chipsFont)
    love.graphics.printf(self:formatNumber(math.floor(self.chips)), 
        self.x, self.y + 8, self.width / 2 - 15, "right")
    
    -- X symbol
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("×", self.x + self.width / 2 - 15, self.y + 8, 30, "center")
    
    -- Mult
    love.graphics.setColor(self.multColor[1], self.multColor[2], self.multColor[3], 1)
    love.graphics.printf(self:formatNumber(math.floor(self.mult)), 
        self.x + self.width / 2 + 15, self.y + 8, self.width / 2 - 15, "left")
    
    -- Total
    local total = math.floor(self.chips * self.mult)
    love.graphics.setColor(1, 1, 1, 0.9)
    local totalFont = love.graphics.newFont(14)
    love.graphics.setFont(totalFont)
    love.graphics.printf("= " .. self:formatNumber(total), 
        self.x, self.y + 38, self.width, "center")
    
    -- Draw popups
    for _, popup in ipairs(self.popups) do
        love.graphics.setColor(popup.color[1], popup.color[2], popup.color[3], popup.alpha)
        local popupFont = love.graphics.newFont(18)
        love.graphics.setFont(popupFont)
        love.graphics.print(popup.text, popup.x, popup.y)
    end
end

function ScoreDisplay:formatNumber(n)
    if n >= 1000000000 then
        return string.format("%.2fB", n / 1000000000)
    elseif n >= 1000000 then
        return string.format("%.2fM", n / 1000000)
    elseif n >= 1000 then
        return string.format("%.1fK", n / 1000)
    end
    return tostring(n)
end

return ScoreDisplay

