-- Card Class
-- Represents a single card (playing card, joker, or consumable)
-- Handles rendering, animations, and interactions

local Enhancements = require("micatro.data.enhancements")
local Editions = require("micatro.data.editions")
local Seals = require("micatro.data.seals")
local Hands = require("micatro.data.hands")

local Card = {}
Card.__index = Card

-- Card types
Card.TYPE = {
    PLAYING = "playing",
    JOKER = "joker",
    TAROT = "tarot",
    PLANET = "planet",
    SPECTRAL = "spectral",
    VOUCHER = "voucher"
}

-- Create a new playing card
function Card.newPlaying(rank, suit, id)
    local card = setmetatable({
        type = Card.TYPE.PLAYING,
        id = id or 0,
        
        -- Base properties
        rank = rank,
        suit = suit,
        
        -- Modifiers
        enhancement = nil,  -- m_bonus, m_mult, etc.
        edition = nil,      -- e_foil, e_holo, etc.
        seal = nil,         -- Gold, Red, Blue, Purple
        
        -- Permanent bonuses (from Hiker, etc.)
        bonus_chips = 0,
        
        -- Stats
        times_played = 0,
        
        -- Visual state
        x = 0,
        y = 0,
        targetX = 0,
        targetY = 0,
        rotation = 0,
        rotationX = 0,  -- Tilt for 3D effect
        rotationY = 0,
        scale = 1,
        targetScale = 1,
        alpha = 1,
        
        -- Interaction state
        selected = false,
        hovered = false,
        dragging = false,
        dragOffsetX = 0,
        dragOffsetY = 0,
        
        -- Animation state
        isAnimating = false,
        animTimer = 0,
        highlighting = false,
        highlightTimer = 0,
        
        -- Area reference
        area = nil
        
    }, Card)
    
    return card
end

-- Create a new joker card
function Card.newJoker(jokerData)
    local card = setmetatable({
        type = Card.TYPE.JOKER,
        id = jokerData.order or 0,
        
        -- Joker data reference
        data = jokerData,
        
        -- Ability state (copied from config, can be modified)
        ability = {},
        
        -- Economy
        cost = jokerData.cost or 4,
        sell_value = math.floor((jokerData.cost or 4) / 2),
        
        -- Modifiers
        edition = nil,
        eternal = false,      -- Cannot be sold or destroyed
        perishable = false,   -- Debuffs after X rounds
        rental = false,       -- Costs $1 per round
        
        -- Visual state
        x = 0,
        y = 0,
        targetX = 0,
        targetY = 0,
        rotation = 0,
        rotationX = 0,
        rotationY = 0,
        scale = 1,
        targetScale = 1,
        alpha = 1,
        
        -- Interaction state
        selected = false,
        hovered = false,
        dragging = false,
        
        -- Animation state
        isAnimating = false,
        animTimer = 0,
        triggering = false,
        triggerTimer = 0,
        
        -- Area reference
        area = nil
        
    }, Card)
    
    -- Copy config to ability
    if jokerData.config then
        for k, v in pairs(jokerData.config) do
            if type(v) == "table" then
                card.ability[k] = {}
                for k2, v2 in pairs(v) do
                    card.ability[k] = v2
                end
            else
                card.ability[k] = v
            end
        end
    end
    
    return card
end

-- Deep copy a table
local function deepCopy(original)
    if type(original) ~= "table" then
        return original
    end
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Create a new consumable card (tarot/planet/spectral)
function Card.newConsumable(consumableData)
    local cardType = Card.TYPE.TAROT
    if consumableData.set == "Planet" then
        cardType = Card.TYPE.PLANET
    elseif consumableData.set == "Spectral" then
        cardType = Card.TYPE.SPECTRAL
    end
    
    -- Deep copy the entire data structure to avoid any sharing
    local dataCopy = deepCopy(consumableData)
    
    -- Generate a unique ID from the key
    local uniqueId = 0
    if consumableData.key then
        -- Use a simple hash of the key to create a unique ID
        for i = 1, #consumableData.key do
            uniqueId = uniqueId + string.byte(consumableData.key, i) * i
        end
    else
        uniqueId = consumableData.order or 0
    end
    
    local card = setmetatable({
        type = cardType,
        -- Use hash of key as ID to ensure uniqueness
        id = uniqueId,
        
        -- Consumable data reference (store a deep copy to avoid sharing issues)
        data = dataCopy,
        
        -- Economy
        cost = consumableData.cost or 3,
        sell_value = math.floor((consumableData.cost or 3) / 2),
        
        -- Modifiers
        edition = nil,
        
        -- Visual state
        x = 0,
        y = 0,
        targetX = 0,
        targetY = 0,
        rotation = 0,
        rotationX = 0,
        rotationY = 0,
        scale = 1,
        targetScale = 1,
        alpha = 1,
        
        -- Interaction state
        selected = false,
        hovered = false,
        
        -- Animation state
        isAnimating = false,
        animTimer = 0,
        
        -- Area reference
        area = nil
        
    }, Card)
    
    return card
end

-- Update card state
function Card:update(dt)
    -- Smooth position interpolation
    local speed = 12
    self.x = self.x + (self.targetX - self.x) * speed * dt
    self.y = self.y + (self.targetY - self.y) * speed * dt
    
    -- Smooth scale interpolation
    self.scale = self.scale + (self.targetScale - self.scale) * 8 * dt
    
    -- Idle wobble when not hovered
    if not self.hovered and not self.dragging and not self.selected then
        local offset = self.id * 0.5
        local time = love.timer.getTime()
        self.rotationX = self.rotationX + (math.sin(time * 0.7 + offset) * 0.15 - self.rotationX) * 4 * dt
        self.rotationY = self.rotationY + (math.cos(time * 0.7 + offset) * 0.15 - self.rotationY) * 4 * dt
    end
    
    -- Highlight animation
    if self.highlighting then
        self.highlightTimer = self.highlightTimer + dt
        if self.highlightTimer > 0.3 then
            self.highlighting = false
            self.highlightTimer = 0
        end
    end
    
    -- Trigger animation (for jokers)
    if self.triggering then
        self.triggerTimer = self.triggerTimer + dt
        if self.triggerTimer > 0.2 then
            self.triggering = false
            self.triggerTimer = 0
        end
    end
end

-- Set position (instant)
function Card:setPosition(x, y)
    self.x = x
    self.y = y
    self.targetX = x
    self.targetY = y
end

-- Set target position (animated)
function Card:setTarget(x, y)
    self.targetX = x
    self.targetY = y
end

-- Check if point is inside card
function Card:containsPoint(px, py, width, height)
    width = width or 71
    height = height or 95
    local halfW = width * self.scale / 2
    local halfH = height * self.scale / 2
    return px >= self.x - halfW and px <= self.x + halfW and
           py >= self.y - halfH and py <= self.y + halfH
end

-- Handle hover enter
function Card:onHoverEnter()
    self.hovered = true
    self.targetScale = 1.1
end

-- Handle hover exit
function Card:onHoverExit()
    self.hovered = false
    if not self.selected then
        self.targetScale = 1
    end
end

-- Handle selection
function Card:select()
    self.selected = true
    self.targetScale = 1.15
end

-- Handle deselection
function Card:deselect()
    self.selected = false
    self.targetScale = self.hovered and 1.1 or 1
end

-- Toggle selection
function Card:toggleSelect()
    if self.selected then
        self:deselect()
    else
        self:select()
    end
end

-- Start highlight animation (when scoring)
function Card:highlight()
    self.highlighting = true
    self.highlightTimer = 0
end

-- Start trigger animation (for jokers)
function Card:trigger()
    self.triggering = true
    self.triggerTimer = 0
end

-- Get chip value for this card
function Card:getChipValue()
    if self.type ~= Card.TYPE.PLAYING then return 0 end
    
    -- Stone cards don't contribute rank chips
    if self.enhancement == "m_stone" then
        return 50
    end
    
    local value = Hands.RANK_VALUES[self.rank] or 0
    
    -- Add permanent bonus
    value = value + self.bonus_chips
    
    -- Add enhancement bonus
    if self.enhancement then
        local enh = Enhancements.get(self.enhancement)
        if enh and enh.config and enh.config.bonus then
            value = value + enh.config.bonus
        end
    end
    
    -- Add foil edition bonus
    if self.edition == "e_foil" then
        local ed = Editions.get(self.edition)
        if ed and ed.config and ed.config.extra then
            value = value + ed.config.extra
        end
    end
    
    return value
end

-- Get mult value for this card
function Card:getMultValue()
    if self.type ~= Card.TYPE.PLAYING then return 0, 1 end
    
    local mult = 0
    local xmult = 1
    
    -- Enhancement mult
    if self.enhancement then
        local enh = Enhancements.get(self.enhancement)
        if enh and enh.config then
            if enh.config.mult then
                mult = mult + enh.config.mult
            end
            if enh.config.Xmult then
                xmult = xmult * enh.config.Xmult
            end
        end
    end
    
    -- Holographic edition
    if self.edition == "e_holo" then
        local ed = Editions.get(self.edition)
        if ed and ed.config and ed.config.extra then
            mult = mult + ed.config.extra
        end
    end
    
    -- Polychrome edition
    if self.edition == "e_polychrome" then
        local ed = Editions.get(self.edition)
        if ed and ed.config and ed.config.extra then
            xmult = xmult * ed.config.extra
        end
    end
    
    return mult, xmult
end

-- Apply enhancement
function Card:setEnhancement(enhancementKey)
    if self.type ~= Card.TYPE.PLAYING then return end
    self.enhancement = enhancementKey
end

-- Apply edition
function Card:setEdition(editionKey)
    self.edition = editionKey
end

-- Apply seal
function Card:setSeal(sealKey)
    if self.type ~= Card.TYPE.PLAYING then return end
    self.seal = sealKey
end

-- Check if card is a face card
function Card:isFace()
    return self.rank == "J" or self.rank == "Q" or self.rank == "K"
end

-- Check if card has even rank
function Card:isEven()
    local num = tonumber(self.rank)
    return num and num % 2 == 0
end

-- Check if card has odd rank
function Card:isOdd()
    local num = tonumber(self.rank)
    if num then
        return num % 2 == 1
    end
    return self.rank == "A"
end

-- Get effective suits (accounting for wild card)
function Card:getSuits()
    if self.enhancement == "m_wild" then
        return {"Hearts", "Diamonds", "Clubs", "Spades"}
    end
    return {self.suit}
end

-- Check if card matches a suit
function Card:matchesSuit(suit)
    local suits = self:getSuits()
    for _, s in ipairs(suits) do
        if s == suit then return true end
    end
    return false
end

-- Get display name
function Card:getName()
    if self.type == Card.TYPE.PLAYING then
        return self.rank .. " of " .. self.suit
    elseif self.data then
        return self.data.name
    end
    return "Card"
end

-- Get shader name for edition
function Card:getShader()
    if self.edition then
        local ed = Editions.get(self.edition)
        if ed then
            return ed.shader
        end
    end
    return nil
end

-- Create a copy of this card
function Card:copy()
    if self.type == Card.TYPE.PLAYING then
        local copy = Card.newPlaying(self.rank, self.suit, 0)
        copy.enhancement = self.enhancement
        copy.edition = self.edition
        copy.seal = self.seal
        copy.bonus_chips = self.bonus_chips
        return copy
    elseif self.type == Card.TYPE.JOKER then
        local copy = Card.newJoker(self.data)
        copy.edition = self.edition
        copy.eternal = self.eternal
        copy.perishable = self.perishable
        copy.rental = self.rental
        for k, v in pairs(self.ability) do
            copy.ability[k] = v
        end
        return copy
    elseif self.data then
        local copy = Card.newConsumable(self.data)
        copy.edition = self.edition
        return copy
    end
    return nil
end

return Card

