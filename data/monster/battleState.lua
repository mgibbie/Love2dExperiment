-- Monster Battle State
-- Manages the state of a Pokemon battle

local damageCalc = require('data.monster.damageCalc')
local moveEffects = require('data.monster.moveEffects')

local battle = {}

-- Battle phases
battle.PHASES = {
    SELECT_ACTION = 'select_action',
    EXECUTE_TURN = 'execute_turn',
    SWITCH_POKEMON = 'switch_pokemon',
    ENEMY_SWITCHING = 'enemy_switching',  -- Enemy needs to switch (for animation)
    PLAYER_WIN = 'player_win',
    ENEMY_WIN = 'enemy_win'
}

-- Create a new battle state
function battle.create(playerTeam, enemyTeam)
    local state = {
        phase = battle.PHASES.SELECT_ACTION,
        
        player = {
            team = playerTeam,
            active = playerTeam[1],
            activeIndex = 1
        },
        
        enemy = {
            team = enemyTeam,
            active = enemyTeam[1],
            activeIndex = 1
        },
        
        turnCount = 0,
        log = {},
        
        -- For animations/delays
        pendingActions = {},
        animationTimer = 0
    }
    
    return state
end

-- Add message to battle log
function battle.log(state, message)
    table.insert(state.log, message)
    -- Keep log reasonable size
    while #state.log > 50 do
        table.remove(state.log, 1)
    end
end

-- Check if a team is fully fainted
function battle.isTeamFainted(team)
    for _, pokemon in ipairs(team) do
        if not pokemon.fainted then
            return false
        end
    end
    return true
end

-- Get first alive Pokemon in team
function battle.getFirstAlive(team)
    for i, pokemon in ipairs(team) do
        if not pokemon.fainted then
            return i, pokemon
        end
    end
    return nil, nil
end

-- Switch active Pokemon
function battle.switchPokemon(state, isPlayer, newIndex)
    local side = isPlayer and state.player or state.enemy
    local name = isPlayer and "You" or "Enemy"
    
    if side.team[newIndex] and not side.team[newIndex].fainted then
        local oldName = side.active.name
        side.activeIndex = newIndex
        side.active = side.team[newIndex]
        
        battle.log(state, name .. " switched from " .. oldName .. " to " .. side.active.name .. "!")
        
        -- Reset stat boosts on switch
        side.active.statBoosts = { atk = 0, def = 0, spa = 0, spd = 0, spe = 0, accuracy = 0, evasion = 0 }
        
        return true
    end
    return false
end

-- Stat stage names for logging
local statNames = {
    atk = "Attack", def = "Defense", spa = "Sp. Atk", spd = "Sp. Def", 
    spe = "Speed", accuracy = "accuracy", evasion = "evasiveness"
}

-- Apply stat changes to a Pokemon
function battle.applyStatChange(state, pokemon, stats, logPrefix)
    logPrefix = logPrefix or pokemon.name .. "'s"
    
    -- Ensure statBoosts exists
    if not pokemon.statBoosts then
        pokemon.statBoosts = { atk = 0, def = 0, spa = 0, spd = 0, spe = 0, accuracy = 0, evasion = 0 }
    end
    
    for stat, stages in pairs(stats) do
        local oldBoost = pokemon.statBoosts[stat] or 0
        local newBoost = math.max(-6, math.min(6, oldBoost + stages))
        local actualChange = newBoost - oldBoost
        
        pokemon.statBoosts[stat] = newBoost
        
        local statName = statNames[stat] or stat
        
        if actualChange > 0 then
            if actualChange == 1 then
                battle.log(state, logPrefix .. " " .. statName .. " rose!")
            elseif actualChange == 2 then
                battle.log(state, logPrefix .. " " .. statName .. " rose sharply!")
            else
                battle.log(state, logPrefix .. " " .. statName .. " rose drastically!")
            end
        elseif actualChange < 0 then
            if actualChange == -1 then
                battle.log(state, logPrefix .. " " .. statName .. " fell!")
            elseif actualChange == -2 then
                battle.log(state, logPrefix .. " " .. statName .. " fell harshly!")
            else
                battle.log(state, logPrefix .. " " .. statName .. " fell severely!")
            end
        elseif stages > 0 then
            battle.log(state, logPrefix .. " " .. statName .. " won't go any higher!")
        elseif stages < 0 then
            battle.log(state, logPrefix .. " " .. statName .. " won't go any lower!")
        end
    end
end

-- Status condition names
local statusNames = {
    paralysis = "paralyzed",
    burn = "burned",
    poison = "poisoned",
    badpoison = "badly poisoned",
    sleep = "fell asleep",
    freeze = "frozen"
}

-- Apply status condition
function battle.applyStatus(state, pokemon, status)
    if pokemon.status then
        battle.log(state, pokemon.name .. " is already " .. (statusNames[pokemon.status] or "affected") .. "!")
        return false
    end
    
    -- Type immunities
    local types = pokemon.types or {}
    local hasType = function(t)
        for _, pt in ipairs(types) do
            if pt:lower() == t:lower() then return true end
        end
        return false
    end
    
    if status == "paralysis" and hasType("electric") then
        battle.log(state, pokemon.name .. " is immune to paralysis!")
        return false
    elseif status == "burn" and hasType("fire") then
        battle.log(state, pokemon.name .. " is immune to burns!")
        return false
    elseif (status == "poison" or status == "badpoison") and (hasType("poison") or hasType("steel")) then
        battle.log(state, pokemon.name .. " is immune to poison!")
        return false
    elseif status == "freeze" and hasType("ice") then
        battle.log(state, pokemon.name .. " is immune to freezing!")
        return false
    end
    
    pokemon.status = status
    
    -- For badly poisoned, track turn counter
    if status == "badpoison" then
        pokemon.toxicCounter = 1
    end
    
    local statusText = statusNames[status] or "afflicted"
    battle.log(state, pokemon.name .. " " .. statusText .. "!")
    
    return true
end

-- Check if Pokemon can move (status effects)
function battle.canPokemonMove(state, pokemon)
    if not pokemon.status then
        return true
    end
    
    if pokemon.status == "paralysis" then
        if math.random(100) <= 25 then
            battle.log(state, pokemon.name .. " is paralyzed! It can't move!")
            return false
        end
    elseif pokemon.status == "sleep" then
        -- Check for wake up
        pokemon.sleepCounter = (pokemon.sleepCounter or 0) + 1
        if pokemon.sleepCounter >= math.random(1, 3) then
            pokemon.status = nil
            pokemon.sleepCounter = nil
            battle.log(state, pokemon.name .. " woke up!")
            return true
        else
            battle.log(state, pokemon.name .. " is fast asleep.")
            return false
        end
    elseif pokemon.status == "freeze" then
        -- 20% chance to thaw each turn
        if math.random(100) <= 20 then
            pokemon.status = nil
            battle.log(state, pokemon.name .. " thawed out!")
            return true
        else
            battle.log(state, pokemon.name .. " is frozen solid!")
            return false
        end
    end
    
    return true
end

-- Execute a move
function battle.executeMove(state, attacker, defender, move, isPlayer)
    local attackerName = attacker.name
    local defenderName = defender.name
    
    battle.log(state, attackerName .. " used " .. move.name .. "!")
    
    -- Check PP
    if move.pp <= 0 then
        battle.log(state, "But there's no PP left for this move!")
        return
    end
    
    -- Reduce PP
    move.pp = move.pp - 1
    
    -- Check if attacker can move (paralysis, sleep, freeze)
    if not battle.canPokemonMove(state, attacker) then
        return
    end
    
    -- Accuracy check for moves that need it
    local needsAccuracy = move.accuracy and move.accuracy > 0
    if needsAccuracy and not damageCalc.doesMoveHit(attacker, defender, move) then
        battle.log(state, attackerName .. "'s attack missed!")
        return
    end
    
    -- Get move effect
    local moveId = move.id or move.name:lower():gsub(" ", ""):gsub("-", "")
    local effect = moveEffects.get(moveId)
    
    -- Handle pure status moves (no base power)
    if move.category == "Status" or (move.basePower or 0) == 0 then
        if effect then
            battle.executeEffect(state, attacker, defender, effect, 0, isPlayer)
        else
            battle.log(state, "But nothing happened!")
        end
        return
    end
    
    -- Calculate and apply damage for damaging moves
    local damage, effectiveness, critical = damageCalc.calculateDamage(attacker, defender, move)
    
    defender.currentHP = math.max(0, defender.currentHP - damage)
    
    -- Log effectiveness
    local effText = damageCalc.getEffectivenessText(effectiveness)
    if effText then
        battle.log(state, "It's " .. effText .. "!")
    end
    
    if critical then
        battle.log(state, "A critical hit!")
    end
    
    battle.log(state, defenderName .. " took " .. damage .. " damage!")
    
    -- Apply secondary effects from damaging moves
    if effect and not defender.fainted then
        battle.executeEffect(state, attacker, defender, effect, damage, isPlayer)
    end
    
    -- Check faint
    battle.checkFaint(state, defender, isPlayer)
end

-- Execute move effect
function battle.executeEffect(state, attacker, defender, effect, damage, isPlayer)
    local targetPokemon = effect.target == "self" and attacker or defender
    
    if effect.type == "boost" then
        -- Stat boost/lower move
        battle.applyStatChange(state, targetPokemon, effect.stats, targetPokemon.name .. "'s")
        
    elseif effect.type == "heal" then
        -- Healing move
        local healAmount = math.floor(attacker.maxHP * effect.percent)
        local oldHP = attacker.currentHP
        attacker.currentHP = math.min(attacker.maxHP, attacker.currentHP + healAmount)
        local actualHeal = attacker.currentHP - oldHP
        battle.log(state, attacker.name .. " restored " .. actualHeal .. " HP!")
        
        -- Rest applies sleep
        if effect.applySleep then
            attacker.status = "sleep"
            attacker.sleepCounter = 0
            battle.log(state, attacker.name .. " fell asleep and became healthy!")
        end
        
    elseif effect.type == "drain" then
        -- Draining move - heal attacker based on damage dealt
        local healAmount = math.floor(damage * effect.percent)
        local oldHP = attacker.currentHP
        attacker.currentHP = math.min(attacker.maxHP, attacker.currentHP + healAmount)
        local actualHeal = attacker.currentHP - oldHP
        if actualHeal > 0 then
            battle.log(state, attacker.name .. " drained " .. actualHeal .. " HP!")
        end
        
    elseif effect.type == "status" then
        -- Pure status move
        battle.applyStatus(state, defender, effect.status)
        
    elseif effect.type == "chance_status" then
        -- Chance to apply status on hit
        if math.random(100) <= effect.chance then
            battle.applyStatus(state, defender, effect.status)
        end
        
        -- Handle recoil if present
        if effect.recoil and effect.recoil > 0 then
            local recoilDamage = math.floor(damage * effect.recoil)
            attacker.currentHP = math.max(0, attacker.currentHP - recoilDamage)
            battle.log(state, attacker.name .. " was hit with recoil!")
            battle.checkFaint(state, attacker, not isPlayer)
        end
        
    elseif effect.type == "chance_boost" then
        -- Chance to boost/lower stats on hit
        if math.random(100) <= effect.chance then
            battle.applyStatChange(state, targetPokemon, effect.stats, targetPokemon.name .. "'s")
        end
        
    elseif effect.type == "boost_on_hit" then
        -- Always boost stats on hit
        battle.applyStatChange(state, targetPokemon, effect.stats, targetPokemon.name .. "'s")
        
    elseif effect.type == "recoil" then
        -- Recoil damage
        local recoilDamage = math.floor(damage * effect.percent)
        attacker.currentHP = math.max(0, attacker.currentHP - recoilDamage)
        battle.log(state, attacker.name .. " was hit with recoil!")
        
        -- Check if attacker also has chance status
        if effect.chanceStatus and math.random(100) <= effect.chance then
            battle.applyStatus(state, defender, effect.chanceStatus)
        end
        
        battle.checkFaint(state, attacker, not isPlayer)
        
    elseif effect.type == "chance_flinch" then
        -- Flinching is not yet implemented, but we could add it here later
        -- For now, just skip
    end
end

-- Check if a Pokemon fainted and handle consequences
function battle.checkFaint(state, pokemon, wasPlayerAttacked)
    if pokemon.currentHP <= 0 and not pokemon.fainted then
        pokemon.fainted = true
        battle.log(state, pokemon.name .. " fainted!")
        
        -- Determine which side's Pokemon fainted
        local isPlayerPokemon = false
        for _, p in ipairs(state.player.team) do
            if p == pokemon then
                isPlayerPokemon = true
                break
            end
        end
        
        if isPlayerPokemon then
            if battle.isTeamFainted(state.player.team) then
                state.phase = battle.PHASES.ENEMY_WIN
                battle.log(state, "You lost the battle...")
            else
                state.phase = battle.PHASES.SWITCH_POKEMON
                battle.log(state, "Choose a Pokemon to send out!")
            end
        else
            if battle.isTeamFainted(state.enemy.team) then
                state.phase = battle.PHASES.PLAYER_WIN
                battle.log(state, "You won the battle!")
            else
                -- Enemy needs to switch - set phase for animation handling
                state.phase = battle.PHASES.ENEMY_SWITCHING
                state.pendingEnemySwitch = battle.getFirstAlive(state.enemy.team)
            end
        end
    end
end

-- Execute a turn (both sides act)
function battle.executeTurn(state, playerMove, enemyMove)
    state.turnCount = state.turnCount + 1
    battle.log(state, "--- Turn " .. state.turnCount .. " ---")
    
    local playerPokemon = state.player.active
    local enemyPokemon = state.enemy.active
    
    -- Determine turn order by speed (and priority)
    local playerPriority = playerMove.priority or 0
    local enemyPriority = enemyMove.priority or 0
    
    local playerFirst = false
    if playerPriority > enemyPriority then
        playerFirst = true
    elseif playerPriority < enemyPriority then
        playerFirst = false
    else
        -- Same priority, compare speed
        local playerSpeed = damageCalc.getEffectiveStat(playerPokemon, 'spe')
        local enemySpeed = damageCalc.getEffectiveStat(enemyPokemon, 'spe')
        
        if playerSpeed > enemySpeed then
            playerFirst = true
        elseif playerSpeed < enemySpeed then
            playerFirst = false
        else
            -- Speed tie - random
            playerFirst = math.random(1, 2) == 1
        end
    end
    
    -- Execute moves in order
    if playerFirst then
        battle.executeMove(state, playerPokemon, enemyPokemon, playerMove, true)
        
        if state.phase == battle.PHASES.SELECT_ACTION and not enemyPokemon.fainted then
            battle.executeMove(state, enemyPokemon, playerPokemon, enemyMove, false)
        end
    else
        battle.executeMove(state, enemyPokemon, playerPokemon, enemyMove, false)
        
        if state.phase == battle.PHASES.SELECT_ACTION and not playerPokemon.fainted then
            battle.executeMove(state, playerPokemon, enemyPokemon, playerMove, true)
        end
    end
    
    -- Return to action select if battle continues
    if state.phase == battle.PHASES.EXECUTE_TURN then
        state.phase = battle.PHASES.SELECT_ACTION
    end
end

-- Process end-of-turn status effects (burn, poison damage)
function battle.processStatusDamage(state, pokemon)
    if not pokemon or pokemon.fainted or not pokemon.status then
        return
    end
    
    if pokemon.status == "burn" then
        local burnDamage = math.max(1, math.floor(pokemon.maxHP / 16))
        pokemon.currentHP = math.max(0, pokemon.currentHP - burnDamage)
        battle.log(state, pokemon.name .. " is hurt by its burn!")
        
        -- Check if determining which team this pokemon belongs to
        battle.checkFaintFromStatus(state, pokemon)
        
    elseif pokemon.status == "poison" then
        local poisonDamage = math.max(1, math.floor(pokemon.maxHP / 8))
        pokemon.currentHP = math.max(0, pokemon.currentHP - poisonDamage)
        battle.log(state, pokemon.name .. " is hurt by poison!")
        
        battle.checkFaintFromStatus(state, pokemon)
        
    elseif pokemon.status == "badpoison" then
        pokemon.toxicCounter = (pokemon.toxicCounter or 1)
        local toxicDamage = math.max(1, math.floor(pokemon.maxHP * pokemon.toxicCounter / 16))
        pokemon.currentHP = math.max(0, pokemon.currentHP - toxicDamage)
        pokemon.toxicCounter = pokemon.toxicCounter + 1
        battle.log(state, pokemon.name .. " is hurt by poison!")
        
        battle.checkFaintFromStatus(state, pokemon)
    end
end

-- Check faint from status damage
function battle.checkFaintFromStatus(state, pokemon)
    if pokemon.currentHP <= 0 and not pokemon.fainted then
        pokemon.fainted = true
        battle.log(state, pokemon.name .. " fainted!")
        
        -- Determine which side
        local isPlayerPokemon = false
        for _, p in ipairs(state.player.team) do
            if p == pokemon then
                isPlayerPokemon = true
                break
            end
        end
        
        if isPlayerPokemon then
            if battle.isTeamFainted(state.player.team) then
                state.phase = battle.PHASES.ENEMY_WIN
                battle.log(state, "You lost the battle...")
            else
                state.phase = battle.PHASES.SWITCH_POKEMON
                battle.log(state, "Choose a Pokemon to send out!")
            end
        else
            if battle.isTeamFainted(state.enemy.team) then
                state.phase = battle.PHASES.PLAYER_WIN
                battle.log(state, "You won the battle!")
            else
                -- Enemy needs to switch - set phase for animation handling
                state.phase = battle.PHASES.ENEMY_SWITCHING
                state.pendingEnemySwitch = battle.getFirstAlive(state.enemy.team)
            end
        end
    end
end

-- Process all end-of-turn effects for both sides
function battle.processEndOfTurn(state)
    -- Process status damage for both active Pokemon
    if state.player.active and not state.player.active.fainted then
        battle.processStatusDamage(state, state.player.active)
    end
    
    if state.enemy.active and not state.enemy.active.fainted then
        battle.processStatusDamage(state, state.enemy.active)
    end
end

-- Heal entire team
function battle.healTeam(team)
    for _, pokemon in ipairs(team) do
        pokemon.currentHP = pokemon.maxHP
        pokemon.fainted = false
        pokemon.status = nil
        pokemon.statBoosts = { atk = 0, def = 0, spa = 0, spd = 0, spe = 0, accuracy = 0, evasion = 0 }
        
        -- Restore PP
        for _, move in ipairs(pokemon.moves) do
            move.pp = move.maxPP
        end
    end
end

return battle

