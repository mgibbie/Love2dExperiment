-- Planet Registry with Lazy Loading

local M = {}

local cache = {}

M.PLANET_KEYS = {
    "c_mercury", "c_venus", "c_earth", "c_mars", "c_jupiter",
    "c_saturn", "c_uranus", "c_neptune", "c_pluto", "c_planet_x",
    "c_ceres", "c_eris"
}

function M.get(key)
    if not key then return nil end
    if cache[key] then return cache[key] end
    
    local ok, data = pcall(require, "micatro.data.planets." .. key)
    if ok and data then
        cache[key] = data
        return data
    end
    return nil
end

function M.getAll()
    local all = {}
    for _, key in ipairs(M.PLANET_KEYS) do
        local item = M.get(key)
        if item then all[key] = item end
    end
    return all
end

function M.getRandom()
    local key = M.PLANET_KEYS[math.random(#M.PLANET_KEYS)]
    return M.get(key)
end

function M.count()
    return #M.PLANET_KEYS
end

M.PLANETS = setmetatable({}, {
    __index = function(t, key) return M.get(key) end,
    __pairs = function(t) return pairs(M.getAll()) end
})

return M

