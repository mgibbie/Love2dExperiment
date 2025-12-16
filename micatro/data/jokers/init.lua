-- Joker Registry with Lazy Loading
-- Jokers are loaded on demand from individual files

local M = {}

-- Rarity definitions
M.RARITY = {
    COMMON = 1,
    UNCOMMON = 2,
    RARE = 3,
    LEGENDARY = 4
}

M.RARITY_NAMES = {
    [1] = "Common",
    [2] = "Uncommon",
    [3] = "Rare",
    [4] = "Legendary"
}

-- Cache for loaded jokers
local cache = {}

-- List of all joker keys for iteration
M.JOKER_KEYS = {
    "j_joker", "j_greedy_joker", "j_lusty_joker", "j_wrathful_joker", "j_gluttenous_joker",
    "j_jolly", "j_zany", "j_mad", "j_crazy", "j_droll",
    "j_sly", "j_wily", "j_clever", "j_devious", "j_crafty",
    "j_half", "j_stencil", "j_four_fingers", "j_mime", "j_credit_card",
    "j_ceremonial", "j_banner", "j_mystic_summit", "j_marble", "j_loyalty_card",
    "j_8_ball", "j_misprint", "j_dusk", "j_raised_fist", "j_chaos",
    "j_fibonacci", "j_steel_joker", "j_scary_face", "j_abstract", "j_delayed_grat",
    "j_hack", "j_pareidolia", "j_gros_michel", "j_even_steven", "j_odd_todd",
    "j_scholar", "j_business", "j_supernova", "j_ride_the_bus", "j_space",
    "j_egg", "j_burglar", "j_blackboard", "j_runner", "j_ice_cream",
    "j_dna", "j_splash", "j_blue_joker", "j_sixth_sense", "j_constellation",
    "j_hiker", "j_faceless", "j_green_joker", "j_superposition", "j_todo_list",
    "j_cavendish", "j_card_sharp", "j_red_card", "j_madness", "j_square",
    "j_seance", "j_riff_raff", "j_vampire", "j_shortcut", "j_hologram",
    "j_vagabond", "j_baron", "j_cloud_9", "j_rocket", "j_obelisk",
    "j_midas_mask", "j_luchador", "j_photograph", "j_gift", "j_turtle_bean",
    "j_erosion", "j_reserved_parking", "j_mail", "j_to_the_moon", "j_hallucination",
    "j_fortune_teller", "j_juggler", "j_drunkard", "j_stone", "j_golden",
    "j_lucky_cat", "j_baseball", "j_bull", "j_diet_cola", "j_trading",
    "j_flash", "j_popcorn", "j_trousers", "j_ancient", "j_ramen",
    "j_walkie_talkie", "j_selzer", "j_castle", "j_smiley", "j_campfire",
    "j_ticket", "j_mr_bones", "j_acrobat", "j_sock_and_buskin", "j_swashbuckler",
    "j_troubadour", "j_certificate", "j_smeared", "j_throwback", "j_hanging_chad",
    "j_rough_gem", "j_bloodstone", "j_arrowhead", "j_onyx_agate", "j_glass",
    "j_ring_master", "j_flower_pot", "j_blueprint", "j_wee", "j_merry_andy",
    "j_oops", "j_idol", "j_seeing_double", "j_matador", "j_hit_the_road",
    "j_duo", "j_trio", "j_family", "j_order", "j_tribe",
    "j_stuntman", "j_invisible", "j_brainstorm", "j_satellite", "j_shoot_the_moon",
    "j_drivers_license", "j_cartomancer", "j_astronomer", "j_burnt", "j_bootstraps",
    "j_caino", "j_triboulet", "j_yorick", "j_chicot", "j_perkeo"
}

-- Get a joker by key (lazy load)
function M.get(key)
    if not key then return nil end
    
    -- Return from cache if already loaded
    if cache[key] then
        return cache[key]
    end
    
    -- Try to load the joker module
    local ok, jokerData = pcall(require, "micatro.data.jokers." .. key)
    if ok and jokerData then
        cache[key] = jokerData
        return jokerData
    end
    
    return nil
end

-- Get all jokers (loads all)
function M.getAll()
    local all = {}
    for _, key in ipairs(M.JOKER_KEYS) do
        local joker = M.get(key)
        if joker then
            all[key] = joker
        end
    end
    return all
end

-- Get random joker of specific rarity
function M.getRandomByRarity(rarity)
    local matching = {}
    for _, key in ipairs(M.JOKER_KEYS) do
        local joker = M.get(key)
        if joker and joker.rarity == rarity then
            table.insert(matching, joker)
        end
    end
    
    if #matching > 0 then
        return matching[math.random(#matching)]
    end
    return nil
end

-- Get random joker
function M.getRandom()
    local key = M.JOKER_KEYS[math.random(#M.JOKER_KEYS)]
    return M.get(key)
end

-- Get joker count
function M.count()
    return #M.JOKER_KEYS
end

-- Preload all jokers (optional, for faster access later)
function M.preloadAll()
    for _, key in ipairs(M.JOKER_KEYS) do
        M.get(key)
    end
end

-- Clear cache
function M.clearCache()
    cache = {}
end

-- For backwards compatibility, expose JOKERS table that lazy loads
M.JOKERS = setmetatable({}, {
    __index = function(t, key)
        return M.get(key)
    end,
    __pairs = function(t)
        local all = M.getAll()
        return pairs(all)
    end
})

return M

