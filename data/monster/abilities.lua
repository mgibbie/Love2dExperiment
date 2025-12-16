-- Ability Data (Loads from individual files)
local abilities = {}

-- Load the index of all ability IDs
local abilityIndex = require('data.monster.abilities._index')

-- Load each ability from its individual file
abilities.data = {}
for _, id in ipairs(abilityIndex) do
    local ok, data = pcall(require, 'data.monster.abilities.' .. id)
    if ok and data then
        abilities.data[id] = data
    end
end

return abilities


