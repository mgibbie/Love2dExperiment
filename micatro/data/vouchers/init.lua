-- Voucher Registry with Lazy Loading

local M = {}

local cache = {}

M.VOUCHER_KEYS = {
    "v_overstock_norm", "v_overstock_plus", "v_clearance_sale", "v_liquidation",
    "v_hone", "v_glow_up", "v_reroll_surplus", "v_reroll_glut",
    "v_crystal_ball", "v_omen_globe", "v_telescope", "v_observatory",
    "v_grabber", "v_nacho_tong", "v_wasteful", "v_recyclomancy",
    "v_tarot_merchant", "v_tarot_tycoon", "v_planet_merchant", "v_planet_tycoon",
    "v_seed_money", "v_money_tree", "v_blank", "v_antimatter",
    "v_magic_trick", "v_illusion", "v_hieroglyph", "v_petroglyph",
    "v_directors_cut", "v_retcon", "v_paint_brush", "v_palette"
}

function M.get(key)
    if not key then return nil end
    if cache[key] then return cache[key] end
    
    local ok, data = pcall(require, "micatro.data.vouchers." .. key)
    if ok and data then
        cache[key] = data
        return data
    end
    return nil
end

function M.getAll()
    local all = {}
    for _, key in ipairs(M.VOUCHER_KEYS) do
        local item = M.get(key)
        if item then all[key] = item end
    end
    return all
end

function M.getRandomForShop()
    local available = {}
    for _, key in ipairs(M.VOUCHER_KEYS) do
        local v = M.get(key)
        if v and not v.requires then
            table.insert(available, v)
        end
    end
    if #available > 0 then
        return available[math.random(#available)]
    end
    return nil
end

-- Get available vouchers (not yet owned and requirements met)
function M.getAvailable(ownedVouchers)
    ownedVouchers = ownedVouchers or {}
    local ownedSet = {}
    for _, v in ipairs(ownedVouchers) do
        ownedSet[v.key or v] = true
    end
    
    local available = {}
    for _, key in ipairs(M.VOUCHER_KEYS) do
        if not ownedSet[key] then
            local v = M.get(key)
            if v then
                -- Check if requirements are met
                if not v.requires or ownedSet[v.requires] then
                    table.insert(available, v)
                end
            end
        end
    end
    return available
end

function M.count()
    return #M.VOUCHER_KEYS
end

M.VOUCHERS = setmetatable({}, {
    __index = function(t, key) return M.get(key) end,
    __pairs = function(t) return pairs(M.getAll()) end
})

return M

