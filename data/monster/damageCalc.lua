-- Damage Calculation
-- Pokemon damage formula with type effectiveness and modifiers

local types = require('data.monster.types')

local calc = {}

-- Get stat with boosts and status effects applied
function calc.getEffectiveStat(pokemon, statName)
    local base = pokemon.stats[statName]
    local boost = pokemon.statBoosts[statName] or 0
    
    -- Boost multipliers: -6 to +6 stages
    local multipliers = {
        [-6] = 2/8, [-5] = 2/7, [-4] = 2/6, [-3] = 2/5, [-2] = 2/4, [-1] = 2/3,
        [0] = 1,
        [1] = 3/2, [2] = 4/2, [3] = 5/2, [4] = 6/2, [5] = 7/2, [6] = 8/2
    }
    
    local value = math.floor(base * (multipliers[boost] or 1))
    
    -- Status effect modifiers
    local status = pokemon.status
    if status then
        -- Burn halves Attack
        if statName == "atk" and status == "burn" then
            value = math.floor(value * 0.5)
        end
        -- Paralysis halves Speed
        if statName == "spe" and status == "paralysis" then
            value = math.floor(value * 0.5)
        end
    end
    
    return value
end

-- Check if move gets STAB (Same Type Attack Bonus)
function calc.hasSTAB(pokemon, moveType)
    for _, pType in ipairs(pokemon.types) do
        if pType == moveType then
            return true
        end
    end
    return false
end

-- Calculate damage
function calc.calculateDamage(attacker, defender, move)
    -- Status moves don't deal damage
    if move.category == "Status" then
        return 0
    end
    
    -- Get the right stats based on move category
    local atkStat, defStat
    if move.category == "Physical" then
        atkStat = calc.getEffectiveStat(attacker, 'atk')
        defStat = calc.getEffectiveStat(defender, 'def')
    else -- Special
        atkStat = calc.getEffectiveStat(attacker, 'spa')
        defStat = calc.getEffectiveStat(defender, 'spd')
    end
    
    local level = attacker.level
    local power = move.basePower
    
    -- Base damage formula
    local damage = math.floor(((2 * level / 5 + 2) * power * atkStat / defStat) / 50 + 2)
    
    -- STAB (1.5x)
    if calc.hasSTAB(attacker, move.type) then
        damage = math.floor(damage * 1.5)
    end
    
    -- Type effectiveness
    local effectiveness = types.getDualEffectiveness(move.type, defender.types)
    damage = math.floor(damage * effectiveness)
    
    -- Critical hit (1/16 chance, 1.5x damage)
    local critical = false
    if math.random(1, 16) == 1 then
        damage = math.floor(damage * 1.5)
        critical = true
    end
    
    -- Random factor (0.85 to 1.0)
    local randomFactor = (math.random(85, 100) / 100)
    damage = math.floor(damage * randomFactor)
    
    -- Minimum 1 damage for damaging moves
    if damage < 1 and power > 0 then
        damage = 1
    end
    
    return damage, effectiveness, critical
end

-- Check if move hits (accuracy check)
function calc.doesMoveHit(attacker, defender, move)
    if move.accuracy == 100 or move.accuracy == true then
        -- Account for accuracy/evasion boosts
        local accBoost = attacker.statBoosts.accuracy or 0
        local evaBoost = defender.statBoosts.evasion or 0
        local netBoost = accBoost - evaBoost
        
        if netBoost >= 0 then
            return true
        end
        
        -- Negative accuracy situation
        local hitChance = 100 * (3 / (3 - netBoost))
        return math.random(1, 100) <= hitChance
    end
    
    local baseAccuracy = move.accuracy
    local accBoost = attacker.statBoosts.accuracy or 0
    local evaBoost = defender.statBoosts.evasion or 0
    
    local accMult = {
        [-6] = 3/9, [-5] = 3/8, [-4] = 3/7, [-3] = 3/6, [-2] = 3/5, [-1] = 3/4,
        [0] = 1,
        [1] = 4/3, [2] = 5/3, [3] = 6/3, [4] = 7/3, [5] = 8/3, [6] = 9/3
    }
    
    local finalAcc = baseAccuracy * (accMult[accBoost] or 1) / (accMult[evaBoost] or 1)
    
    return math.random(1, 100) <= finalAcc
end

-- Get effectiveness text
function calc.getEffectivenessText(effectiveness)
    if effectiveness >= 2 then
        return "super effective"
    elseif effectiveness == 0 then
        return "no effect"
    elseif effectiveness < 1 then
        return "not very effective"
    end
    return nil
end

return calc

