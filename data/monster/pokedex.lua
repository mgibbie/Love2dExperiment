-- Pokemon Data (Loads from individual files)
local pokedex = {}

-- Load the index of all pokemon IDs
local pokemonIndex = require('data.monster.pokemon._index')

-- Load each pokemon from its individual file
pokedex.pokemon = {}
for _, id in ipairs(pokemonIndex) do
    local ok, data = pcall(require, 'data.monster.pokemon.' .. id)
    if ok and data then
        pokedex.pokemon[id] = data
    end
end

-- Get list of all pokemon IDs
pokedex.allIds = {}
for id, _ in pairs(pokedex.pokemon) do
    table.insert(pokedex.allIds, id)
end

function pokedex.getRandom()
    return pokedex.allIds[math.random(1, #pokedex.allIds)]
end

return pokedex
