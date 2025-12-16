-- Spectral Registry with Lazy Loading

local M = {}

local cache = {}

M.SPECTRAL_KEYS = {
    "c_familiar", "c_grim", "c_incantation", "c_talisman", "c_aura",
    "c_wraith", "c_sigil", "c_ouija", "c_ectoplasm", "c_immolate",
    "c_ankh", "c_deja_vu", "c_hex", "c_trance", "c_medium",
    "c_cryptid", "c_soul", "c_black_hole"
}

function M.get(key)
    if not key then return nil end
    if cache[key] then return cache[key] end
    
    local ok, data = pcall(require, "micatro.data.spectrals." .. key)
    if ok and data then
        cache[key] = data
        return data
    end
    return nil
end

function M.getAll()
    local all = {}
    for _, key in ipairs(M.SPECTRAL_KEYS) do
        local item = M.get(key)
        if item then all[key] = item end
    end
    return all
end

function M.getRandom()
    local key = M.SPECTRAL_KEYS[math.random(#M.SPECTRAL_KEYS)]
    return M.get(key)
end

function M.count()
    return #M.SPECTRAL_KEYS
end

M.SPECTRALS = setmetatable({}, {
    __index = function(t, key) return M.get(key) end,
    __pairs = function(t) return pairs(M.getAll()) end
})

return M

