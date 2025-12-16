-- Move Data (Loads from individual files)
local moves = {}

-- Load the index of all move IDs
local moveIndex = require('data.monster.moves._index')

-- Load each move from its individual file
moves.data = {}
for _, id in ipairs(moveIndex) do
    local ok, data = pcall(require, 'data.monster.moves.' .. id)
    if ok and data then
        moves.data[id] = data
    end
end

return moves
