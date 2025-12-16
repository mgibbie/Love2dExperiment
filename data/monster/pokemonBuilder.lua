-- Pokemon Builder
-- Creates random Pokemon instances with abilities, moves, IVs, EVs

local pokedex = require('data.monster.pokedex')
local moves = require('data.monster.moves')
local learnsets = require('data.monster.learnsets')

local builder = {}

-- Generate random IVs (0-31 for each stat)
function builder.randomIVs()
    return {
        hp = math.random(0, 31),
        atk = math.random(0, 31),
        def = math.random(0, 31),
        spa = math.random(0, 31),
        spd = math.random(0, 31),
        spe = math.random(0, 31)
    }
end

-- Generate random EVs (510 total, max 252 per stat)
function builder.randomEVs()
    local evs = { hp = 0, atk = 0, def = 0, spa = 0, spd = 0, spe = 0 }
    local stats = {'hp', 'atk', 'def', 'spa', 'spd', 'spe'}
    local remaining = 510
    
    -- Shuffle stats order for randomness
    for i = #stats, 2, -1 do
        local j = math.random(i)
        stats[i], stats[j] = stats[j], stats[i]
    end
    
    for _, stat in ipairs(stats) do
        local maxForStat = math.min(252, remaining)
        local amount = math.random(0, maxForStat)
        evs[stat] = amount
        remaining = remaining - amount
        if remaining <= 0 then break end
    end
    
    return evs
end

-- Calculate actual stat from base, IV, EV, level
function builder.calcStat(base, iv, ev, level, isHP)
    if isHP then
        return math.floor(((2 * base + iv + math.floor(ev / 4)) * level / 100) + level + 10)
    else
        return math.floor(((2 * base + iv + math.floor(ev / 4)) * level / 100) + 5)
    end
end

-- Get 4 random valid moves for a Pokemon
function builder.randomMoves(pokemonId)
    local validMoves = learnsets.getMovesFor(pokemonId)
    
    -- Filter to moves that exist in our moves data
    local available = {}
    for _, moveId in ipairs(validMoves) do
        if moves.data[moveId] then
            table.insert(available, moveId)
        end
    end
    
    -- If not enough moves, add some basic moves
    if #available < 4 then
        local defaults = {'tackle', 'scratch', 'pound', 'struggle'}
        for _, m in ipairs(defaults) do
            if moves.data[m] and #available < 4 then
                local found = false
                for _, existing in ipairs(available) do
                    if existing == m then found = true break end
                end
                if not found then table.insert(available, m) end
            end
        end
    end
    
    -- Shuffle and pick 4
    for i = #available, 2, -1 do
        local j = math.random(i)
        available[i], available[j] = available[j], available[i]
    end
    
    local selected = {}
    for i = 1, math.min(4, #available) do
        local moveId = available[i]
        local moveData = moves.data[moveId]
        table.insert(selected, {
            id = moveId,
            name = moveData.name,
            type = moveData.type,
            category = moveData.category,
            basePower = moveData.basePower,
            accuracy = moveData.accuracy,
            pp = moveData.pp,
            maxPP = moveData.pp,
            priority = moveData.priority
        })
    end
    
    return selected
end

-- Get random ability for a Pokemon
function builder.randomAbility(pokemonId)
    local species = pokedex.pokemon[pokemonId]
    if not species or not species.abilities or #species.abilities == 0 then
        return "No Ability"
    end
    return species.abilities[math.random(1, #species.abilities)]
end

-- Build a complete Pokemon instance
function builder.build(pokemonId, level)
    level = level or 50
    
    local species = pokedex.pokemon[pokemonId]
    if not species then
        return nil
    end
    
    local ivs = builder.randomIVs()
    local evs = builder.randomEVs()
    local base = species.baseStats
    
    local pokemon = {
        id = pokemonId,
        num = species.num,  -- Pokedex number for sprite loading
        name = species.name,
        level = level,
        types = species.types,
        ability = builder.randomAbility(pokemonId),
        
        -- Stats
        ivs = ivs,
        evs = evs,
        baseStats = base,
        
        stats = {
            hp = builder.calcStat(base.hp, ivs.hp, evs.hp, level, true),
            atk = builder.calcStat(base.atk, ivs.atk, evs.atk, level, false),
            def = builder.calcStat(base.def, ivs.def, evs.def, level, false),
            spa = builder.calcStat(base.spa, ivs.spa, evs.spa, level, false),
            spd = builder.calcStat(base.spd, ivs.spd, evs.spd, level, false),
            spe = builder.calcStat(base.spe, ivs.spe, evs.spe, level, false)
        },
        
        -- Current HP
        currentHP = 0,
        maxHP = 0,
        
        -- Moves
        moves = builder.randomMoves(pokemonId),
        
        -- Battle state
        status = nil,  -- burn, paralyze, poison, sleep, freeze
        statBoosts = { atk = 0, def = 0, spa = 0, spd = 0, spe = 0, accuracy = 0, evasion = 0 },
        fainted = false
    }
    
    pokemon.maxHP = pokemon.stats.hp
    pokemon.currentHP = pokemon.maxHP
    
    return pokemon
end

-- Build a random Pokemon
function builder.buildRandom(level)
    local id = pokedex.getRandom()
    return builder.build(id, level)
end

-- Build multiple random unique Pokemon
function builder.buildRandomTeam(count, level)
    local team = {}
    local usedIds = {}
    
    while #team < count do
        local id = pokedex.getRandom()
        if not usedIds[id] then
            usedIds[id] = true
            table.insert(team, builder.build(id, level))
        end
    end
    
    return team
end

-- Generate 3 random Pokemon options for draft
function builder.getDraftOptions(level, excludeIds)
    excludeIds = excludeIds or {}
    local options = {}
    local attempts = 0
    
    while #options < 3 and attempts < 100 do
        local id = pokedex.getRandom()
        local isExcluded = false
        
        for _, exId in ipairs(excludeIds) do
            if exId == id then isExcluded = true break end
        end
        
        for _, opt in ipairs(options) do
            if opt.id == id then isExcluded = true break end
        end
        
        if not isExcluded then
            table.insert(options, builder.build(id, level))
        end
        
        attempts = attempts + 1
    end
    
    return options
end

return builder

