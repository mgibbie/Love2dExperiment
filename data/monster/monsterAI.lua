-- Monster AI
-- Enemy decision making for Pokemon battles

local types = require('data.monster.types')
local damageCalc = require('data.monster.damageCalc')

local ai = {}

-- Score a move based on expected damage and type effectiveness
function ai.scoreMove(attacker, defender, move)
    -- Status moves get low score for now
    if move.category == "Status" or move.basePower == 0 then
        return 10
    end
    
    -- Check PP
    if move.pp <= 0 then
        return 0
    end
    
    -- Calculate expected damage
    local damage = damageCalc.calculateDamage(attacker, defender, move)
    
    -- Get type effectiveness bonus
    local effectiveness = types.getDualEffectiveness(move.type, defender.types)
    
    -- Score based on damage relative to defender's HP
    local damagePercent = damage / defender.maxHP * 100
    local score = damagePercent
    
    -- Bonus for super effective
    if effectiveness >= 2 then
        score = score * 1.5
    end
    
    -- Penalty for not very effective
    if effectiveness < 1 and effectiveness > 0 then
        score = score * 0.5
    end
    
    -- Zero for immune
    if effectiveness == 0 then
        score = 0
    end
    
    -- STAB bonus consideration
    if damageCalc.hasSTAB(attacker, move.type) then
        score = score * 1.1
    end
    
    -- Accuracy consideration
    local accuracy = move.accuracy
    if type(accuracy) == "number" and accuracy < 100 then
        score = score * (accuracy / 100)
    end
    
    -- Priority moves get bonus when low HP
    if move.priority and move.priority > 0 then
        if attacker.currentHP < attacker.maxHP * 0.3 then
            score = score * 1.3
        end
    end
    
    return score
end

-- Choose the best move for the AI
function ai.chooseMove(attacker, defender)
    local bestMove = nil
    local bestScore = -1
    
    for _, move in ipairs(attacker.moves) do
        local score = ai.scoreMove(attacker, defender, move)
        
        -- Add some randomness
        score = score * (0.9 + math.random() * 0.2)
        
        if score > bestScore then
            bestScore = score
            bestMove = move
        end
    end
    
    -- Fallback to first move with PP
    if not bestMove then
        for _, move in ipairs(attacker.moves) do
            if move.pp > 0 then
                return move
            end
        end
    end
    
    return bestMove
end

-- Decide whether to switch Pokemon
function ai.shouldSwitch(activeEnemy, playerActive, enemyTeam)
    -- Check if heavily disadvantaged by type
    local dominated = false
    
    for _, move in ipairs(playerActive.moves) do
        if move.basePower and move.basePower > 0 then
            local effectiveness = types.getDualEffectiveness(move.type, activeEnemy.types)
            if effectiveness >= 2 then
                dominated = true
                break
            end
        end
    end
    
    if not dominated then
        return false, nil
    end
    
    -- Look for a better matchup
    for i, pokemon in ipairs(enemyTeam) do
        if not pokemon.fainted and pokemon ~= activeEnemy then
            -- Check if this Pokemon resists player's types
            local resists = false
            for _, move in ipairs(playerActive.moves) do
                if move.basePower and move.basePower > 0 then
                    local eff = types.getDualEffectiveness(move.type, pokemon.types)
                    if eff < 1 then
                        resists = true
                        break
                    end
                end
            end
            
            if resists then
                -- 30% chance to switch
                if math.random() < 0.3 then
                    return true, i
                end
            end
        end
    end
    
    return false, nil
end

-- Get AI action for the turn
function ai.getAction(state)
    local enemy = state.enemy.active
    local player = state.player.active
    
    -- Check if should switch (rarely)
    local shouldSwitch, switchIndex = ai.shouldSwitch(enemy, player, state.enemy.team)
    if shouldSwitch and switchIndex then
        return { type = 'switch', index = switchIndex }
    end
    
    -- Choose best move
    local move = ai.chooseMove(enemy, player)
    return { type = 'move', move = move }
end

return ai

