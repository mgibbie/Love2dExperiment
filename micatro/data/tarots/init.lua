-- Tarot Registry with Lazy Loading

local M = {}

local cache = {}

M.TAROT_KEYS = {
    "c_fool", "c_magician", "c_high_priestess", "c_empress", "c_emperor",
    "c_heirophant", "c_lovers", "c_chariot", "c_justice", "c_hermit",
    "c_wheel_of_fortune", "c_strength", "c_hanged_man", "c_death", "c_temperance",
    "c_devil", "c_tower", "c_star", "c_moon", "c_sun",
    "c_judgement", "c_world"
}

function M.get(key)
    if not key then return nil end
    if cache[key] then return cache[key] end
    
    local ok, data = pcall(require, "micatro.data.tarots." .. key)
    if ok and data then
        cache[key] = data
        return data
    end
    return nil
end

function M.getAll()
    local all = {}
    for _, key in ipairs(M.TAROT_KEYS) do
        local item = M.get(key)
        if item then all[key] = item end
    end
    return all
end

function M.getRandom()
    local key = M.TAROT_KEYS[math.random(#M.TAROT_KEYS)]
    return M.get(key)
end

function M.count()
    return #M.TAROT_KEYS
end

M.TAROTS = setmetatable({}, {
    __index = function(t, key) return M.get(key) end,
    __pairs = function(t) return pairs(M.getAll()) end
})

return M

