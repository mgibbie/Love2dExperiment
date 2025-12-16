-- Tooltip UI
-- Card hover information display

local cards = require('data.cards')
local tooltip = {}

-- Draw a tooltip for a card at the given position
function tooltip.drawCard(cardData, x, y)
    local w, h = love.graphics.getDimensions()
    local tooltipWidth = 220
    local padding = 10
    
    -- Calculate text heights
    local titleFont = love.graphics.newFont(14)
    local textFont = love.graphics.newFont(11)
    local smallFont = love.graphics.newFont(9)
    
    local effectLines = tooltip.wrapText(cardData.effect or '', textFont, tooltipWidth - padding * 2)
    local effectHeight = #effectLines * textFont:getHeight()
    
    local keywordText = ''
    if cardData.keywords and #cardData.keywords > 0 then
        keywordText = table.concat(cardData.keywords, ', ')
    end
    
    local tooltipHeight = padding * 2 + titleFont:getHeight() + 8 + effectHeight
    if keywordText ~= '' then
        tooltipHeight = tooltipHeight + smallFont:getHeight() + 4
    end
    if cardData.type == 'creature' then
        tooltipHeight = tooltipHeight + smallFont:getHeight() + 4
    end
    
    -- Position tooltip (avoid going off screen)
    local tx = x + 15
    local ty = y + 15
    if tx + tooltipWidth > w then tx = x - tooltipWidth - 15 end
    if ty + tooltipHeight > h then ty = h - tooltipHeight - 10 end
    if tx < 10 then tx = 10 end
    if ty < 10 then ty = 10 end
    
    -- Draw background
    love.graphics.setColor(0.08, 0.05, 0.12, 0.95)
    love.graphics.rectangle('fill', tx, ty, tooltipWidth, tooltipHeight, 6, 6)
    
    -- Draw border
    local colorScheme = cards.colorSchemes[cardData.cardClass] or cards.colorSchemes.neutral
    love.graphics.setColor(colorScheme.secondary[1], colorScheme.secondary[2], colorScheme.secondary[3], 0.8)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', tx, ty, tooltipWidth, tooltipHeight, 6, 6)
    
    local cy = ty + padding
    
    -- Draw card name and cost
    love.graphics.setFont(titleFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(cardData.name, tx + padding, cy)
    
    -- Cost badge
    love.graphics.setColor(0.2, 0.5, 0.9)
    local costX = tx + tooltipWidth - padding - 20
    love.graphics.circle('fill', costX + 10, cy + titleFont:getHeight() / 2, 12)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(smallFont)
    local costStr = tostring(cardData.cost)
    love.graphics.print(costStr, costX + 10 - smallFont:getWidth(costStr) / 2, cy + 2)
    
    cy = cy + titleFont:getHeight() + 8
    
    -- Draw stats for creatures
    if cardData.type == 'creature' then
        love.graphics.setFont(smallFont)
        love.graphics.setColor(0.9, 0.7, 0.5)
        local statsText = 'Attack: ' .. (cardData.attack or 0) .. '  Health: ' .. (cardData.health or 1)
        love.graphics.print(statsText, tx + padding, cy)
        cy = cy + smallFont:getHeight() + 4
    end
    
    -- Draw keywords
    if keywordText ~= '' then
        love.graphics.setFont(smallFont)
        love.graphics.setColor(1, 0.85, 0.4)
        love.graphics.print(keywordText, tx + padding, cy)
        cy = cy + smallFont:getHeight() + 4
    end
    
    -- Draw effect text
    love.graphics.setFont(textFont)
    love.graphics.setColor(0.85, 0.82, 0.78)
    for _, line in ipairs(effectLines) do
        love.graphics.print(line, tx + padding, cy)
        cy = cy + textFont:getHeight()
    end
end

-- Wrap text to fit within a given width
function tooltip.wrapText(text, font, maxWidth)
    local lines = {}
    local currentLine = ''
    
    for word in text:gmatch('%S+') do
        local testLine = currentLine == '' and word or currentLine .. ' ' .. word
        if font:getWidth(testLine) <= maxWidth then
            currentLine = testLine
        else
            if currentLine ~= '' then
                table.insert(lines, currentLine)
            end
            currentLine = word
        end
    end
    
    if currentLine ~= '' then
        table.insert(lines, currentLine)
    end
    
    if #lines == 0 then
        table.insert(lines, '')
    end
    
    return lines
end

return tooltip

