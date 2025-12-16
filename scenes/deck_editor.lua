-- Deck Editor Scene
-- Build and manage decks

local cards = require('data.cards')
local cardUI = require('ui.card')
local tooltip = require('ui.tooltip')

local editor = {}

-- Colors
local colors = {
    background = {0.06, 0.03, 0.1},
    backgroundGrad = {0.1, 0.05, 0.15},
    text = {0.9, 0.85, 0.75},
    accent = {0.9, 0.6, 0.3},
    panel = {0.1, 0.06, 0.14},
    panelBorder = {0.3, 0.2, 0.35},
    button = {0.15, 0.1, 0.2},
    buttonHover = {0.25, 0.15, 0.3},
    buttonBorder = {0.5, 0.4, 0.6}
}

-- State
local deckCards = {}
local hoveredCard = nil
local hoveredDeckIndex = nil
local scrollOffset = 0
local mouseX, mouseY = 0, 0

local MAX_DECK_SIZE = 30
local MAX_COPIES = 2

local backButton = { x = 10, y = 10, width = 80, height = 30, hovered = false, pressed = false }

-- Get all available cards sorted by class and cost
local function getSortedCards()
    local sorted = {}
    for _, card in ipairs(cards.sampleCards) do
        table.insert(sorted, card)
    end
    table.sort(sorted, function(a, b)
        if a.cardClass ~= b.cardClass then return a.cardClass < b.cardClass end
        if a.cost ~= b.cost then return a.cost < b.cost end
        return a.name < b.name
    end)
    return sorted
end

local sortedCards = getSortedCards()

-- Count copies of a card in deck
local function countInDeck(cardId)
    local count = 0
    for _, c in ipairs(deckCards) do
        if c.id == cardId then count = count + 1 end
    end
    return count
end

-- Add card to deck
local function addToDeck(card)
    if #deckCards >= MAX_DECK_SIZE then return false end
    if countInDeck(card.id) >= MAX_COPIES then return false end
    table.insert(deckCards, cards.copy(card))
    return true
end

-- Remove card from deck by index
local function removeFromDeck(index)
    if index and index >= 1 and index <= #deckCards then
        table.remove(deckCards, index)
    end
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

function editor.load() end

function editor.enter()
    deckCards = {}
    scrollOffset = 0
    hoveredCard = nil
    hoveredDeckIndex = nil
end

function editor.exit() end

function editor.update(dt) end

function editor.draw()
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
    love.graphics.print("Deck Editor", w / 2 - 80, 15)
    
    -- Card browser panel (left side)
    local browserX, browserY = 20, 60
    local browserW, browserH = w * 0.55, h - 80
    
    love.graphics.setColor(colors.panel[1], colors.panel[2], colors.panel[3], 0.8)
    love.graphics.rectangle('fill', browserX, browserY, browserW, browserH, 8, 8)
    love.graphics.setColor(colors.panelBorder)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', browserX, browserY, browserW, browserH, 8, 8)
    
    -- Draw available cards
    local cardScale = 0.85
    local cardW = cardUI.CARD_WIDTH * cardScale
    local cardH = cardUI.CARD_HEIGHT * cardScale
    local cardsPerRow = math.floor((browserW - 30) / (cardW + 10))
    local startX = browserX + 15
    local startY = browserY + 15 - scrollOffset
    
    love.graphics.setScissor(browserX, browserY, browserW, browserH)
    for i, card in ipairs(sortedCards) do
        local col = (i - 1) % cardsPerRow
        local row = math.floor((i - 1) / cardsPerRow)
        local x = startX + col * (cardW + 10)
        local y = startY + row * (cardH + 10)
        
        if y + cardH > browserY and y < browserY + browserH then
            local canAdd = #deckCards < MAX_DECK_SIZE and countInDeck(card.id) < MAX_COPIES
            cardUI.draw(card, x, y, {
                scale = cardScale,
                hovered = hoveredCard == card,
                playable = canAdd
            })
        end
    end
    love.graphics.setScissor()
    
    -- Deck panel (right side)
    local deckX = browserX + browserW + 20
    local deckW = w - deckX - 20
    
    love.graphics.setColor(colors.panel[1], colors.panel[2], colors.panel[3], 0.8)
    love.graphics.rectangle('fill', deckX, browserY, deckW, browserH, 8, 8)
    love.graphics.setColor(colors.panelBorder)
    love.graphics.rectangle('line', deckX, browserY, deckW, browserH, 8, 8)
    
    -- Deck title
    local deckFont = love.graphics.newFont(18)
    love.graphics.setFont(deckFont)
    love.graphics.setColor(colors.text)
    love.graphics.print("Your Deck (" .. #deckCards .. "/" .. MAX_DECK_SIZE .. ")", deckX + 15, browserY + 10)
    
    -- Deck cards list
    local listY = browserY + 45
    local listFont = love.graphics.newFont(14)
    love.graphics.setFont(listFont)
    
    for i, card in ipairs(deckCards) do
        local y = listY + (i - 1) * 28
        if y < browserY + browserH - 20 then
            local isHovered = hoveredDeckIndex == i
            
            if isHovered then
                love.graphics.setColor(0.3, 0.2, 0.35, 0.5)
                love.graphics.rectangle('fill', deckX + 10, y - 2, deckW - 20, 26, 4, 4)
            end
            
            -- Cost badge
            love.graphics.setColor(0.2, 0.4, 0.8)
            love.graphics.circle('fill', deckX + 25, y + 10, 10)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(tostring(card.cost), deckX + 22, y + 2)
            
            -- Card name
            local scheme = cards.colorSchemes[card.cardClass] or cards.colorSchemes.neutral
            love.graphics.setColor(scheme.accent)
            love.graphics.print(card.name, deckX + 45, y + 2)
            
            -- Remove button
            if isHovered then
                love.graphics.setColor(0.9, 0.3, 0.3)
                love.graphics.print("X", deckX + deckW - 30, y + 2)
            end
        end
    end
    
    -- Back button
    drawButton(backButton, "Back")
    
    -- Tooltip
    if hoveredCard then
        tooltip.drawCard(hoveredCard, mouseX, mouseY)
    end
    
    -- Instructions
    love.graphics.setColor(colors.text[1], colors.text[2], colors.text[3], 0.5)
    local helpFont = love.graphics.newFont(12)
    love.graphics.setFont(helpFont)
    love.graphics.print("Click cards to add to deck. Click deck cards to remove.", 100, h - 25)
end

function editor.mousemoved(x, y)
    mouseX, mouseY = x, y
    local w, h = love.graphics.getDimensions()
    
    hoveredCard = nil
    hoveredDeckIndex = nil
    backButton.hovered = x >= backButton.x and x <= backButton.x + backButton.width and
                         y >= backButton.y and y <= backButton.y + backButton.height
    
    -- Check card browser
    local browserX, browserY = 20, 60
    local browserW = w * 0.55
    local cardScale = 0.85
    local cardW = cardUI.CARD_WIDTH * cardScale
    local cardH = cardUI.CARD_HEIGHT * cardScale
    local cardsPerRow = math.floor((browserW - 30) / (cardW + 10))
    local startX = browserX + 15
    local startY = browserY + 15 - scrollOffset
    
    for i, card in ipairs(sortedCards) do
        local col = (i - 1) % cardsPerRow
        local row = math.floor((i - 1) / cardsPerRow)
        local cx = startX + col * (cardW + 10)
        local cy = startY + row * (cardH + 10)
        
        if x >= cx and x <= cx + cardW and y >= cy and y <= cy + cardH and
           y >= browserY and y <= browserY + (h - 80) then
            hoveredCard = card
            break
        end
    end
    
    -- Check deck list
    local deckX = browserX + browserW + 20
    local deckW = w - deckX - 20
    local listY = browserY + 45
    
    for i = 1, #deckCards do
        local iy = listY + (i - 1) * 28
        if x >= deckX + 10 and x <= deckX + deckW - 10 and y >= iy - 2 and y <= iy + 24 then
            hoveredDeckIndex = i
            break
        end
    end
end

function editor.mousepressed(x, y, button)
    if button == 1 then
        if backButton.hovered then backButton.pressed = true end
    end
end

function editor.mousereleased(x, y, button)
    if button == 1 then
        if backButton.pressed and backButton.hovered then
            switchScene("battlecards_menu")
        end
        backButton.pressed = false
        
        if hoveredCard then
            addToDeck(hoveredCard)
        elseif hoveredDeckIndex then
            removeFromDeck(hoveredDeckIndex)
        end
    end
end

function editor.wheelmoved(x, y)
    scrollOffset = math.max(0, scrollOffset - y * 40)
end

function editor.keypressed(key)
    if key == "escape" then switchScene("battlecards_menu") end
end

function editor.resize() end

return editor

