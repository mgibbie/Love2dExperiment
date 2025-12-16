-- Button Component
-- Reusable button with hover and click handling

local Button = {}
Button.__index = Button

function Button.new(config)
    local button = setmetatable({
        x = config.x or 0,
        y = config.y or 0,
        width = config.width or 100,
        height = config.height or 40,
        text = config.text or "Button",
        
        -- Colors
        bgColor = config.bgColor or {0.3, 0.35, 0.45},
        hoverColor = config.hoverColor or {0.4, 0.5, 0.6},
        textColor = config.textColor or {1, 1, 1},
        borderColor = config.borderColor or {0.5, 0.5, 0.6},
        disabledColor = config.disabledColor or {0.2, 0.2, 0.25},
        
        -- State
        hovered = false,
        pressed = false,
        enabled = true,
        visible = true,
        
        -- Callbacks
        onClick = config.onClick,
        
        -- Style
        cornerRadius = config.cornerRadius or 8,
        fontSize = config.fontSize or 16,
        shadowOffset = config.shadowOffset or 3
        
    }, Button)
    
    return button
end

function Button:setPosition(x, y)
    self.x = x
    self.y = y
end

function Button:setSize(width, height)
    self.width = width
    self.height = height
end

function Button:setText(text)
    self.text = text
end

function Button:setEnabled(enabled)
    self.enabled = enabled
end

function Button:containsPoint(px, py)
    return px >= self.x and px <= self.x + self.width and
           py >= self.y and py <= self.y + self.height
end

function Button:update(dt)
    -- Animation could go here
end

function Button:draw()
    if not self.visible then return end
    
    local color
    if not self.enabled then
        color = self.disabledColor
    elseif self.hovered then
        color = self.hoverColor
    else
        color = self.bgColor
    end
    
    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", 
        self.x + self.shadowOffset, 
        self.y + self.shadowOffset, 
        self.width, self.height, 
        self.cornerRadius)
    
    -- Background
    love.graphics.setColor(color[1], color[2], color[3], 1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, self.cornerRadius)
    
    -- Border
    love.graphics.setColor(self.borderColor[1], self.borderColor[2], self.borderColor[3], 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, self.cornerRadius)
    
    -- Text
    local alpha = self.enabled and 1 or 0.5
    love.graphics.setColor(self.textColor[1], self.textColor[2], self.textColor[3], alpha)
    local font = love.graphics.newFont(self.fontSize)
    love.graphics.setFont(font)
    love.graphics.printf(self.text, self.x, self.y + self.height/2 - self.fontSize/2, self.width, "center")
end

function Button:mousemoved(x, y)
    self.hovered = self:containsPoint(x, y)
end

function Button:mousepressed(x, y, button)
    if button == 1 and self.enabled and self.hovered then
        self.pressed = true
        if self.onClick then
            self.onClick()
        end
        return true
    end
    return false
end

function Button:mousereleased(x, y, button)
    self.pressed = false
end

return Button

