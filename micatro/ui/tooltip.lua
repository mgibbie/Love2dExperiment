-- Tooltip Component
-- Display card/item information on hover

local Tooltip = {}
Tooltip.__index = Tooltip

-- Active tooltip data
local activeTooltip = nil
local showDelay = 0.3
local hoverTime = 0

function Tooltip.new()
    return setmetatable({
        x = 0,
        y = 0,
        width = 200,
        padding = 10,
        visible = false,
        title = "",
        description = "",
        stats = {},
        bgColor = {0.1, 0.1, 0.15, 0.95},
        borderColor = {0.4, 0.4, 0.5, 1},
        titleColor = {1, 1, 1, 1},
        descColor = {0.8, 0.8, 0.9, 1}
    }, Tooltip)
end

function Tooltip:show(x, y, data)
    self.x = x
    self.y = y
    self.title = data.title or ""
    self.description = data.description or ""
    self.stats = data.stats or {}
    self.rarity = data.rarity
    self.visible = true
    
    -- Adjust position to stay on screen
    local w, h = love.graphics.getDimensions()
    if self.x + self.width > w - 10 then
        self.x = w - self.width - 10
    end
    if self.x < 10 then
        self.x = 10
    end
end

function Tooltip:hide()
    self.visible = false
end

function Tooltip:draw()
    if not self.visible then return end
    
    -- Calculate height based on content
    local titleFont = love.graphics.newFont(14)
    local descFont = love.graphics.newFont(12)
    local statFont = love.graphics.newFont(11)
    
    local height = self.padding * 2
    height = height + 20  -- Title
    
    if self.description ~= "" then
        -- Wrap text
        love.graphics.setFont(descFont)
        local _, lines = descFont:getWrap(self.description, self.width - self.padding * 2)
        height = height + #lines * 14 + 10
    end
    
    height = height + #self.stats * 16
    
    -- Adjust Y to stay on screen
    local _, screenH = love.graphics.getDimensions()
    if self.y + height > screenH - 10 then
        self.y = screenH - height - 10
    end
    
    -- Background
    love.graphics.setColor(self.bgColor[1], self.bgColor[2], self.bgColor[3], self.bgColor[4])
    love.graphics.rectangle("fill", self.x, self.y, self.width, height, 6)
    
    -- Border
    love.graphics.setColor(self.borderColor[1], self.borderColor[2], self.borderColor[3], self.borderColor[4])
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x, self.y, self.width, height, 6)
    
    local yOffset = self.y + self.padding
    
    -- Rarity bar
    if self.rarity then
        local rarityColors = {
            {0.5, 0.6, 0.7},  -- Common
            {0.3, 0.7, 0.4},  -- Uncommon
            {0.8, 0.3, 0.3},  -- Rare
            {0.7, 0.4, 0.9}   -- Legendary
        }
        local col = rarityColors[self.rarity] or rarityColors[1]
        love.graphics.setColor(col[1], col[2], col[3], 0.8)
        love.graphics.rectangle("fill", self.x + 5, self.y + 5, self.width - 10, 3, 1)
    end
    
    -- Title
    love.graphics.setColor(self.titleColor[1], self.titleColor[2], self.titleColor[3], self.titleColor[4])
    love.graphics.setFont(titleFont)
    love.graphics.printf(self.title, self.x + self.padding, yOffset, self.width - self.padding * 2, "center")
    yOffset = yOffset + 22
    
    -- Description
    if self.description ~= "" then
        love.graphics.setColor(self.descColor[1], self.descColor[2], self.descColor[3], self.descColor[4])
        love.graphics.setFont(descFont)
        love.graphics.printf(self.description, self.x + self.padding, yOffset, self.width - self.padding * 2, "left")
        local _, lines = descFont:getWrap(self.description, self.width - self.padding * 2)
        yOffset = yOffset + #lines * 14 + 10
    end
    
    -- Stats
    love.graphics.setFont(statFont)
    for _, stat in ipairs(self.stats) do
        local labelColor = stat.color or {0.7, 0.8, 0.9}
        love.graphics.setColor(labelColor[1], labelColor[2], labelColor[3], 1)
        love.graphics.print(stat.label .. ": ", self.x + self.padding, yOffset)
        
        local valueColor = stat.valueColor or {1, 1, 1}
        love.graphics.setColor(valueColor[1], valueColor[2], valueColor[3], 1)
        love.graphics.print(stat.value, self.x + self.padding + 80, yOffset)
        yOffset = yOffset + 16
    end
end

-- Global tooltip instance
local globalTooltip = Tooltip.new()

function Tooltip.global()
    return globalTooltip
end

function Tooltip.showGlobal(x, y, data)
    globalTooltip:show(x, y, data)
end

function Tooltip.hideGlobal()
    globalTooltip:hide()
end

function Tooltip.drawGlobal()
    globalTooltip:draw()
end

return Tooltip

