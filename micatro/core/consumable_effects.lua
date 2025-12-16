-- Consumable Effects
-- Implementation of tarot, planet, and spectral card effects

local GameState = require("micatro.core.game_state")
local Tarots = require("micatro.data.tarots")
local Planets = require("micatro.data.planets")
local Spectrals = require("micatro.data.spectrals")
local Jokers = require("micatro.data.jokers")
local Enhancements = require("micatro.data.enhancements")

local M = {}

-- Use a consumable card
-- Returns: success (bool), message (string), effects (table)
function M.use(consumable, gameState, selectedCards, area)
    local data = consumable.data
    if not data then
        return false, "Invalid consumable", {}
    end
    
    local set = data.set
    
    if set == "Tarot" then
        return M.useTarot(consumable, gameState, selectedCards, area)
    elseif set == "Planet" then
        return M.usePlanet(consumable, gameState)
    elseif set == "Spectral" then
        return M.useSpectral(consumable, gameState, selectedCards, area)
    end
    
    return false, "Unknown consumable type", {}
end

-- Use a Tarot card
function M.useTarot(consumable, gameState, selectedCards, area)
    local data = consumable.data
    local config = data.config or {}
    local effects = {}
    
    -- Track for The Fool (save BEFORE updating, so Fool can use the previous one)
    local previousTarot = gameState.last_tarot
    local previousPlanet = gameState.last_planet
    
    -- Track for The Fool (update AFTER saving previous)
    if data.key ~= "c_fool" then  -- Don't overwrite with Fool itself
        gameState.last_tarot = data.key
    end
    
    -- Check selection requirements
    if config.max_highlighted then
        if #selectedCards > config.max_highlighted then
            return false, "Too many cards selected", {}
        end
    end
    if config.min_highlighted then
        if #selectedCards < config.min_highlighted then
            return false, "Not enough cards selected", {}
        end
    end
    
    -- Apply effect based on tarot type
    if data.key == "c_fool" then
        -- The Fool: Create last used tarot/planet
        local lastKey = previousTarot or previousPlanet
        if lastKey then
            local lastCard = Tarots.get(lastKey) or Planets.get(lastKey)
            if lastCard then
                effects.created = effects.created or {}
                table.insert(effects.created, lastCard)
            else
                return false, "No previous tarot or planet card used", {}
            end
        else
            return false, "No previous tarot or planet card used", {}
        end
        
    elseif config.mod_conv then
        -- Enhancement tarots
        -- Supported cards:
        -- - The Magician (m_lucky)
        -- - The Empress (m_mult)
        -- - The Hierophant (m_bonus)
        -- - The Chariot (m_steel)
        -- - The Lovers (m_wild)
        -- - Justice (m_glass)
        -- - The Devil (m_gold)
        -- - The Tower (m_stone)
        -- - Strength (up_rank - special case)
        for _, card in ipairs(selectedCards) do
            if config.mod_conv == "up_rank" then
                -- Strength: Increase rank by 1
                local rankOrder = {A = 14, K = 13, Q = 12, J = 11, ["10"] = 10, ["9"] = 9, ["8"] = 8, ["7"] = 7, ["6"] = 6, ["5"] = 5, ["4"] = 4, ["3"] = 3, ["2"] = 2}
                local rankToName = {[14] = "A", [13] = "K", [12] = "Q", [11] = "J", [10] = "10", [9] = "9", [8] = "8", [7] = "7", [6] = "6", [5] = "5", [4] = "4", [3] = "3", [2] = "2"}
                local currentRank = rankOrder[card.rank] or tonumber(card.rank) or 2
                if currentRank < 14 then  -- Can't go above Ace
                    card.rank = rankToName[currentRank + 1] or tostring(currentRank + 1)
                    effects.rank_up = effects.rank_up or {}
                    table.insert(effects.rank_up, card)
                end
            else
                -- Apply enhancement (handles: m_lucky, m_mult, m_bonus, m_steel, m_wild, m_glass, m_gold, m_stone)
                card.enhancement = config.mod_conv
                effects.enhanced = effects.enhanced or {}
                table.insert(effects.enhanced, card)
            end
        end
        
    elseif config.suit_conv then
        -- Suit conversion tarots (Star, Moon, Sun, World)
        for _, card in ipairs(selectedCards) do
            card.suit = config.suit_conv
            effects.converted = effects.converted or {}
            table.insert(effects.converted, card)
        end
        
    elseif config.remove_card then
        -- The Hanged Man: Destroy cards
        for _, card in ipairs(selectedCards) do
            effects.destroyed = effects.destroyed or {}
            table.insert(effects.destroyed, card)
        end
        
    elseif data.key == "c_high_priestess" then
        -- High Priestess: Create up to 2 planet cards
        -- Account for the fact that this consumable will be removed, so we have +1 slot available
        local availableSlots = gameState.consumable_slots - (#gameState.consumables - 1)
        local count = math.min(config.planets or 2, availableSlots)
        for i = 1, count do
            local planet = Planets.getRandom()
            effects.created = effects.created or {}
            table.insert(effects.created, planet)
        end
        
    elseif data.key == "c_emperor" then
        -- Emperor: Create up to 2 tarot cards
        -- Account for the fact that this consumable will be removed, so we have +1 slot available
        local availableSlots = gameState.consumable_slots - (#gameState.consumables - 1)
        local count = math.min(config.tarots or 2, availableSlots)
        for i = 1, count do
            local tarot = Tarots.getRandom()
            effects.created = effects.created or {}
            table.insert(effects.created, tarot)
        end
        
    elseif data.key == "c_hermit" then
        -- Hermit: Double money (max $20)
        local gain = math.min(gameState.money, config.extra or 20)
        gameState.money = gameState.money + gain
        effects.dollars = gain
        
    elseif data.key == "c_wheel_of_fortune" then
        -- Wheel of Fortune: 1 in 4 chance to add edition to joker
        if math.random(config.extra or 4) == 1 then
            local editions = {"e_foil", "e_holo", "e_polychrome"}
            local edition = editions[math.random(#editions)]
            if #gameState.jokers > 0 then
                local joker = gameState.jokers[math.random(#gameState.jokers)]
                joker.edition = edition
                effects.edition_added = {joker = joker, edition = edition}
            end
        else
            effects.failed = true
        end
        
    elseif data.key == "c_temperance" then
        -- Temperance: Get sell value of all jokers (max $50)
        local total = 0
        for _, joker in ipairs(gameState.jokers) do
            total = total + (joker.sell_value or 0)
        end
        local gain = math.min(total, config.extra or 50)
        gameState.money = gameState.money + gain
        effects.dollars = gain
        
    elseif data.key == "c_judgement" then
        -- Judgement: Create random joker
        if #gameState.jokers < gameState.joker_slots then
            local jokerData = Jokers.getRandom()
            effects.create_joker = jokerData
        end
        
    elseif data.key == "c_death" then
        -- Death: Convert left card into right card
        if #selectedCards == 2 then
            local left = selectedCards[1]
            local right = selectedCards[2]
            left.rank = right.rank
            left.suit = right.suit
            effects.copied = {from = right, to = left}
        end
    end
    
    return true, "Used!", effects
end

-- Use a Planet card
function M.usePlanet(consumable, gameState)
    local data = consumable.data
    local config = data.config or {}
    local effects = {}
    
    -- Track for The Fool
    gameState.last_planet = data.key
    
    -- Level up the associated hand
    local handType = config.hand_type
    if handType then
        GameState.levelUpHand(gameState, handType)
        effects.leveled_up = handType
        effects.new_level = gameState.hand_levels[handType]
    end
    
    -- Update constellation joker if present
    for _, joker in ipairs(gameState.jokers) do
        if joker.data.key == "j_constellation" then
            joker.ability.Xmult = (joker.ability.Xmult or 1) + 0.1
        end
    end
    
    return true, "Level Up!", effects
end

-- Use a Spectral card
function M.useSpectral(consumable, gameState, selectedCards, area)
    local data = consumable.data
    local config = data.config or {}
    local effects = {}
    
    if data.key == "c_familiar" then
        -- Familiar: Destroy 1 random card, add 3 enhanced face cards
        if #gameState.hand > 0 then
            local idx = math.random(#gameState.hand)
            effects.destroyed = {gameState.hand[idx]}
            effects.created_cards = {}
            local faces = {"J", "Q", "K"}
            local suits = {"Hearts", "Diamonds", "Clubs", "Spades"}
            local enhancements = {"m_bonus", "m_mult", "m_wild"}
            for i = 1, config.extra or 3 do
                table.insert(effects.created_cards, {
                    rank = faces[math.random(#faces)],
                    suit = suits[math.random(#suits)],
                    enhancement = enhancements[math.random(#enhancements)]
                })
            end
        end
        
    elseif data.key == "c_grim" then
        -- Grim: Destroy 1 random card, add 2 enhanced Aces
        if #gameState.hand > 0 then
            local idx = math.random(#gameState.hand)
            effects.destroyed = {gameState.hand[idx]}
            effects.created_cards = {}
            local suits = {"Hearts", "Diamonds", "Clubs", "Spades"}
            local enhancements = {"m_bonus", "m_mult", "m_wild"}
            for i = 1, config.extra or 2 do
                table.insert(effects.created_cards, {
                    rank = "A",
                    suit = suits[math.random(#suits)],
                    enhancement = enhancements[math.random(#enhancements)]
                })
            end
        end
        
    elseif data.key == "c_incantation" then
        -- Incantation: Destroy 1 random card, add 4 enhanced number cards
        if #gameState.hand > 0 then
            local idx = math.random(#gameState.hand)
            effects.destroyed = {gameState.hand[idx]}
            effects.created_cards = {}
            local numbers = {"2", "3", "4", "5", "6", "7", "8", "9", "10"}
            local suits = {"Hearts", "Diamonds", "Clubs", "Spades"}
            local enhancements = {"m_bonus", "m_mult", "m_wild"}
            for i = 1, config.extra or 4 do
                table.insert(effects.created_cards, {
                    rank = numbers[math.random(#numbers)],
                    suit = suits[math.random(#suits)],
                    enhancement = enhancements[math.random(#enhancements)]
                })
            end
        end
        
    elseif data.key == "c_talisman" or data.key == "c_deja_vu" or 
           data.key == "c_trance" or data.key == "c_medium" then
        -- Seal cards
        if #selectedCards > 0 then
            local seal = config.extra
            for _, card in ipairs(selectedCards) do
                card.seal = seal
            end
            effects.sealed = selectedCards
        end
        
    elseif data.key == "c_aura" then
        -- Aura: Add random edition to selected card
        if #selectedCards > 0 then
            local editions = {"e_foil", "e_holo", "e_polychrome"}
            local edition = editions[math.random(#editions)]
            selectedCards[1].edition = edition
            effects.edition_added = {card = selectedCards[1], edition = edition}
        end
        
    elseif data.key == "c_wraith" then
        -- Wraith: Create rare joker, set money to $0
        if #gameState.jokers < gameState.joker_slots then
            local jokerData = Jokers.getRandomByRarity(3)  -- Rare
            effects.create_joker = jokerData
            gameState.money = 0
            effects.money_lost = true
        end
        
    elseif data.key == "c_sigil" then
        -- Sigil: Convert all hand cards to one suit
        local suits = {"Hearts", "Diamonds", "Clubs", "Spades"}
        local newSuit = suits[math.random(#suits)]
        for _, card in ipairs(gameState.hand) do
            card.suit = newSuit
        end
        effects.converted_suit = newSuit
        
    elseif data.key == "c_ouija" then
        -- Ouija: Convert all hand cards to one rank, -1 hand size
        local ranks = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"}
        local newRank = ranks[math.random(#ranks)]
        for _, card in ipairs(gameState.hand) do
            card.rank = newRank
        end
        gameState.hand_size = gameState.hand_size - 1
        effects.converted_rank = newRank
        effects.hand_size_reduced = true
        
    elseif data.key == "c_ectoplasm" then
        -- Ectoplasm: Add Negative to random joker, -1 hand size
        if #gameState.jokers > 0 then
            local joker = gameState.jokers[math.random(#gameState.jokers)]
            joker.edition = "e_negative"
            gameState.hand_size = gameState.hand_size - 1
            effects.negative_added = joker
            effects.hand_size_reduced = true
        end
        
    elseif data.key == "c_immolate" then
        -- Immolate: Destroy 5 random cards, gain $20
        effects.destroyed = {}
        local destroyCount = math.min(config.extra and config.extra.destroy or 5, #gameState.hand)
        for i = 1, destroyCount do
            local idx = math.random(#gameState.hand)
            table.insert(effects.destroyed, gameState.hand[idx])
        end
        local gain = config.extra and config.extra.dollars or 20
        gameState.money = gameState.money + gain
        effects.dollars = gain
        
    elseif data.key == "c_ankh" then
        -- Ankh: Copy random joker, destroy all others
        if #gameState.jokers > 0 then
            local idx = math.random(#gameState.jokers)
            local survivor = gameState.jokers[idx]
            effects.destroyed_jokers = {}
            for i, joker in ipairs(gameState.jokers) do
                if i ~= idx then
                    table.insert(effects.destroyed_jokers, joker)
                end
            end
            effects.copied_joker = survivor
        end
        
    elseif data.key == "c_hex" then
        -- Hex: Add Polychrome to random joker, destroy all others
        if #gameState.jokers > 0 then
            local idx = math.random(#gameState.jokers)
            local survivor = gameState.jokers[idx]
            survivor.edition = "e_polychrome"
            effects.destroyed_jokers = {}
            for i, joker in ipairs(gameState.jokers) do
                if i ~= idx then
                    table.insert(effects.destroyed_jokers, joker)
                end
            end
            effects.polychrome_added = survivor
        end
        
    elseif data.key == "c_cryptid" then
        -- Cryptid: Create 2 copies of selected card
        if #selectedCards > 0 then
            effects.created_cards = {}
            for i = 1, config.extra or 2 do
                local copy = {
                    rank = selectedCards[1].rank,
                    suit = selectedCards[1].suit,
                    enhancement = selectedCards[1].enhancement,
                    edition = selectedCards[1].edition,
                    seal = selectedCards[1].seal
                }
                table.insert(effects.created_cards, copy)
            end
        end
        
    elseif data.key == "c_soul" then
        -- The Soul: Create legendary joker
        if #gameState.jokers < gameState.joker_slots then
            local jokerData = Jokers.getRandomByRarity(4)  -- Legendary
            effects.create_joker = jokerData
        end
        
    elseif data.key == "c_black_hole" then
        -- Black Hole: Level up all hands by 1
        for handName, _ in pairs(gameState.hand_levels) do
            GameState.levelUpHand(gameState, handName)
        end
        effects.all_leveled = true
    end
    
    return true, "Used!", effects
end

-- Check if consumable can be used with current selection
function M.canUse(consumable, gameState, selectedCards)
    local data = consumable.data
    if not data then return false end
    
    local config = data.config or {}
    
    -- Check card selection requirements
    if config.max_highlighted then
        if #selectedCards == 0 then return false end
        if #selectedCards > config.max_highlighted then return false end
    end
    
    if config.min_highlighted then
        if #selectedCards < config.min_highlighted then return false end
    end
    
    -- Specific consumable checks
    if data.key == "c_judgement" then
        return #gameState.jokers < gameState.joker_slots
    elseif data.key == "c_wraith" or data.key == "c_soul" then
        return #gameState.jokers < gameState.joker_slots
    elseif data.key == "c_high_priestess" or data.key == "c_emperor" then
        return #gameState.consumables < gameState.consumable_slots
    end
    
    return true
end

-- Get description for current state
function M.getDescription(consumable, gameState, selectedCards)
    local data = consumable.data
    if not data then return "" end
    
    return data.description or ""
end

return M

