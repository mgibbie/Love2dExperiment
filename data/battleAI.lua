-- Battle AI
-- Enemy decision making and turn management

local helpers = require('data.battleHelpers')
local ai = {}

-- Enemy turn state
ai.turnState = {
    phase = 0,  -- 0=waiting, 1=start, 2=play cards, 3=attack, 4=end
    cardIndex = 0,
    actionIndex = 0,
    cardsToPlay = {},
    attackDecisions = {}
}

-- Reset turn state
function ai.resetTurnState()
    ai.turnState.phase = 0
    ai.turnState.cardIndex = 0
    ai.turnState.actionIndex = 0
    ai.turnState.cardsToPlay = {}
    ai.turnState.attackDecisions = {}
end

-- Decide which cards to play (prioritize highest cost creatures)
function ai.decideCardsToPlay(hand, availableMana)
    local playableCards = {}
    for _, cardInstance in ipairs(hand) do
        if cardInstance.card.cost <= availableMana and cardInstance.card.type == 'creature' then
            table.insert(playableCards, cardInstance)
        end
    end
    
    table.sort(playableCards, function(a, b)
        return a.card.cost > b.card.cost
    end)
    
    local cardsToPlay = {}
    local manaLeft = availableMana
    
    for _, card in ipairs(playableCards) do
        if card.card.cost <= manaLeft then
            table.insert(cardsToPlay, card)
            manaLeft = manaLeft - card.card.cost
        end
    end
    
    return cardsToPlay
end

-- Decide attack target for a creature
function ai.decideAttackTarget(attacker, playerBoard)
    local playerTaunts = helpers.getTauntCreatures(playerBoard)
    if #playerTaunts > 0 then
        return { type = 'creature', creature = playerTaunts[1] }
    end
    
    if helpers.hasKeyword(attacker, 'Rush') and not attacker.canAttackFace then
        if #playerBoard > 0 then
            return { type = 'creature', creature = playerBoard[math.random(1, #playerBoard)] }
        end
        return nil
    end
    
    if #playerBoard > 0 and math.random() > 0.5 then
        return { type = 'creature', creature = playerBoard[math.random(1, #playerBoard)] }
    end
    
    return { type = 'face' }
end

-- Get all attack decisions for enemy turn
function ai.getAttackDecisions(enemyBoard, playerBoard)
    local decisions = {}
    for _, creature in ipairs(enemyBoard) do
        if creature.canAttack and not creature.hasAttacked then
            local target = ai.decideAttackTarget(creature, playerBoard)
            if target then
                table.insert(decisions, { attacker = creature, target = target })
            end
        end
    end
    return decisions
end

-- Process enemy turn (returns action to execute or nil if waiting)
function ai.processEnemyTurn(state, battleState, dt)
    state.enemyTurnTimer = state.enemyTurnTimer - dt
    if state.enemyTurnTimer > 0 then return nil end
    
    local ts = ai.turnState
    
    if ts.phase == 0 then
        battleState.startEnemyTurn(state)
        ts.phase = 1
        state.enemyTurnTimer = 0.5
        return { type = 'start' }
        
    elseif ts.phase == 1 then
        ts.cardsToPlay = ai.decideCardsToPlay(state.enemy.hand, state.enemy.mana)
        ts.cardIndex = 1
        ts.phase = 2
        state.enemyTurnTimer = 0.3
        return { type = 'decide_cards' }
        
    elseif ts.phase == 2 then
        if ts.cardIndex <= #ts.cardsToPlay then
            local card = ts.cardsToPlay[ts.cardIndex]
            battleState.playCreature(state, card, false)
            ts.cardIndex = ts.cardIndex + 1
            state.enemyTurnTimer = 0.4
            return { type = 'play_card', card = card }
        else
            ts.phase = 3
            ts.attackDecisions = ai.getAttackDecisions(state.enemy.board, state.player.board)
            ts.actionIndex = 1
            state.enemyTurnTimer = 0.3
            return { type = 'start_attacks' }
        end
        
    elseif ts.phase == 3 then
        if state.phase == battleState.PHASES.VICTORY or state.phase == battleState.PHASES.DEFEAT then
            ts.phase = 4
            return { type = 'game_over' }
        elseif ts.actionIndex <= #ts.attackDecisions then
            local decision = ts.attackDecisions[ts.actionIndex]
            if decision.target.type == 'face' then
                battleState.attackFace(state, decision.attacker, false)
            else
                battleState.attackCreature(state, decision.attacker, decision.target.creature, false)
            end
            ts.actionIndex = ts.actionIndex + 1
            state.enemyTurnTimer = 0.4
            return { type = 'attack', decision = decision }
        else
            ts.phase = 4
            state.enemyTurnTimer = 0.3
            return { type = 'attacks_done' }
        end
        
    elseif ts.phase == 4 then
        if state.phase ~= battleState.PHASES.VICTORY and state.phase ~= battleState.PHASES.DEFEAT then
            battleState.startPlayerTurn(state)
        end
        ai.resetTurnState()
        return { type = 'end_turn' }
    end
    
    return nil
end

return ai
