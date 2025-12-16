-- Game State Manager
-- Manages all run state, deck, jokers, consumables, and progression

local Hands = require("micatro.data.hands")
local Decks = require("micatro.data.decks")

local M = {}

-- Default game configuration
M.DEFAULT_CONFIG = {
    starting_money = 4,
    starting_hands = 4,
    starting_discards = 3,
    hand_size = 8,
    joker_slots = 5,
    consumable_slots = 2,
    interest_cap = 25,
    max_interest_rate = 5,
    deck_size = 52
}

-- Create a new game state
function M.new(deckKey)
    local state = {
        -- Run progression
        ante = 1,
        round = 1,
        
        -- Economy
        money = M.DEFAULT_CONFIG.starting_money,
        interest_cap = M.DEFAULT_CONFIG.interest_cap,
        
        -- Per-round resources
        hands_remaining = M.DEFAULT_CONFIG.starting_hands,
        discards_remaining = M.DEFAULT_CONFIG.starting_discards,
        hands_per_round = M.DEFAULT_CONFIG.starting_hands,
        discards_per_round = M.DEFAULT_CONFIG.starting_discards,
        
        -- Hand management
        hand_size = M.DEFAULT_CONFIG.hand_size,
        
        -- Current score
        chips = 0,
        blind_chips = 0,  -- Target to beat
        
        -- Deck
        deck = {},           -- Full deck definition
        draw_pile = {},      -- Cards to draw from
        hand = {},           -- Current hand
        played = {},         -- Cards currently in play area
        discard_pile = {},   -- Discarded cards
        
        -- Jokers and consumables
        joker_slots = M.DEFAULT_CONFIG.joker_slots,
        consumable_slots = M.DEFAULT_CONFIG.consumable_slots,
        jokers = {},
        consumables = {},
        
        -- Vouchers owned
        vouchers = {},
        
        -- Hand levels (for planet cards)
        hand_levels = {},
        
        -- Play counts
        hands_played = {},       -- Times each hand type played this run
        hands_played_round = {}, -- Times each hand type played this round
        
        -- Statistics
        cards_played = 0,
        cards_discarded = 0,
        dollars_earned = 0,
        
        -- Deck type
        deck_type = deckKey or "b_red",
        
        -- Game flags
        is_boss_blind = false,
        current_blind = nil,
        blinds_skipped = 0,
        
        -- Last used consumables (for The Fool)
        last_tarot = nil,
        last_planet = nil
    }
    
    -- Initialize hand levels
    for handName, _ in pairs(Hands.HANDS) do
        state.hand_levels[handName] = 1
        state.hands_played[handName] = 0
        state.hands_played_round[handName] = 0
    end
    
    -- Apply deck bonuses
    M.applyDeckConfig(state)
    
    -- Create the deck
    M.createDeck(state)
    
    return state
end

-- Apply deck configuration bonuses
function M.applyDeckConfig(state)
    local deck = Decks.get(state.deck_type)
    if not deck or not deck.config then return end
    
    local config = deck.config
    
    if config.hands then
        state.hands_per_round = state.hands_per_round + config.hands
        state.hands_remaining = state.hands_remaining + config.hands
    end
    
    if config.discards then
        state.discards_per_round = state.discards_per_round + config.discards
        state.discards_remaining = state.discards_remaining + config.discards
    end
    
    if config.dollars then
        state.money = state.money + config.dollars
    end
    
    if config.hand_size then
        state.hand_size = state.hand_size + config.hand_size
    end
    
    if config.joker_slot then
        state.joker_slots = state.joker_slots + config.joker_slot
    end
    
    if config.consumable_slot then
        state.consumable_slots = state.consumable_slots + config.consumable_slot
    end
end

-- Create a standard 52-card deck
function M.createDeck(state)
    state.deck = {}
    
    local suits = {"Hearts", "Diamonds", "Clubs", "Spades"}
    local ranks = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}
    
    local deck_config = Decks.get(state.deck_type)
    
    -- Check for special deck modifications
    local remove_faces = deck_config and deck_config.config and deck_config.config.remove_faces
    local only_suits = deck_config and deck_config.config and deck_config.config.only_suits
    
    local id = 1
    for _, suit in ipairs(suits) do
        -- Skip suits not in only_suits list if specified
        local include_suit = true
        if only_suits then
            include_suit = false
            for _, allowed in ipairs(only_suits) do
                if suit == allowed then
                    include_suit = true
                    break
                end
            end
        end
        
        if include_suit then
            for _, rank in ipairs(ranks) do
                -- Skip face cards if remove_faces
                local is_face = (rank == "J" or rank == "Q" or rank == "K")
                if not (remove_faces and is_face) then
                    local card = {
                        id = id,
                        rank = rank,
                        suit = suit,
                        enhancement = nil,  -- m_bonus, m_mult, etc.
                        edition = nil,      -- e_foil, e_holo, etc.
                        seal = nil,         -- Gold, Red, Blue, Purple
                        bonus_chips = 0,    -- Permanent chip bonus from Hiker, etc.
                        times_played = 0
                    }
                    table.insert(state.deck, card)
                    id = id + 1
                end
            end
        end
    end
    
    -- For checkered deck, double up on Spades and Hearts
    if only_suits and #only_suits == 2 then
        local extra_cards = {}
        for _, card in ipairs(state.deck) do
            local copy = {}
            for k, v in pairs(card) do copy[k] = v end
            copy.id = id
            id = id + 1
            table.insert(extra_cards, copy)
        end
        for _, card in ipairs(extra_cards) do
            table.insert(state.deck, card)
        end
    end
end

-- Shuffle and reset for a new round
function M.startRound(state)
    -- Reset round-specific counters
    state.hands_remaining = state.hands_per_round
    state.discards_remaining = state.discards_per_round
    state.chips = 0
    
    -- Reset hands played this round
    for handName, _ in pairs(state.hands_played_round) do
        state.hands_played_round[handName] = 0
    end
    
    -- Put all cards back into draw pile
    state.draw_pile = {}
    state.hand = {}
    state.played = {}
    state.discard_pile = {}
    
    for _, card in ipairs(state.deck) do
        table.insert(state.draw_pile, card)
    end
    
    -- Shuffle
    M.shuffle(state.draw_pile)
    
    -- Draw initial hand
    M.drawToHandSize(state)
end

-- Shuffle a table in place
function M.shuffle(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

-- Draw cards until hand is at hand_size
function M.drawToHandSize(state)
    while #state.hand < state.hand_size and #state.draw_pile > 0 do
        local card = table.remove(state.draw_pile, 1)
        table.insert(state.hand, card)
    end
end

-- Draw specific number of cards
function M.drawCards(state, count)
    local drawn = {}
    for i = 1, count do
        if #state.draw_pile > 0 then
            local card = table.remove(state.draw_pile, 1)
            table.insert(state.hand, card)
            table.insert(drawn, card)
        end
    end
    return drawn
end

-- Play selected cards (move from hand to played)
function M.playCards(state, cardIds)
    local played = {}
    for _, id in ipairs(cardIds) do
        for i, card in ipairs(state.hand) do
            if card.id == id then
                table.remove(state.hand, i)
                table.insert(state.played, card)
                table.insert(played, card)
                card.times_played = card.times_played + 1
                state.cards_played = state.cards_played + 1
                break
            end
        end
    end
    return played
end

-- Discard selected cards
function M.discardCards(state, cardIds)
    local discarded = {}
    for _, id in ipairs(cardIds) do
        for i, card in ipairs(state.hand) do
            if card.id == id then
                table.remove(state.hand, i)
                table.insert(state.discard_pile, card)
                table.insert(discarded, card)
                state.cards_discarded = state.cards_discarded + 1
                break
            end
        end
    end
    return discarded
end

-- Move played cards to discard
function M.discardPlayed(state)
    for _, card in ipairs(state.played) do
        table.insert(state.discard_pile, card)
    end
    state.played = {}
end

-- Add a joker to the collection
function M.addJoker(state, jokerData)
    if #state.jokers >= state.joker_slots then
        return false, "No room for joker"
    end
    
    local joker = {
        data = jokerData,
        ability = {},
        sell_value = math.floor(jokerData.cost / 2),
        edition = nil,
        eternal = false,
        perishable = false,
        rental = false
    }
    
    -- Copy config to ability
    if jokerData.config then
        for k, v in pairs(jokerData.config) do
            if type(v) == "table" then
                joker.ability[k] = {}
                for k2, v2 in pairs(v) do
                    joker.ability[k2] = v2
                end
            else
                joker.ability[k] = v
            end
        end
    end
    
    table.insert(state.jokers, joker)
    return true
end

-- Deep copy helper
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

-- Add a consumable
function M.addConsumable(state, consumableData)
    if #state.consumables >= state.consumable_slots then
        return false, "No room for consumable"
    end
    
    -- Deep copy the data to avoid sharing issues
    local dataCopy = deepCopy(consumableData)
    
    local consumable = {
        data = dataCopy,
        edition = nil
    }
    
    table.insert(state.consumables, consumable)
    return true
end

-- Use a consumable
function M.useConsumable(state, index)
    if index > 0 and index <= #state.consumables then
        local consumable = table.remove(state.consumables, index)
        
        -- Track for The Fool
        if consumable.data.set == "Tarot" then
            state.last_tarot = consumable.data.key
        elseif consumable.data.set == "Planet" then
            state.last_planet = consumable.data.key
        end
        
        return consumable
    end
    return nil
end

-- Level up a hand type
function M.levelUpHand(state, handName, levels)
    levels = levels or 1
    if state.hand_levels[handName] then
        state.hand_levels[handName] = state.hand_levels[handName] + levels
        return true
    end
    return false
end

-- Get chips and mult for a hand at current level
function M.getHandValue(state, handName)
    local level = state.hand_levels[handName] or 1
    return Hands.getHandValue(handName, level)
end

-- Add money
function M.addMoney(state, amount)
    state.money = state.money + amount
    if amount > 0 then
        state.dollars_earned = state.dollars_earned + amount
    end
end

-- Spend money
function M.spendMoney(state, amount)
    if state.money >= amount then
        state.money = state.money - amount
        return true
    end
    return false
end

-- Calculate interest at end of round
function M.calculateInterest(state)
    local interest = math.floor(state.money / 5)
    interest = math.min(interest, state.interest_cap / 5)
    return interest
end

-- Progress to next blind
function M.nextBlind(state)
    state.round = state.round + 1
    
    -- Every 3 blinds = 1 ante
    if state.round > 3 then
        state.round = 1
        state.ante = state.ante + 1
    end
end

-- Check if current blind is boss
function M.isBossBlind(state)
    return state.round == 3
end

-- Get save data
function M.getSaveData(state)
    return {
        ante = state.ante,
        round = state.round,
        money = state.money,
        deck_type = state.deck_type,
        hand_levels = state.hand_levels,
        hands_played = state.hands_played,
        -- ... more fields as needed
    }
end

return M

