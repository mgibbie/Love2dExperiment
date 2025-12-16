-- Collection Scene
-- Browse all available cards

local cards = require('data.cards')
local cardUI = require('ui.card')
local tooltip = require('ui.tooltip')

local collection = {}

-- Colors
local colors = {
    background = {0.06, 0.03, 0.1},
    backgroundGrad = {0.1, 0.05, 0.15},
    text = {0.9, 0.85, 0.75},
    accent = {0.9, 0.6, 0.3},
    tabActive = {0.2, 0.12, 0.25},
    tabInactive = {0.1, 0.06, 0.12},
    tabBorder = {0.5, 0.35, 0.55},
    button = {0.15, 0.1, 0.2},
    buttonHover = {0.25, 0.15, 0.3},
    buttonBorder = {0.5, 0.4, 0.6}
}

-- Class tabs
local classOrder = { 'all', 'centurion', 'naturalist', 'bounty_hunter', 'neutral' }
local classNames = {
    all = 'All Cards',
    centurion = 'Centurion',
    naturalist = 'Naturalist',
    bounty_hunter = 'Bounty Hunter',
    neutral = 'Neutral'
}

-- State
local selectedClass = 'all'
local hoveredCard = nil
local scrollOffset = 0
local mouseX, mouseY = 0, 0
local tabs = {}
local tabsInitialized = false
local backButton = { x = 10, y = 10, width = 80, height = 30, hovered = false, pressed = false }

-- Get filtered and sorted cards
local function getFilteredCards()
    local filtered = {}
    for _, card in ipairs(cards.sampleCards) do
        if selectedClass == 'all' or card.cardClass == selectedClass then
            table.insert(filtered, card)
        end
    end
    table.sort(filtered, function(a, b)
        if a.cost ~= b.cost then return a.cost < b.cost end
        return a.name < b.name
    end)
    return filtered
end

local function drawButton(btn, text)
    love.graphics.setColor(btn.hovered and colors.buttonHover or colors.button)
    love.graphics.rectangle('fill', btn.x, btn.y, btn.width, btn.height, 6, 6)
    love.graphics.setColor(colors.buttonBorder)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', btn.x, btn.y, btn.width, btn.height, 6, 6)
    love.graphics.setColor(colors.text)
    local font = love.graphics.newFont(14)
    love.graphics.setFont(font)
    local tw = font:getWidth(text)
    love.graphics.print(text, btn.x + (btn.width - tw) / 2, btn.y + (btn.height - font:getHeight()) / 2)
end

function collection.load() end

function collection.enter()
    selectedClass = 'all'
    scrollOffset = 0
    hoveredCard = nil
    tabsInitialized = false
    tabs = {}
end

function collection.exit() end

function collection.update(dt)
    local w = love.graphics.getWidth()
    local tabW = 140
    local startX = (w - #classOrder * tabW) / 2
    
    -- Initialize tabs once, then only update positions
    for i, class in ipairs(classOrder) do
        if not tabs[class] then
            tabs[class] = { hovered = false }
        end
        tabs[class].x = startX + (i - 1) * tabW
        tabs[class].y = 50
        tabs[class].width = tabW - 5
        tabs[class].height = 35
    end
end

function collection.draw()
    local w, h = love.graphics.getDimensions()
    
    -- Background
    for i = 0, h do
        local t = i / h
        love.graphics.setColor(
            colors.background[1] + (colors.backgroundGrad[1] - colors.background[1]) * t,
            colors.background[2] + (colors.backgroundGrad[2] - colors.background[2]) * t,
            colors.background[3] + (colors.backgroundGrad[3] - colors.background[3]) * t
        )
        love.graphics.line(0, i, w, i)
    end
    
    -- Title
    love.graphics.setColor(colors.text)
    local titleFont = love.graphics.newFont(28)
    love.graphics.setFont(titleFont)
    love.graphics.print("Card Collection", w / 2 - 100, 10)
    
    -- Class tabs
    local tabFont = love.graphics.newFont(14)
    love.graphics.setFont(tabFont)
    
    for _, class in ipairs(classOrder) do
        local tab = tabs[class]
        if tab then
            local isSelected = selectedClass == class
            local isHovered = tab.hovered
            
            if isSelected then
                love.graphics.setColor(colors.tabActive)
            elseif isHovered then
                love.graphics.setColor(colors.buttonHover)
            else
                love.graphics.setColor(colors.tabInactive)
            end
            love.graphics.rectangle('fill', tab.x, tab.y, tab.width, tab.height, 6, 6)
            
            love.graphics.setColor(isSelected and colors.accent or colors.tabBorder)
            love.graphics.setLineWidth(isSelected and 2 or 1)
            love.graphics.rectangle('line', tab.x, tab.y, tab.width, tab.height, 6, 6)
            
            love.graphics.setColor(isSelected and colors.accent or colors.text)
            local tw = tabFont:getWidth(classNames[class])
            love.graphics.print(classNames[class], tab.x + (tab.width - tw) / 2, tab.y + 8)
        end
    end
    
    -- Card count
    local filteredCards = getFilteredCards()
    love.graphics.setColor(colors.text[1], colors.text[2], colors.text[3], 0.6)
    local countFont = love.graphics.newFont(14)
    love.graphics.setFont(countFont)
    love.graphics.print(#filteredCards .. " cards", w / 2 - 30, 92)
    
    -- Card grid
    local gridY = 115
    local gridH = h - gridY - 20
    local cardScale = 0.9
    local cardW = cardUI.CARD_WIDTH * cardScale
    local cardH = cardUI.CARD_HEIGHT * cardScale
    local padding = 15
    local cardsPerRow = math.floor((w - padding * 2) / (cardW + padding))
    local startX = (w - cardsPerRow * (cardW + padding) + padding) / 2
    
    love.graphics.setScissor(0, gridY, w, gridH)
    for i, card in ipairs(filteredCards) do
        local col = (i - 1) % cardsPerRow
        local row = math.floor((i - 1) / cardsPerRow)
        local x = startX + col * (cardW + padding)
        local y = gridY + row * (cardH + padding) - scrollOffset
        
        if y + cardH > gridY and y < gridY + gridH then
            cardUI.draw(card, x, y, {
                scale = cardScale,
                hovered = hoveredCard == card
            })
        end
    end
    love.graphics.setScissor()
    
    -- Back button
    drawButton(backButton, "Back")
    
    -- Tooltip
    if hoveredCard then
        tooltip.drawCard(hoveredCard, mouseX, mouseY)
    end
end

function collection.mousemoved(x, y)
    mouseX, mouseY = x, y
    local w, h = love.graphics.getDimensions()
    
    hoveredCard = nil
    backButton.hovered = x >= backButton.x and x <= backButton.x + backButton.width and
                         y >= backButton.y and y <= backButton.y + backButton.height
    
    -- Check tabs
    for _, class in ipairs(classOrder) do
        local tab = tabs[class]
        if tab then
            tab.hovered = x >= tab.x and x <= tab.x + tab.width and y >= tab.y and y <= tab.y + tab.height
        end
    end
    
    -- Check cards
    local gridY = 115
    local gridH = h - gridY - 20
    local cardScale = 0.9
    local cardW = cardUI.CARD_WIDTH * cardScale
    local cardH = cardUI.CARD_HEIGHT * cardScale
    local padding = 15
    local cardsPerRow = math.floor((w - padding * 2) / (cardW + padding))
    local startX = (w - cardsPerRow * (cardW + padding) + padding) / 2
    
    local filteredCards = getFilteredCards()
    for i, card in ipairs(filteredCards) do
        local col = (i - 1) % cardsPerRow
        local row = math.floor((i - 1) / cardsPerRow)
        local cx = startX + col * (cardW + padding)
        local cy = gridY + row * (cardH + padding) - scrollOffset
        
        if x >= cx and x <= cx + cardW and y >= cy and y <= cy + cardH and
           y >= gridY and y <= gridY + gridH then
            hoveredCard = card
            break
        end
    end
end

function collection.mousepressed(x, y, button)
    if button == 1 then
        if backButton.hovered then backButton.pressed = true end
    end
end

function collection.mousereleased(x, y, button)
    if button == 1 then
        if backButton.pressed and backButton.hovered then
            switchScene("battlecards_menu")
        end
        backButton.pressed = false
        
        -- Check tab clicks
        for _, class in ipairs(classOrder) do
            local tab = tabs[class]
            if tab and tab.hovered then
                selectedClass = class
                scrollOffset = 0
                break
            end
        end
    end
end

function collection.wheelmoved(x, y)
    scrollOffset = math.max(0, scrollOffset - y * 40)
end

function collection.keypressed(key)
    if key == "escape" then switchScene("battlecards_menu") end
end

function collection.resize() end

return collection

