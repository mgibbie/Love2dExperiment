-- Battle Helpers
-- Utility functions for the battle system

local cards = require('data.cards')
local helpers = {}

-- Generate unique instance ID
local instanceCounter = 0
function helpers.generateInstanceId(prefix)
    instanceCounter = instanceCounter + 1
    return (prefix or 'card') .. '-' .. instanceCounter .. '-' .. os.time() .. '-' .. math.random(1000, 9999)
end

-- Shuffle an array using Fisher-Yates algorithm
function helpers.shuffle(array)
    local shuffled = {}
    for i, v in ipairs(array) do
        shuffled[i] = v
    end
    for i = #shuffled, 2, -1 do
        local j = math.random(1, i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end
    return shuffled
end

-- Create a card instance from card data
function helpers.createCardInstance(cardData, prefix)
    return {
        instanceId = helpers.generateInstanceId(prefix or cardData.id),
        card = cards.copy(cardData)
    }
end

-- Create a creature instance from a card instance
function helpers.createCreatureFromCard(cardInstance)
    local card = cardInstance.card
    local hasCharge = helpers.hasKeyword(card, 'Charge')
    local hasRush = helpers.hasKeyword(card, 'Rush')
    
    return {
        instanceId = cardInstance.instanceId,
        card = card,
        currentHealth = card.health or 1,
        currentAttack = card.attack or 0,
        canAttack = hasCharge or hasRush,
        canAttackFace = hasCharge, -- Rush can only attack creatures
        hasAttacked = false,
        keywords = helpers.copyKeywords(card.keywords or {})
    }
end

-- Copy keywords array
function helpers.copyKeywords(keywords)
    local result = {}
    for i, k in ipairs(keywords) do
        result[i] = k
    end
    return result
end

-- Check if a card/creature has a keyword
function helpers.hasKeyword(cardOrCreature, keyword)
    local keywords = cardOrCreature.keywords or {}
    for _, k in ipairs(keywords) do
        if k == keyword then
            return true
        end
    end
    return false
end

-- Remove a keyword from a creature
function helpers.removeKeyword(creature, keyword)
    local newKeywords = {}
    for _, k in ipairs(creature.keywords or {}) do
        if k ~= keyword then
            table.insert(newKeywords, k)
        end
    end
    creature.keywords = newKeywords
end

-- Create a deck for a player class
function helpers.createDeck(heroClass)
    local classCards = {}
    for _, card in ipairs(cards.sampleCards) do
        if card.cardClass == heroClass or card.cardClass == 'neutral' then
            table.insert(classCards, card)
        end
    end
    
    -- Duplicate cards to fill deck and take first 15
    local deckCards = {}
    for _, card in ipairs(classCards) do
        table.insert(deckCards, card)
    end
    for _, card in ipairs(classCards) do
        table.insert(deckCards, card)
    end
    
    -- Shuffle and take first 15
    deckCards = helpers.shuffle(deckCards)
    local deck = {}
    for i = 1, math.min(15, #deckCards) do
        table.insert(deck, helpers.createCardInstance(deckCards[i]))
    end
    
    return deck
end

-- Create an enemy deck (random creature mix)
function helpers.createEnemyDeck()
    local creatures = cards.getCreatures()
    local deckCards = {}
    
    -- Duplicate and shuffle
    for _, card in ipairs(creatures) do
        table.insert(deckCards, card)
    end
    for _, card in ipairs(creatures) do
        table.insert(deckCards, card)
    end
    
    deckCards = helpers.shuffle(deckCards)
    
    local deck = {}
    for i = 1, math.min(15, #deckCards) do
        table.insert(deck, helpers.createCardInstance(deckCards[i], 'enemy'))
    end
    
    return deck
end

-- Check if a spell requires a target
function helpers.spellNeedsTarget(card)
    local effect = string.lower(card.effect or '')
    
    -- Damage spells that target
    if string.find(effect, 'deal') and string.find(effect, 'damage') and
       (string.find(effect, 'target') or string.find(effect, 'any')) then
        return true
    end
    
    -- Buff spells that target a creature
    if string.find(effect, 'give a creature') or string.find(effect, 'give target creature') then
        return true
    end
    
    return false
end

-- Check if board has taunt creatures
function helpers.hasTauntCreatures(board)
    for _, creature in ipairs(board) do
        if helpers.hasKeyword(creature, 'Taunt') then
            return true
        end
    end
    return false
end

-- Get taunt creatures from board
function helpers.getTauntCreatures(board)
    local taunts = {}
    for _, creature in ipairs(board) do
        if helpers.hasKeyword(creature, 'Taunt') then
            table.insert(taunts, creature)
        end
    end
    return taunts
end

-- Filter dead creatures from board
function helpers.filterDeadCreatures(board)
    local alive = {}
    local dead = {}
    for _, creature in ipairs(board) do
        if creature.currentHealth > 0 then
            table.insert(alive, creature)
        else
            table.insert(dead, creature)
        end
    end
    return alive, dead
end

-- Convert creatures to card instances (for graveyard)
function helpers.creaturesToGraveyard(creatures)
    local result = {}
    for _, creature in ipairs(creatures) do
        table.insert(result, {
            instanceId = creature.instanceId,
            card = creature.card
        })
    end
    return result
end

-- Apply buff to creature
function helpers.applyBuff(creature, attackBuff, healthBuff, addTaunt)
    creature.currentAttack = creature.currentAttack + attackBuff
    creature.currentHealth = creature.currentHealth + healthBuff
    
    if addTaunt and not helpers.hasKeyword(creature, 'Taunt') then
        table.insert(creature.keywords, 'Taunt')
    end
end

-- Check if a card can be played (enough mana)
function helpers.canPlayCard(cardInstance, owner, enemyBoard)
    -- Check mana
    if cardInstance.card.cost > owner.mana then
        return false
    end
    
    -- Creatures always playable if mana available
    if cardInstance.card.type == 'creature' then
        return true
    end
    
    -- Spells may need targets
    -- For now, allow all spells if mana is available
    return true
end

return helpers

