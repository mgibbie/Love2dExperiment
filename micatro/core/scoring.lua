-- Score Calculator
-- Evaluates hands, applies joker effects, calculates final score

local Hands = require("micatro.data.hands")
local Enhancements = require("micatro.data.enhancements")
local Editions = require("micatro.data.editions")

local M = {}

-- Rank values for straights
local RANK_ORDER = {
    ["A"] = 14, ["K"] = 13, ["Q"] = 12, ["J"] = 11, ["10"] = 10,
    ["9"] = 9, ["8"] = 8, ["7"] = 7, ["6"] = 6, ["5"] = 5,
    ["4"] = 4, ["3"] = 3, ["2"] = 2
}

-- Rank chip values
local RANK_CHIPS = {
    ["2"] = 2, ["3"] = 3, ["4"] = 4, ["5"] = 5, ["6"] = 6,
    ["7"] = 7, ["8"] = 8, ["9"] = 9, ["10"] = 10,
    ["J"] = 10, ["Q"] = 10, ["K"] = 10, ["A"] = 11
}

-- Check if a card is a face card
function M.isFaceCard(card)
    return card.rank == "J" or card.rank == "Q" or card.rank == "K"
end

-- Check if rank is even
function M.isEven(rank)
    local num = tonumber(rank)
    if num then
        return num % 2 == 0
    end
    return false  -- Face cards and Ace are not even
end

-- Check if rank is odd
function M.isOdd(rank)
    local num = tonumber(rank)
    if num then
        return num % 2 == 1
    end
    return rank == "A"  -- Ace counts as odd
end

-- Get card's effective suit (accounting for Wild cards)
function M.getCardSuit(card, allSuits)
    if card.enhancement == "m_wild" then
        -- Wild cards can be any suit
        return allSuits or {"Hearts", "Diamonds", "Clubs", "Spades"}
    end
    return {card.suit}
end

-- Count ranks and suits in a hand
local function countRanksAndSuits(cards)
    local rankCounts = {}
    local suitCounts = {}
    
    for _, card in ipairs(cards) do
        -- Count ranks (Stone cards don't have ranks)
        if card.enhancement ~= "m_stone" then
            rankCounts[card.rank] = (rankCounts[card.rank] or 0) + 1
        end
        
        -- Count suits (accounting for wild)
        local suits = M.getCardSuit(card)
        for _, suit in ipairs(suits) do
            suitCounts[suit] = (suitCounts[suit] or 0) + 1
        end
    end
    
    return rankCounts, suitCounts
end

-- Check for flush (5+ cards of same suit)
local function isFlush(suitCounts, minCards)
    minCards = minCards or 5
    for _, count in pairs(suitCounts) do
        if count >= minCards then
            return true
        end
    end
    return false
end

-- Get the flush suit
local function getFlushSuit(suitCounts, minCards)
    minCards = minCards or 5
    for suit, count in pairs(suitCounts) do
        if count >= minCards then
            return suit
        end
    end
    return nil
end

-- Check for straight (5 consecutive ranks)
local function isStraight(rankCounts, gapAllowed)
    gapAllowed = gapAllowed or 0
    
    local values = {}
    local seen = {}
    
    for rank, _ in pairs(rankCounts) do
        local val = RANK_ORDER[rank]
        if val and not seen[val] then
            table.insert(values, val)
            seen[val] = true
        end
    end
    
    -- Add Ace-low for A-2-3-4-5
    if seen[14] then
        table.insert(values, 1)
    end
    
    table.sort(values)
    
    -- Check for 5-card straight (with optional gaps for Shortcut joker)
    local consecutive = 1
    local gaps = 0
    
    for i = 2, #values do
        local diff = values[i] - values[i-1]
        if diff == 1 then
            consecutive = consecutive + 1
        elseif diff == 2 and gapAllowed > 0 then
            gaps = gaps + 1
            if gaps <= gapAllowed then
                consecutive = consecutive + 1
            else
                consecutive = 1
                gaps = 0
            end
        else
            consecutive = 1
            gaps = 0
        end
        
        if consecutive >= 5 then
            return true
        end
    end
    
    return false
end

-- Build frequency table (how many pairs, trips, etc.)
local function getCountFrequencies(rankCounts)
    local freq = {}
    for _, count in pairs(rankCounts) do
        freq[count] = (freq[count] or 0) + 1
    end
    return freq
end

-- Evaluate what poker hand the cards form
function M.evaluateHand(cards, config)
    config = config or {}
    
    if #cards == 0 then
        return {
            name = "No Cards",
            level = 1,
            base_chips = 0,
            base_mult = 0,
            scoring_cards = {}
        }
    end
    
    local rankCounts, suitCounts = countRanksAndSuits(cards)
    local countFreq = getCountFrequencies(rankCounts)
    
    -- Check for Four Fingers (4-card straights/flushes)
    local minCards = config.four_fingers and 4 or 5
    local gapAllowed = config.shortcut and 1 or 0
    
    local hasFlush = isFlush(suitCounts, minCards)
    local hasStraight = isStraight(rankCounts, gapAllowed)
    
    -- Determine hand type (highest to lowest)
    local handName = "High Card"
    
    -- Check special Balatro hands first
    if hasFlush and countFreq[5] then
        handName = "Flush Five"
    elseif hasFlush and countFreq[3] and countFreq[2] then
        handName = "Flush House"
    elseif countFreq[5] then
        handName = "Five of a Kind"
    elseif hasFlush and hasStraight then
        handName = "Straight Flush"
    elseif countFreq[4] then
        handName = "Four of a Kind"
    elseif countFreq[3] and countFreq[2] then
        handName = "Full House"
    elseif hasFlush then
        handName = "Flush"
    elseif hasStraight then
        handName = "Straight"
    elseif countFreq[3] then
        handName = "Three of a Kind"
    elseif countFreq[2] and countFreq[2] >= 2 then
        handName = "Two Pair"
    elseif countFreq[2] then
        handName = "Pair"
    end
    
    -- Determine which cards score
    local scoringCards = M.getScoringCards(cards, handName, rankCounts, suitCounts, config)
    
    return {
        name = handName,
        scoring_cards = scoringCards,
        rank_counts = rankCounts,
        suit_counts = suitCounts
    }
end

-- Determine which cards score for a given hand type
function M.getScoringCards(cards, handName, rankCounts, suitCounts, config)
    config = config or {}
    local scoring = {}
    
    -- If Splash joker is active, all cards score
    if config.splash then
        return cards
    end
    
    -- Determine scoring based on hand type
    if handName == "High Card" then
        -- Only highest card scores
        local highest = nil
        local highestVal = 0
        for _, card in ipairs(cards) do
            if card.enhancement ~= "m_stone" then
                local val = RANK_ORDER[card.rank] or 0
                if val > highestVal then
                    highest = card
                    highestVal = val
                end
            end
        end
        if highest then
            table.insert(scoring, highest)
        end
        
    elseif handName == "Pair" or handName == "Three of a Kind" or 
           handName == "Four of a Kind" or handName == "Five of a Kind" then
        -- Cards that match the set score
        for rank, count in pairs(rankCounts) do
            if (handName == "Pair" and count >= 2) or
               (handName == "Three of a Kind" and count >= 3) or
               (handName == "Four of a Kind" and count >= 4) or
               (handName == "Five of a Kind" and count >= 5) then
                for _, card in ipairs(cards) do
                    if card.rank == rank then
                        table.insert(scoring, card)
                    end
                end
                break
            end
        end
        
    elseif handName == "Two Pair" then
        -- Both pairs score
        local pairCount = 0
        for rank, count in pairs(rankCounts) do
            if count >= 2 and pairCount < 2 then
                for _, card in ipairs(cards) do
                    if card.rank == rank then
                        table.insert(scoring, card)
                    end
                end
                pairCount = pairCount + 1
            end
        end
        
    elseif handName == "Full House" or handName == "Flush House" then
        -- All 5 cards score
        for _, card in ipairs(cards) do
            table.insert(scoring, card)
        end
        
    elseif handName == "Flush" or handName == "Flush Five" then
        -- Cards of the flush suit score
        local flushSuit = getFlushSuit(suitCounts, config.four_fingers and 4 or 5)
        for _, card in ipairs(cards) do
            local suits = M.getCardSuit(card)
            for _, suit in ipairs(suits) do
                if suit == flushSuit then
                    table.insert(scoring, card)
                    break
                end
            end
        end
        
    elseif handName == "Straight" or handName == "Straight Flush" then
        -- All 5 cards in the straight score
        -- For simplicity, score all cards if straight is detected
        for _, card in ipairs(cards) do
            table.insert(scoring, card)
        end
    end
    
    return scoring
end

-- Calculate total score for a played hand
function M.calculateScore(gameState, playedCards, config)
    config = config or {}
    
    -- Evaluate the hand
    local evaluation = M.evaluateHand(playedCards, config)
    local handName = evaluation.name
    local scoringCards = evaluation.scoring_cards
    
    -- Get base chips and mult from hand level
    local level = gameState.hand_levels[handName] or 1
    local baseChips, baseMult = Hands.getHandValue(handName, level)
    
    -- Start with base values
    local totalChips = baseChips
    local totalMult = baseMult
    local xMult = 1
    
    -- Calculate card chips
    for _, card in ipairs(scoringCards) do
        -- Base chip value
        local cardChips = RANK_CHIPS[card.rank] or 0
        
        -- Stone cards give bonus but no rank chips
        if card.enhancement == "m_stone" then
            cardChips = 50
        end
        
        -- Bonus from Hiker, etc.
        cardChips = cardChips + (card.bonus_chips or 0)
        
        -- Enhancement bonuses
        if card.enhancement then
            local enh = Enhancements.get(card.enhancement)
            if enh and enh.config then
                if enh.config.bonus then
                    print("Adding bonus chips: " .. enh.config.bonus .. " for enhancement: " .. card.enhancement)
                    cardChips = cardChips + enh.config.bonus
                end
                if enh.config.mult then
                    totalMult = totalMult + enh.config.mult
                end
                if enh.config.Xmult then
                    xMult = xMult * enh.config.Xmult
                end
            end
        end
        
        -- Edition bonuses
        if card.edition then
            local ed = Editions.get(card.edition)
            if ed and ed.config and ed.config.extra then
                if card.edition == "e_foil" then
                    cardChips = cardChips + ed.config.extra
                elseif card.edition == "e_holo" then
                    totalMult = totalMult + ed.config.extra
                elseif card.edition == "e_polychrome" then
                    xMult = xMult * ed.config.extra
                end
            end
        end
        
        totalChips = totalChips + cardChips
    end
    
    -- Track hand played
    if gameState then
        gameState.hands_played[handName] = (gameState.hands_played[handName] or 0) + 1
        gameState.hands_played_round[handName] = (gameState.hands_played_round[handName] or 0) + 1
    end
    
    -- Build result
    local result = {
        hand_name = handName,
        level = level,
        chips = totalChips,
        mult = totalMult,
        xmult = xMult,
        scoring_cards = scoringCards,
        
        -- Final calculation happens after joker effects
        final_chips = totalChips,
        final_mult = totalMult * xMult,
        final_score = 0
    }
    
    return result
end

-- Apply joker effects to a score result
function M.applyJokerEffects(gameState, scoreResult, context)
    context = context or {}
    
    local chips = scoreResult.chips
    local mult = scoreResult.mult
    local xmult = scoreResult.xmult
    
    -- Check for in-hand effects (steel, gold, etc.) - process left to right
    local handCards = context.handCards or {}
    for _, card in ipairs(handCards) do
        if card.enhancement then
            local enh = Enhancements.get(card.enhancement)
            if enh and enh.config then
                -- Steel: x1.5 mult while in hand (applied left to right)
                if enh.config.h_x_mult then
                    xmult = xmult * enh.config.h_x_mult
                end
                -- Gold: $3 if in hand at end of round (will be processed after scoring)
                if enh.config.h_dollars then
                    -- Track for end-of-round processing
                    scoreResult.gold_dollars = (scoreResult.gold_dollars or 0) + enh.config.h_dollars
                end
            end
        end
    end
    
    -- Process each joker in order
    for i, joker in ipairs(gameState.jokers) do
        local effect = M.calculateJokerEffect(joker, gameState, scoreResult, context)
        
        if effect then
            if effect.chips then
                chips = chips + effect.chips
            end
            if effect.mult then
                mult = mult + effect.mult
            end
            if effect.xmult then
                xmult = xmult * effect.xmult
            end
            if effect.dollars then
                gameState.money = gameState.money + effect.dollars
            end
        end
    end
    
    -- Apply gold card dollars (if any)
    if scoreResult.gold_dollars then
        gameState.money = gameState.money + scoreResult.gold_dollars
    end
    
    -- Calculate final score
    scoreResult.final_chips = chips
    scoreResult.final_mult = mult * xmult
    scoreResult.final_score = math.floor(chips * mult * xmult)
    
    return scoreResult
end

-- Calculate a single joker's effect
function M.calculateJokerEffect(joker, gameState, scoreResult, context)
    local data = joker.data
    local ability = joker.ability
    local effect = {}
    
    -- Basic Joker
    if data.key == "j_joker" then
        effect.mult = ability.mult or 4
        
    -- Suit-based mult jokers
    elseif data.key == "j_greedy_joker" then
        for _, card in ipairs(scoreResult.scoring_cards) do
            if card.suit == "Diamonds" then
                effect.mult = (effect.mult or 0) + (ability.extra and ability.extra.s_mult or 3)
            end
        end
        
    elseif data.key == "j_lusty_joker" then
        for _, card in ipairs(scoreResult.scoring_cards) do
            if card.suit == "Hearts" then
                effect.mult = (effect.mult or 0) + (ability.extra and ability.extra.s_mult or 3)
            end
        end
        
    elseif data.key == "j_wrathful_joker" then
        for _, card in ipairs(scoreResult.scoring_cards) do
            if card.suit == "Spades" then
                effect.mult = (effect.mult or 0) + (ability.extra and ability.extra.s_mult or 3)
            end
        end
        
    elseif data.key == "j_gluttenous_joker" then
        for _, card in ipairs(scoreResult.scoring_cards) do
            if card.suit == "Clubs" then
                effect.mult = (effect.mult or 0) + (ability.extra and ability.extra.s_mult or 3)
            end
        end
        
    -- Hand type mult jokers
    elseif data.key == "j_jolly" then
        if scoreResult.hand_name == "Pair" or 
           scoreResult.hand_name == "Two Pair" or
           scoreResult.hand_name == "Full House" or
           scoreResult.hand_name:find("Kind") then
            effect.mult = ability.t_mult or 8
        end
        
    -- And so on for other jokers...
    -- This would be expanded to cover all 150 jokers
    
    -- Abstract Joker - mult per joker
    elseif data.key == "j_abstract" then
        effect.mult = (ability.extra or 3) * #gameState.jokers
        
    -- Banner - chips per discard remaining
    elseif data.key == "j_banner" then
        effect.chips = (ability.extra or 30) * gameState.discards_remaining
        
    -- Half Joker
    elseif data.key == "j_half" then
        if #scoreResult.scoring_cards <= (ability.extra and ability.extra.size or 3) then
            effect.mult = ability.extra and ability.extra.mult or 20
        end
    end
    
    return effect
end

return M

