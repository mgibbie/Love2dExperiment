-- Battle State Management
-- Core state and logic for the card game

local helpers = require('data.battleHelpers')
local battleState = {}

-- Battle phases
battleState.PHASES = {
    DRAW = 'draw',
    MAIN = 'main',
    COMBAT = 'combat',
    END = 'end',
    ENEMY_TURN = 'enemy_turn',
    VICTORY = 'victory',
    DEFEAT = 'defeat'
}

-- Create initial player state
function battleState.createPlayerState(heroClass)
    heroClass = heroClass or 'centurion'
    return {
        life = 40,
        maxLife = 40,
        mana = 1,
        maxMana = 1,
        armor = 0,
        heroClass = heroClass,
        heroIcon = '🦸',
        hand = {},
        deck = {},
        graveyard = {},
        board = {}
    }
end

-- Create initial enemy state
function battleState.createEnemyState()
    return {
        life = 30,
        maxLife = 30,
        mana = 1,
        maxMana = 1,
        armor = 0,
        heroClass = 'neutral',
        heroIcon = '👹',
        hand = {},
        deck = {},
        graveyard = {},
        board = {}
    }
end

-- Create the main battle state
function battleState.create()
    local state = {
        player = battleState.createPlayerState('centurion'),
        enemy = battleState.createEnemyState(),
        turnNumber = 1,
        phase = battleState.PHASES.DRAW,
        selectedCard = nil,
        selectedCreature = nil,
        attackingCreature = nil,
        targetingSpell = nil,
        log = {},
        animationQueue = {},
        enemyTurnTimer = 0,
        enemyActions = {}
    }
    
    return state
end

-- Add to battle log
function battleState.addLog(state, message)
    table.insert(state.log, message)
    if #state.log > 50 then
        table.remove(state.log, 1)
    end
end

-- Draw a card for player or enemy
function battleState.drawCard(state, isPlayer)
    local target = isPlayer and state.player or state.enemy
    
    -- Check if deck is empty - shuffle graveyard
    if #target.deck == 0 and #target.graveyard > 0 then
        target.deck = helpers.shuffle(target.graveyard)
        target.graveyard = {}
        battleState.addLog(state, (isPlayer and "Your" or "Enemy") .. " graveyard shuffled into deck!")
    end
    
    if #target.deck == 0 then
        battleState.addLog(state, (isPlayer and "You have" or "Enemy has") .. " no cards to draw!")
        return nil
    end
    
    if #target.hand >= 10 then
        battleState.addLog(state, (isPlayer and "Your" or "Enemy") .. " hand is full!")
        return nil
    end
    
    local drawnCard = table.remove(target.deck, 1)
    table.insert(target.hand, drawnCard)
    
    if isPlayer then
        battleState.addLog(state, "You draw " .. drawnCard.card.name)
    else
        battleState.addLog(state, "Enemy draws a card")
    end
    
    return drawnCard
end

-- Check if a card can be played
function battleState.canPlayCard(state, cardInstance, isPlayer)
    local owner = isPlayer and state.player or state.enemy
    return helpers.canPlayCard(cardInstance, owner, isPlayer and state.enemy.board or state.player.board)
end

-- Play a creature card
function battleState.playCreature(state, cardInstance, isPlayer, position)
    local owner = isPlayer and state.player or state.enemy
    
    if cardInstance.card.cost > owner.mana then
        battleState.addLog(state, "Not enough mana!")
        return false
    end
    
    -- Spend mana
    owner.mana = owner.mana - cardInstance.card.cost
    
    -- Remove from hand
    for i, card in ipairs(owner.hand) do
        if card.instanceId == cardInstance.instanceId then
            table.remove(owner.hand, i)
            break
        end
    end
    
    -- Create creature and add to board
    local creature = helpers.createCreatureFromCard(cardInstance)
    
    if position then
        table.insert(owner.board, position, creature)
    else
        table.insert(owner.board, creature)
    end
    
    battleState.addLog(state, (isPlayer and "You play " or "Enemy plays ") .. cardInstance.card.name)
    
    -- Handle battlecry
    battleState.handleBattlecry(state, creature, isPlayer)
    
    return true
end

-- Play a spell card
function battleState.playSpell(state, cardInstance, isPlayer, target)
    local owner = isPlayer and state.player or state.enemy
    
    if cardInstance.card.cost > owner.mana then
        battleState.addLog(state, "Not enough mana!")
        return false
    end
    
    -- Spend mana
    owner.mana = owner.mana - cardInstance.card.cost
    
    -- Remove from hand
    for i, card in ipairs(owner.hand) do
        if card.instanceId == cardInstance.instanceId then
            table.remove(owner.hand, i)
            break
        end
    end
    
    -- Add to graveyard
    table.insert(owner.graveyard, cardInstance)
    
    battleState.addLog(state, (isPlayer and "You cast " or "Enemy casts ") .. cardInstance.card.name)
    
    -- Handle spell effects
    battleState.handleSpellEffect(state, cardInstance.card, isPlayer, target)
    
    return true
end

-- Handle battlecry effects
function battleState.handleBattlecry(state, creature, isPlayer)
    local card = creature.card
    local effect = string.lower(card.effect or '')
    
    if not string.find(effect, 'battlecry') then return end
    
    -- Draw cards
    local drawMatch = string.match(effect, 'draw (%d+) cards?') or (string.find(effect, 'draw a card') and '1')
    if drawMatch then
        local count = tonumber(drawMatch) or 1
        for i = 1, count do
            battleState.drawCard(state, isPlayer)
        end
        battleState.addLog(state, card.name .. "'s Battlecry: Draw " .. count .. " card(s)!")
    end
    
    -- Deal damage
    local damageMatch = string.match(effect, 'deal (%d+) damage')
    if damageMatch then
        local damage = tonumber(damageMatch)
        local targetBoard = isPlayer and state.enemy.board or state.player.board
        if #targetBoard > 0 then
            local target = targetBoard[math.random(1, #targetBoard)]
            target.currentHealth = target.currentHealth - damage
            battleState.addLog(state, card.name .. "'s Battlecry deals " .. damage .. " damage to " .. target.card.name .. "!")
            battleState.checkDeaths(state)
        else
            -- Hit face if no creatures
            local targetPlayer = isPlayer and state.enemy or state.player
            targetPlayer.life = targetPlayer.life - damage
            battleState.addLog(state, card.name .. "'s Battlecry deals " .. damage .. " damage to " .. (isPlayer and "enemy" or "you") .. "!")
        end
    end
end

-- Handle spell effects
function battleState.handleSpellEffect(state, card, isPlayer, target)
    local effect = string.lower(card.effect or '')
    
    -- Deal damage
    local damageMatch = string.match(effect, 'deal (%d+) damage')
    if damageMatch then
        local damage = tonumber(damageMatch)
        if target and target.type == 'creature' then
            target.creature.currentHealth = target.creature.currentHealth - damage
            battleState.addLog(state, card.name .. " deals " .. damage .. " damage to " .. target.creature.card.name .. "!")
            battleState.checkDeaths(state)
        elseif target and target.type == 'face' then
            local targetPlayer = target.isPlayer and state.player or state.enemy
            targetPlayer.life = targetPlayer.life - damage
            battleState.addLog(state, card.name .. " deals " .. damage .. " damage to " .. (target.isPlayer and "you" or "enemy") .. "!")
        end
        battleState.checkVictory(state)
    end
    
    -- Healing
    local healMatch = string.match(effect, 'restore (%d+) health')
    if healMatch and string.find(effect, 'hero') then
        local healing = tonumber(healMatch)
        local owner = isPlayer and state.player or state.enemy
        owner.life = math.min(owner.maxLife, owner.life + healing)
        battleState.addLog(state, (isPlayer and "You" or "Enemy") .. " restore " .. healing .. " health!")
    end
    
    -- Buff all friendly creatures
    local buffAllMatch = string.match(effect, 'give all friendly creatures %+(%d+)/%+(%d+)')
    if buffAllMatch then
        local atkBuff = tonumber(string.match(effect, '%+(%d+)/')) or 0
        local hpBuff = tonumber(string.match(effect, '/%+(%d+)')) or 0
        local board = isPlayer and state.player.board or state.enemy.board
        for _, creature in ipairs(board) do
            helpers.applyBuff(creature, atkBuff, hpBuff, false)
        end
        battleState.addLog(state, card.name .. " gives all friendly creatures +" .. atkBuff .. "/+" .. hpBuff .. "!")
    end
    
    -- Single target buff
    if string.find(effect, 'give a creature') and target and target.type == 'creature' then
        local atkBuff = tonumber(string.match(effect, '%+(%d+)/')) or 0
        local hpBuff = tonumber(string.match(effect, '/%+(%d+)')) or 0
        local addTaunt = string.find(effect, 'taunt') ~= nil
        helpers.applyBuff(target.creature, atkBuff, hpBuff, addTaunt)
        battleState.addLog(state, card.name .. " buffs " .. target.creature.card.name .. "!")
    end
end

-- Creature attacks another creature
function battleState.attackCreature(state, attacker, defender, attackerIsPlayer)
    if not attacker.canAttack or attacker.hasAttacked then
        battleState.addLog(state, "This creature can't attack!")
        return false
    end
    
    -- Check taunt
    local defenderBoard = attackerIsPlayer and state.enemy.board or state.player.board
    if helpers.hasTauntCreatures(defenderBoard) and not helpers.hasKeyword(defender, 'Taunt') then
        battleState.addLog(state, "Must attack a creature with Taunt first!")
        return false
    end
    
    -- Handle Divine Shield
    local defenderHasShield = helpers.hasKeyword(defender, 'Divine Shield')
    local attackerHasShield = helpers.hasKeyword(attacker, 'Divine Shield')
    
    -- Handle Deathtouch
    local attackerHasDeathtouch = helpers.hasKeyword(attacker, 'Deathtouch')
    local defenderHasDeathtouch = helpers.hasKeyword(defender, 'Deathtouch')
    
    -- Deal damage
    if defenderHasShield then
        helpers.removeKeyword(defender, 'Divine Shield')
        battleState.addLog(state, defender.card.name .. "'s Divine Shield absorbs the damage!")
    elseif attacker.currentAttack > 0 then
        defender.currentHealth = defender.currentHealth - attacker.currentAttack
        if attackerHasDeathtouch and defender.currentHealth > 0 then
            defender.currentHealth = 0
            battleState.addLog(state, attacker.card.name .. "'s Deathtouch destroys " .. defender.card.name .. "!")
        end
    end
    
    if attackerHasShield then
        helpers.removeKeyword(attacker, 'Divine Shield')
        battleState.addLog(state, attacker.card.name .. "'s Divine Shield absorbs the damage!")
    elseif defender.currentAttack > 0 then
        attacker.currentHealth = attacker.currentHealth - defender.currentAttack
        if defenderHasDeathtouch and attacker.currentHealth > 0 then
            attacker.currentHealth = 0
            battleState.addLog(state, defender.card.name .. "'s Deathtouch destroys " .. attacker.card.name .. "!")
        end
    end
    
    battleState.addLog(state, attacker.card.name .. " attacks " .. defender.card.name .. "!")
    
    attacker.hasAttacked = true
    
    battleState.checkDeaths(state)
    battleState.checkVictory(state)
    
    return true
end

-- Creature attacks face
function battleState.attackFace(state, attacker, attackerIsPlayer)
    if not attacker.canAttack or attacker.hasAttacked then
        battleState.addLog(state, "This creature can't attack!")
        return false
    end
    
    -- Check if Rush creature trying to attack face
    if helpers.hasKeyword(attacker, 'Rush') and not attacker.canAttackFace then
        battleState.addLog(state, "Rush creatures can only attack creatures on their first turn!")
        return false
    end
    
    -- Check taunt
    local enemyBoard = attackerIsPlayer and state.enemy.board or state.player.board
    if helpers.hasTauntCreatures(enemyBoard) then
        battleState.addLog(state, "Must attack a creature with Taunt first!")
        return false
    end
    
    local target = attackerIsPlayer and state.enemy or state.player
    target.life = target.life - attacker.currentAttack
    
    battleState.addLog(state, attacker.card.name .. " attacks " .. (attackerIsPlayer and "enemy" or "you") .. " for " .. attacker.currentAttack .. "!")
    
    attacker.hasAttacked = true
    
    battleState.checkVictory(state)
    
    return true
end

-- Check for dead creatures and handle deathrattles
function battleState.checkDeaths(state)
    -- Process player board
    local playerAlive, playerDead = helpers.filterDeadCreatures(state.player.board)
    for _, creature in ipairs(playerDead) do
        battleState.addLog(state, "Your " .. creature.card.name .. " dies!")
        battleState.handleDeathrattle(state, creature, true)
    end
    state.player.board = playerAlive
    for _, card in ipairs(helpers.creaturesToGraveyard(playerDead)) do
        table.insert(state.player.graveyard, card)
    end
    
    -- Process enemy board
    local enemyAlive, enemyDead = helpers.filterDeadCreatures(state.enemy.board)
    for _, creature in ipairs(enemyDead) do
        battleState.addLog(state, "Enemy " .. creature.card.name .. " dies!")
        battleState.handleDeathrattle(state, creature, false)
    end
    state.enemy.board = enemyAlive
    for _, card in ipairs(helpers.creaturesToGraveyard(enemyDead)) do
        table.insert(state.enemy.graveyard, card)
    end
end

-- Handle deathrattle effects
function battleState.handleDeathrattle(state, creature, isPlayer)
    local card = creature.card
    local effect = string.lower(card.effect or '')
    
    if not helpers.hasKeyword(creature, 'Deathrattle') then return end
    
    -- Deal damage
    local damageMatch = string.match(effect, 'deal (%d+) damage')
    if damageMatch then
        local damage = tonumber(damageMatch)
        local targetBoard = isPlayer and state.enemy.board or state.player.board
        
        if string.find(effect, 'random') then
            -- Random target (creatures + face)
            if #targetBoard > 0 and math.random() > 0.3 then
                local target = targetBoard[math.random(1, #targetBoard)]
                target.currentHealth = target.currentHealth - damage
                battleState.addLog(state, card.name .. "'s Deathrattle deals " .. damage .. " damage to " .. target.card.name .. "!")
            else
                local targetPlayer = isPlayer and state.enemy or state.player
                targetPlayer.life = targetPlayer.life - damage
                battleState.addLog(state, card.name .. "'s Deathrattle deals " .. damage .. " damage to " .. (isPlayer and "enemy" or "you") .. "!")
            end
        end
    end
    
    -- Summon tokens
    if string.find(effect, 'summon') then
        local tokenMatch = string.match(effect, 'summon a (%d+)/(%d+)')
        if tokenMatch then
            local attack = tonumber(string.match(effect, 'summon a (%d+)/')) or 1
            local health = tonumber(string.match(effect, '/(%d+)')) or 1
            local tokenCard = {
                id = 'token',
                name = 'Token',
                type = 'creature',
                cardClass = 'neutral',
                rarity = 'common',
                cost = 0,
                attack = attack,
                health = health,
                effect = '',
                keywords = {}
            }
            local token = helpers.createCreatureFromCard(helpers.createCardInstance(tokenCard))
            token.canAttack = false -- Summoning sickness
            local board = isPlayer and state.player.board or state.enemy.board
            table.insert(board, token)
            battleState.addLog(state, card.name .. "'s Deathrattle summons a token!")
        end
    end
end

-- Check victory/defeat conditions
function battleState.checkVictory(state)
    if state.enemy.life <= 0 then
        state.phase = battleState.PHASES.VICTORY
        battleState.addLog(state, "VICTORY!")
        return true
    end
    if state.player.life <= 0 then
        state.phase = battleState.PHASES.DEFEAT
        battleState.addLog(state, "DEFEAT!")
        return true
    end
    return false
end

-- End player turn
function battleState.endTurn(state)
    -- Trigger end of turn effects
    battleState.triggerEndOfTurnEffects(state, true)
    
    state.phase = battleState.PHASES.ENEMY_TURN
    state.attackingCreature = nil
    state.selectedCard = nil
    state.targetingSpell = nil
    
    battleState.addLog(state, "--- Enemy Turn ---")
    
    -- Set up enemy turn timer
    state.enemyTurnTimer = 0.5
    state.enemyActions = {}
end

-- Start enemy turn (called after delay)
function battleState.startEnemyTurn(state)
    -- Increase enemy mana
    state.enemy.maxMana = math.min(12, state.enemy.maxMana + 1)
    state.enemy.mana = state.enemy.maxMana
    
    -- Refresh creatures
    for _, creature in ipairs(state.enemy.board) do
        creature.canAttack = true
        creature.hasAttacked = false
        creature.canAttackFace = true
    end
    
    -- Draw a card
    battleState.drawCard(state, false)
end

-- End enemy turn and start player turn
function battleState.startPlayerTurn(state)
    -- Trigger enemy end of turn effects
    battleState.triggerEndOfTurnEffects(state, false)
    
    state.turnNumber = state.turnNumber + 1
    
    -- Increase player mana
    state.player.maxMana = math.min(12, state.player.maxMana + 1)
    state.player.mana = state.player.maxMana
    
    -- Refresh creatures
    for _, creature in ipairs(state.player.board) do
        creature.canAttack = true
        creature.hasAttacked = false
        creature.canAttackFace = true
    end
    
    state.phase = battleState.PHASES.MAIN
    battleState.addLog(state, "--- Your Turn " .. state.turnNumber .. " (" .. state.player.maxMana .. " Mana) ---")
    
    -- Draw a card
    battleState.drawCard(state, true)
end

-- Trigger end of turn effects
function battleState.triggerEndOfTurnEffects(state, isPlayer)
    local board = isPlayer and state.player.board or state.enemy.board
    
    for _, creature in ipairs(board) do
        local effect = string.lower(creature.card.effect or '')
        
        -- End of turn healing
        local healMatch = string.match(effect, 'restore (%d+) health to your hero')
        if healMatch and string.find(effect, 'end of turn') then
            local healing = tonumber(healMatch)
            local owner = isPlayer and state.player or state.enemy
            owner.life = math.min(owner.maxLife, owner.life + healing)
            battleState.addLog(state, creature.card.name .. " restores " .. healing .. " health!")
        end
    end
end

-- Initialize a new battle
function battleState.initBattle(state, heroClass)
    heroClass = heroClass or 'centurion'
    
    state.player = battleState.createPlayerState(heroClass)
    state.enemy = battleState.createEnemyState()
    
    state.player.deck = helpers.createDeck(heroClass)
    state.enemy.deck = helpers.createEnemyDeck()
    
    state.turnNumber = 1
    state.phase = battleState.PHASES.MAIN
    state.log = {"Battle Start!"}
    state.selectedCard = nil
    state.selectedCreature = nil
    state.attackingCreature = nil
    state.targetingSpell = nil
    state.enemyTurnTimer = 0
    state.enemyActions = {}
    
    -- Draw starting hands (4 cards each)
    for i = 1, 4 do
        battleState.drawCard(state, true)
        battleState.drawCard(state, false)
    end
    
    battleState.addLog(state, "--- Your Turn 1 ---")
end

return battleState

