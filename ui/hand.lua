-- Hand UI
-- Display and interaction for cards in hand

local cardUI = require('ui.card')
local hand = {}

-- Draw the player's hand
function hand.draw(cards, options)
    options = options or {}
    local y = options.y or (love.graphics.getHeight() - cardUI.CARD_HEIGHT - 20)
    local hoveredIndex = options.hoveredIndex
    local canPlay = options.canPlay or function() return true end
    local scale = options.scale or 1
    
    local w = love.graphics.getWidth()
    local cardWidth = cardUI.CARD_WIDTH * scale
    local cardSpacing = math.min(cardWidth * 0.8, (w - 200) / math.max(1, #cards))
    
    -- Calculate starting position to center hand
    local totalWidth = (#cards - 1) * cardSpacing + cardWidth
    local startX = (w - totalWidth) / 2
    
    for i, cardInstance in ipairs(cards) do
        local x = startX + (i - 1) * cardSpacing
        local isHovered = hoveredIndex == i
        local isPlayable = canPlay(cardInstance)
        
        cardUI.draw(cardInstance.card, x, y, {
            scale = scale,
            hovered = isHovered,
            playable = isPlayable
        })
    end
end

-- Draw the enemy's hand (card backs)
function hand.drawEnemy(cardCount, options)
    options = options or {}
    local y = options.y or 10
    local scale = options.scale or 0.6
    
    local w = love.graphics.getWidth()
    local cardWidth = cardUI.CARD_WIDTH * scale
    local cardSpacing = math.min(cardWidth * 0.5, (w - 200) / math.max(1, cardCount))
    
    local totalWidth = (cardCount - 1) * cardSpacing + cardWidth
    local startX = (w - totalWidth) / 2
    
    for i = 1, cardCount do
        local x = startX + (i - 1) * cardSpacing
        cardUI.drawBack(x, y, { scale = scale })
    end
end

-- Get card at position
function hand.getCardAtPosition(cards, mx, my, options)
    options = options or {}
    local y = options.y or (love.graphics.getHeight() - cardUI.CARD_HEIGHT - 20)
    local scale = options.scale or 1
    
    local w = love.graphics.getWidth()
    local cardWidth = cardUI.CARD_WIDTH * scale
    local cardHeight = cardUI.CARD_HEIGHT * scale
    local cardSpacing = math.min(cardWidth * 0.8, (w - 200) / math.max(1, #cards))
    
    local totalWidth = (#cards - 1) * cardSpacing + cardWidth
    local startX = (w - totalWidth) / 2
    
    -- Check from right to left (rightmost card is on top)
    for i = #cards, 1, -1 do
        local x = startX + (i - 1) * cardSpacing
        
        if mx >= x and mx <= x + cardWidth and my >= y and my <= y + cardHeight then
            return i, cards[i]
        end
    end
    
    return nil, nil
end

return hand

