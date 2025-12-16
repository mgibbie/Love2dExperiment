-- Card Area
-- Manages a collection of cards in a specific layout
-- Used for hand, play area, jokers, consumables, shop, etc.

local Card = require("micatro.core.card")

local CardArea = {}
CardArea.__index = CardArea

-- Area types with different layouts
CardArea.TYPE = {
    HAND = "hand",           -- Fan layout, selectable
    PLAY = "play",           -- Centered, scoring display
    JOKER = "joker",         -- Horizontal row, fixed slots
    CONSUMABLE = "consumable", -- Small horizontal row
    SHOP = "shop",           -- Grid layout
    DECK = "deck"            -- Stacked pile
}

-- Create a new card area
function CardArea.new(areaType, config)
    config = config or {}
    
    local area = setmetatable({
        type = areaType,
        cards = {},
        
        -- Position and size
        x = config.x or 0,
        y = config.y or 0,
        width = config.width or 600,
        height = config.height or 150,
        
        -- Layout configuration
        cardWidth = config.cardWidth or 71,
        cardHeight = config.cardHeight or 95,
        spacing = config.spacing or 10,
        maxCards = config.maxCards or 8,
        
        -- Selection
        maxSelected = config.maxSelected or 5,
        selectedCount = 0,
        
        -- Visual settings
        showSlots = config.showSlots or false,
        slotColor = config.slotColor or {0.2, 0.2, 0.3, 0.5},
        
        -- Dragging state
        allowDrag = config.allowDrag or false,
        draggedCard = nil,
        dragOffsetX = 0,
        dragOffsetY = 0,
        dragOriginalIndex = nil,
        dropIndicatorIndex = nil,
        
        -- Pending drag (waiting for mouse movement to confirm drag)
        pendingDragCard = nil,
        pendingDragX = 0,
        pendingDragY = 0,
        dragThreshold = 8,  -- Pixels to move before drag starts
        
        -- Layout update protection
        updatingLayout = false,  -- Flag to prevent recursive calls
        layoutCache = nil  -- Cache last layout calculation
        
    }, CardArea)
    
    return area
end

-- Add a card to the area
function CardArea:addCard(card, index)
    if not card then
        print("WARNING: Attempted to add nil card to area")
        return false
    end
    
    if #self.cards >= self.maxCards then
        return false
    end
    
    card.area = self
    
    if index then
        if index < 1 or index > #self.cards + 1 then
            print("WARNING: Invalid index for addCard: " .. tostring(index))
            index = nil
        end
    end
    
    if index then
        table.insert(self.cards, index, card)
    else
        table.insert(self.cards, card)
    end
    
    self:updateLayout()
    return true
end

-- Remove a card from the area
function CardArea:removeCard(card)
    for i, c in ipairs(self.cards) do
        if c == card then
            -- If the card was selected, decrement selectedCount
            if card.selected then
                self.selectedCount = math.max(0, self.selectedCount - 1)
                card.selected = false
            end
            table.remove(self.cards, i)
            card.area = nil
            self:updateLayout()
            return true
        end
    end
    return false
end

-- Remove card by ID
function CardArea:removeCardById(id)
    for i, c in ipairs(self.cards) do
        if c.id == id then
            local card = table.remove(self.cards, i)
            card.area = nil
            self:updateLayout()
            return card
        end
    end
    return nil
end

-- Remove card by index
function CardArea:removeCardAt(index)
    if index > 0 and index <= #self.cards then
        local card = table.remove(self.cards, index)
        card.area = nil
        self:updateLayout()
        return card
    end
    return nil
end

-- Get card index
function CardArea:getCardIndex(card)
    for i, c in ipairs(self.cards) do
        if c == card then
            return i
        end
    end
    return nil
end

-- Move card from one index to another
function CardArea:moveCard(fromIndex, toIndex)
    if fromIndex < 1 or fromIndex > #self.cards then return false end
    if toIndex < 1 or toIndex > #self.cards then return false end
    if fromIndex == toIndex then return true end
    
    local card = table.remove(self.cards, fromIndex)
    table.insert(self.cards, toIndex, card)
    self:updateLayout()
    return true
end

-- Get all cards
function CardArea:getCards()
    return self.cards
end

-- Get card count
function CardArea:count()
    return #self.cards
end

-- Check if area is full
function CardArea:isFull()
    return #self.cards >= self.maxCards
end

-- Check if area has room
function CardArea:hasRoom()
    return #self.cards < self.maxCards
end

-- Get selected cards
function CardArea:getSelected()
    local selected = {}
    for _, card in ipairs(self.cards) do
        if card.selected then
            table.insert(selected, card)
        end
    end
    return selected
end

-- Get selected card IDs
function CardArea:getSelectedIds()
    local ids = {}
    for _, card in ipairs(self.cards) do
        if card.selected then
            table.insert(ids, card.id)
        end
    end
    return ids
end

-- Select a card
function CardArea:selectCard(card)
    if card.selected then return true end
    
    if self.selectedCount >= self.maxSelected then
        return false
    end
    
    card:select()
    self.selectedCount = self.selectedCount + 1
    self:updateLayout()
    return true
end

-- Deselect a card
function CardArea:deselectCard(card)
    if not card.selected then return end
    
    card:deselect()
    self.selectedCount = math.max(0, self.selectedCount - 1)
    self:updateLayout()
end

-- Toggle card selection
function CardArea:toggleCardSelection(card)
    if card.selected then
        self:deselectCard(card)
    else
        self:selectCard(card)
    end
end

-- Deselect all cards
function CardArea:deselectAll()
    for _, card in ipairs(self.cards) do
        card:deselect()
    end
    self.selectedCount = 0
    self:updateLayout()
end

-- ===== DRAG AND DROP SYSTEM =====

-- Start dragging a card
function CardArea:startDrag(card, mouseX, mouseY)
    if not self.allowDrag then return false end
    if not card then return false end
    
    -- Prevent drag during animations
    if card.animatingAway then return false end
    
    self.draggedCard = card
    self.dragOffsetX = (card.x or 0) - mouseX
    self.dragOffsetY = (card.y or 0) - mouseY
    self.dragOriginalIndex = self:getCardIndex(card)
    card.dragging = true
    card.scale = 1.1  -- Slightly enlarge dragged card
    
    return true
end

-- Update drag position
function CardArea:updateDrag(mouseX, mouseY)
    if not self.draggedCard then return end
    
    local card = self.draggedCard
    card.x = mouseX + self.dragOffsetX
    card.y = mouseY + self.dragOffsetY
    
    -- Calculate where the card would drop
    self.dropIndicatorIndex = self:getDropIndex(mouseX)
end

-- Calculate which index card would drop at based on X position
function CardArea:getDropIndex(mouseX)
    if #self.cards <= 1 then return 1 end
    
    local cardCount = #self.cards
    local totalWidth = (cardCount - 1) * (self.cardWidth + self.spacing) + self.cardWidth
    local startX = self.x + (self.width - totalWidth) / 2 + self.cardWidth / 2
    
    for i = 1, cardCount do
        local cardCenterX = startX + (i - 1) * (self.cardWidth + self.spacing)
        if mouseX < cardCenterX then
            return i
        end
    end
    
    return cardCount
end

-- End drag and drop card
function CardArea:endDrag()
    if not self.draggedCard then return end
    
    local card = self.draggedCard
    card.dragging = false
    card.scale = 1.0
    
    local newIndex = self.dropIndicatorIndex or self.dragOriginalIndex
    local oldIndex = self.dragOriginalIndex
    
    if newIndex and oldIndex and newIndex ~= oldIndex then
        -- Remove from old position
        table.remove(self.cards, oldIndex)
        
        -- Adjust index if necessary
        if newIndex > oldIndex then
            newIndex = newIndex - 1
        end
        
        -- Insert at new position
        table.insert(self.cards, newIndex, card)
    end
    
    self.draggedCard = nil
    self.dragOffsetX = 0
    self.dragOffsetY = 0
    self.dragOriginalIndex = nil
    self.dropIndicatorIndex = nil
    
    self:updateLayout()
end

-- Cancel drag without moving
function CardArea:cancelDrag()
    if not self.draggedCard then return end
    
    self.draggedCard.dragging = false
    self.draggedCard.scale = 1.0
    self.draggedCard = nil
    self.dragOffsetX = 0
    self.dragOffsetY = 0
    self.dragOriginalIndex = nil
    self.dropIndicatorIndex = nil
    
    self:updateLayout()
end

-- Check if currently dragging
function CardArea:isDragging()
    return self.draggedCard ~= nil
end

-- ===== LAYOUT FUNCTIONS =====

-- Update layout positions
function CardArea:updateLayout()
    -- Prevent recursive calls
    if self.updatingLayout then
        return
    end
    
    local cardCount = #self.cards
    if cardCount == 0 then 
        self.layoutCache = nil
        return 
    end
    
    -- Build cache key that includes selection state and card order
    local selectionHash = ""
    local orderHash = ""
    for i, card in ipairs(self.cards) do
        selectionHash = selectionHash .. (card.selected and "1" or "0")
        -- Include card identity in order hash to detect sorting
        -- Use card ID if available, otherwise use rank+suit for playing cards, or object identity
        local cardIdentity = card.id
        if not cardIdentity or cardIdentity == 0 then
            if card.rank and card.suit then
                cardIdentity = card.rank .. card.suit
            else
                cardIdentity = tostring(card)  -- Fallback to object identity
            end
        end
        orderHash = orderHash .. tostring(cardIdentity) .. "_"
    end
    
    local cacheKey = cardCount .. "_" .. self.type .. "_" .. self.width .. "_" .. self.height .. "_" .. selectionHash .. "_" .. orderHash
    if self.layoutCache == cacheKey then
        return  -- Layout hasn't changed, skip update
    end
    
    self.updatingLayout = true
    
    -- Wrap in pcall for safety
    local success, err = pcall(function()
        if self.type == CardArea.TYPE.HAND then
            self:layoutHand()
        elseif self.type == CardArea.TYPE.PLAY then
            self:layoutCentered()
        elseif self.type == CardArea.TYPE.JOKER or self.type == CardArea.TYPE.CONSUMABLE then
            self:layoutRow()
        elseif self.type == CardArea.TYPE.SHOP then
            self:layoutGrid()
        elseif self.type == CardArea.TYPE.DECK then
            self:layoutStacked()
        end
    end)
    
    if not success then
        print("ERROR in updateLayout: " .. tostring(err))
    else
        -- Update cache
        self.layoutCache = cacheKey
    end
    
    self.updatingLayout = false
end

-- Hand layout (cards fan out, selected cards rise)
function CardArea:layoutHand()
    local cardCount = #self.cards
    local totalWidth = (cardCount - 1) * (self.cardWidth + self.spacing) + self.cardWidth
    local startX = self.x + (self.width - totalWidth) / 2 + self.cardWidth / 2
    
    for i, card in ipairs(self.cards) do
        -- Skip dragged card positioning
        if card.dragging then
            goto continue
        end
        
        local x = startX + (i - 1) * (self.cardWidth + self.spacing)
        local y = self.y + self.height / 2
        
        -- Make room for drop indicator
        if self.draggedCard and self.dropIndicatorIndex then
            local draggedIndex = self.dragOriginalIndex
            if i >= self.dropIndicatorIndex and (draggedIndex == nil or i < draggedIndex) then
                x = x + self.cardWidth / 2
            elseif i < self.dropIndicatorIndex and (draggedIndex == nil or i >= draggedIndex) then
                -- Cards shift left
            end
        end
        
        -- Selected cards rise up
        if card.selected then
            y = y - 25
        end
        
        card:setTarget(x, y)
        
        ::continue::
    end
end

-- Centered layout (for play area)
function CardArea:layoutCentered()
    local cardCount = #self.cards
    local gap = math.min(self.spacing, (self.width - self.cardWidth * cardCount) / math.max(1, cardCount - 1))
    local totalWidth = (cardCount - 1) * (self.cardWidth + gap) + self.cardWidth
    local startX = self.x + (self.width - totalWidth) / 2 + self.cardWidth / 2
    
    for i, card in ipairs(self.cards) do
        if not card.dragging then
            local x = startX + (i - 1) * (self.cardWidth + gap)
            local y = self.y + self.height / 2
            card:setTarget(x, y)
        end
    end
end

-- Row layout (for jokers and consumables)
function CardArea:layoutRow()
    local startX = self.x + self.cardWidth / 2 + 10
    
    for i, card in ipairs(self.cards) do
        if not card.dragging then
            local x = startX + (i - 1) * (self.cardWidth + self.spacing)
            local y = self.y + self.height / 2
            card:setTarget(x, y)
        end
    end
end

-- Grid layout (for shop)
function CardArea:layoutGrid()
    local cols = math.floor(self.width / (self.cardWidth + self.spacing))
    local startX = self.x + self.cardWidth / 2 + 10
    local startY = self.y + self.cardHeight / 2 + 10
    
    for i, card in ipairs(self.cards) do
        if not card.dragging then
            local col = (i - 1) % cols
            local row = math.floor((i - 1) / cols)
            local x = startX + col * (self.cardWidth + self.spacing)
            local y = startY + row * (self.cardHeight + self.spacing + 20)
            card:setTarget(x, y)
        end
    end
end

-- Stacked layout (for deck display)
function CardArea:layoutStacked()
    local x = self.x + self.width / 2
    local y = self.y + self.height / 2
    
    for i, card in ipairs(self.cards) do
        if not card.dragging then
            local offset = math.min(i - 1, 5) * 0.5
            card:setTarget(x + offset, y - offset)
        end
    end
end

-- Update all cards
function CardArea:update(dt)
    for _, card in ipairs(self.cards) do
        -- Don't update target for dragged cards
        if not card.dragging then
            card:update(dt)
        else
            -- Still update other properties
            card.rotation = card.rotation + (0 - card.rotation) * (1 - math.exp(-10 * dt))
        end
    end
end

-- Find card at position
function CardArea:getCardAt(x, y)
    -- Check in reverse order (top cards first)
    -- Only check cards that are actually in this area and not being animated away
    for i = #self.cards, 1, -1 do
        local card = self.cards[i]
        -- Verify card is still in this area and not being animated away
        if card.area == self and not card.animatingAway and card:containsPoint(x, y, self.cardWidth, self.cardHeight) then
            return card, i
        end
    end
    return nil
end

-- Handle mouse movement
function CardArea:onMouseMoved(x, y)
    -- Check if we should start dragging (pending drag + moved past threshold)
    if self.pendingDragCard and not self.draggedCard then
        local dx = x - self.pendingDragX
        local dy = y - self.pendingDragY
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist >= self.dragThreshold then
            -- Start actual drag
            self:startDrag(self.pendingDragCard, self.pendingDragX, self.pendingDragY)
            self.pendingDragCard = nil
            self:updateDrag(x, y)
            return
        end
    end
    
    -- Handle active dragging
    if self.draggedCard then
        self:updateDrag(x, y)
        return
    end
    
    for _, card in ipairs(self.cards) do
        -- Skip cards that are being animated away
        if not card.animatingAway then
            local wasHovered = card.hovered
            local isHovered = card:containsPoint(x, y, self.cardWidth, self.cardHeight)
            
            if isHovered and not wasHovered then
                card:onHoverEnter()
            elseif not isHovered and wasHovered then
                card:onHoverExit()
            end
        end
        
        -- Update tilt based on mouse position when hovered
        if card.hovered and not card.dragging then
            local offsetX = (x - card.x) / (self.cardWidth / 2)
            local offsetY = (y - card.y) / (self.cardHeight / 2)
            local maxTilt = 0.4
            card.rotationY = card.rotationY + (-offsetX * maxTilt - card.rotationY) * 0.3
            card.rotationX = card.rotationX + (offsetY * maxTilt - card.rotationX) * 0.3
        end
    end
end

-- Handle mouse pressed - records potential drag start
function CardArea:onMousePressed(x, y, button)
    if button ~= 1 then return nil end
    
    local card, index = self:getCardAt(x, y)
    if card then
        if self.allowDrag then
            -- Don't start drag yet - wait for mouse movement
            self.pendingDragCard = card
            self.pendingDragX = x
            self.pendingDragY = y
        end
        return card
    end
    return nil
end

-- Handle mouse released
function CardArea:onMouseReleased(x, y, button)
    if button ~= 1 then return false end
    
    -- If we were dragging, end the drag
    if self.draggedCard then
        self:endDrag()
        return true
    end
    
    -- If we had a pending drag that never started, treat as click
    if self.pendingDragCard then
        local card = self.pendingDragCard
        self.pendingDragCard = nil
        -- Toggle selection on the card
        self:toggleCardSelection(card)
        return true
    end
    
    return false
end

-- Handle click (for selection) - fallback for areas without drag
function CardArea:onClick(x, y)
    local card = self:getCardAt(x, y)
    if card then
        self:toggleCardSelection(card)
        return card
    end
    return nil
end

-- ===== SORTING FUNCTIONS =====

-- Sort cards by suit
function CardArea:sortBySuit()
    local suitOrder = {Spades = 1, Hearts = 2, Clubs = 3, Diamonds = 4}
    local rankOrder = {A = 14, K = 13, Q = 12, J = 11}
    
    table.sort(self.cards, function(a, b)
        local aSuit = suitOrder[a.suit] or 5
        local bSuit = suitOrder[b.suit] or 5
        
        if aSuit == bSuit then
            local aRank = rankOrder[a.rank] or tonumber(a.rank) or 0
            local bRank = rankOrder[b.rank] or tonumber(b.rank) or 0
            return aRank > bRank
        end
        
        return aSuit < bSuit
    end)
    
    self:updateLayout()
end

-- Sort cards by rank
function CardArea:sortByRank()
    local rankOrder = {A = 14, K = 13, Q = 12, J = 11}
    local suitOrder = {Spades = 1, Hearts = 2, Clubs = 3, Diamonds = 4}
    
    table.sort(self.cards, function(a, b)
        local aRank = rankOrder[a.rank] or tonumber(a.rank) or 0
        local bRank = rankOrder[b.rank] or tonumber(b.rank) or 0
        
        if aRank == bRank then
            local aSuit = suitOrder[a.suit] or 5
            local bSuit = suitOrder[b.suit] or 5
            return aSuit < bSuit
        end
        
        return aRank > bRank
    end)
    
    self:updateLayout()
end

-- Shuffle cards
function CardArea:shuffle()
    for i = #self.cards, 2, -1 do
        local j = math.random(i)
        self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
    end
    self:updateLayout()
end

-- Clear all cards
function CardArea:clear()
    for _, card in ipairs(self.cards) do
        card.area = nil
    end
    self.cards = {}
    self.selectedCount = 0
    self:cancelDrag()  -- Cancel any active drag
end

-- Move cards to another area
function CardArea:moveCardsTo(targetArea, cards)
    cards = cards or self:getSelected()
    local moved = {}
    
    for _, card in ipairs(cards) do
        if targetArea:hasRoom() then
            self:removeCard(card)
            targetArea:addCard(card)
            table.insert(moved, card)
        end
    end
    
    return moved
end

-- Move all cards to another area
function CardArea:moveAllTo(targetArea)
    local moved = {}
    while #self.cards > 0 and targetArea:hasRoom() do
        local card = self:removeCardAt(1)
        if card then
            targetArea:addCard(card)
            table.insert(moved, card)
        end
    end
    return moved
end

-- Draw drop indicator
function CardArea:drawDropIndicator()
    if not self.draggedCard or not self.dropIndicatorIndex then return end
    
    local cardCount = #self.cards
    local totalWidth = (cardCount - 1) * (self.cardWidth + self.spacing) + self.cardWidth
    local startX = self.x + (self.width - totalWidth) / 2 + self.cardWidth / 2
    
    local indicatorX = startX + (self.dropIndicatorIndex - 1) * (self.cardWidth + self.spacing)
    indicatorX = indicatorX - self.cardWidth / 2 - 2
    
    local indicatorY = self.y + self.height / 2 - self.cardHeight / 2
    
    -- Draw vertical line indicator
    love.graphics.setColor(0.3, 0.6, 1, 0.8)
    love.graphics.setLineWidth(4)
    love.graphics.line(indicatorX, indicatorY, indicatorX, indicatorY + self.cardHeight)
end

return CardArea
