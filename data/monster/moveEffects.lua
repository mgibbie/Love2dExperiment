-- Move Effects
-- Defines secondary effects for moves (stat changes, healing, status, etc.)

local effects = {}

-- Effect types:
-- boost: Change stats { target = "self"|"enemy", stats = {stat = stages} }
-- heal: Restore HP { target = "self", percent = 0.5 }
-- drain: Damage + heal { percent = 0.5 }
-- status: Apply status condition { status = "paralysis"|"burn"|"poison"|"sleep"|"freeze" }
-- recoil: Take recoil damage { percent = 0.25|0.33|0.5 }

effects.data = {
    -- ==================
    -- STAT BOOSTING MOVES (self)
    -- ==================
    ["swordsdance"] = { type = "boost", target = "self", stats = {atk = 2} },
    ["dragondance"] = { type = "boost", target = "self", stats = {atk = 1, spe = 1} },
    ["calmmind"] = { type = "boost", target = "self", stats = {spa = 1, spd = 1} },
    ["nastyplot"] = { type = "boost", target = "self", stats = {spa = 2} },
    ["agility"] = { type = "boost", target = "self", stats = {spe = 2} },
    ["rockpolish"] = { type = "boost", target = "self", stats = {spe = 2} },
    ["autotomize"] = { type = "boost", target = "self", stats = {spe = 2} },
    ["quiverdance"] = { type = "boost", target = "self", stats = {spa = 1, spd = 1, spe = 1} },
    ["shellsmash"] = { type = "boost", target = "self", stats = {atk = 2, spa = 2, spe = 2, def = -1, spd = -1} },
    ["bulkup"] = { type = "boost", target = "self", stats = {atk = 1, def = 1} },
    ["workup"] = { type = "boost", target = "self", stats = {atk = 1, spa = 1} },
    ["howl"] = { type = "boost", target = "self", stats = {atk = 1} },
    ["sharpen"] = { type = "boost", target = "self", stats = {atk = 1} },
    ["meditate"] = { type = "boost", target = "self", stats = {atk = 1} },
    ["growth"] = { type = "boost", target = "self", stats = {atk = 1, spa = 1} },
    ["curse"] = { type = "boost", target = "self", stats = {atk = 1, def = 1, spe = -1} },  -- Non-ghost version
    ["irondefense"] = { type = "boost", target = "self", stats = {def = 2} },
    ["acidarmor"] = { type = "boost", target = "self", stats = {def = 2} },
    ["barrier"] = { type = "boost", target = "self", stats = {def = 2} },
    ["harden"] = { type = "boost", target = "self", stats = {def = 1} },
    ["withdraw"] = { type = "boost", target = "self", stats = {def = 1} },
    ["defensecurl"] = { type = "boost", target = "self", stats = {def = 1} },
    ["amnesia"] = { type = "boost", target = "self", stats = {spd = 2} },
    ["cosmicpower"] = { type = "boost", target = "self", stats = {def = 1, spd = 1} },
    ["coil"] = { type = "boost", target = "self", stats = {atk = 1, def = 1, accuracy = 1} },
    ["honeclaws"] = { type = "boost", target = "self", stats = {atk = 1, accuracy = 1} },
    ["minimize"] = { type = "boost", target = "self", stats = {evasion = 2} },
    ["doubleteam"] = { type = "boost", target = "self", stats = {evasion = 1} },
    ["tailglow"] = { type = "boost", target = "self", stats = {spa = 3} },
    ["cottonguard"] = { type = "boost", target = "self", stats = {def = 3} },
    ["bellydrum"] = { type = "boost", target = "self", stats = {atk = 6}, hpCost = 0.5 },
    ["shiftgear"] = { type = "boost", target = "self", stats = {atk = 1, spe = 2} },
    ["geomancy"] = { type = "boost", target = "self", stats = {spa = 2, spd = 2, spe = 2} },
    
    -- ==================
    -- STAT LOWERING MOVES (enemy)
    -- ==================
    ["growl"] = { type = "boost", target = "enemy", stats = {atk = -1} },
    ["leer"] = { type = "boost", target = "enemy", stats = {def = -1} },
    ["tailwhip"] = { type = "boost", target = "enemy", stats = {def = -1} },
    ["stringshot"] = { type = "boost", target = "enemy", stats = {spe = -2} },
    ["scaryface"] = { type = "boost", target = "enemy", stats = {spe = -2} },
    ["cottonspore"] = { type = "boost", target = "enemy", stats = {spe = -2} },
    ["screech"] = { type = "boost", target = "enemy", stats = {def = -2} },
    ["metalsound"] = { type = "boost", target = "enemy", stats = {spd = -2} },
    ["faketears"] = { type = "boost", target = "enemy", stats = {spd = -2} },
    ["charm"] = { type = "boost", target = "enemy", stats = {atk = -2} },
    ["featherdance"] = { type = "boost", target = "enemy", stats = {atk = -2} },
    ["sweetscent"] = { type = "boost", target = "enemy", stats = {evasion = -2} },
    ["sandattack"] = { type = "boost", target = "enemy", stats = {accuracy = -1} },
    ["smokescreen"] = { type = "boost", target = "enemy", stats = {accuracy = -1} },
    ["flash"] = { type = "boost", target = "enemy", stats = {accuracy = -1} },
    ["kinesis"] = { type = "boost", target = "enemy", stats = {accuracy = -1} },
    ["captivate"] = { type = "boost", target = "enemy", stats = {spa = -2} },
    ["memento"] = { type = "boost", target = "enemy", stats = {atk = -2, spa = -2}, selfFaint = true },
    ["partingshot"] = { type = "boost", target = "enemy", stats = {atk = -1, spa = -1}, switchOut = true },
    ["nobleroar"] = { type = "boost", target = "enemy", stats = {atk = -1, spa = -1} },
    ["tearfullook"] = { type = "boost", target = "enemy", stats = {atk = -1, spa = -1} },
    ["babydolleyes"] = { type = "boost", target = "enemy", stats = {atk = -1} },
    ["playnice"] = { type = "boost", target = "enemy", stats = {atk = -1} },
    
    -- ==================
    -- HEALING MOVES
    -- ==================
    ["recover"] = { type = "heal", target = "self", percent = 0.5 },
    ["softboiled"] = { type = "heal", target = "self", percent = 0.5 },
    ["milkdrink"] = { type = "heal", target = "self", percent = 0.5 },
    ["slackoff"] = { type = "heal", target = "self", percent = 0.5 },
    ["roost"] = { type = "heal", target = "self", percent = 0.5 },
    ["moonlight"] = { type = "heal", target = "self", percent = 0.5 },
    ["morningsun"] = { type = "heal", target = "self", percent = 0.5 },
    ["synthesis"] = { type = "heal", target = "self", percent = 0.5 },
    ["rest"] = { type = "heal", target = "self", percent = 1.0, applySleep = true },
    ["wish"] = { type = "heal", target = "self", percent = 0.5, delayed = true },
    ["healorder"] = { type = "heal", target = "self", percent = 0.5 },
    ["shoreup"] = { type = "heal", target = "self", percent = 0.5 },
    
    -- ==================
    -- DRAINING MOVES (damage + heal)
    -- ==================
    ["absorb"] = { type = "drain", percent = 0.5 },
    ["megadrain"] = { type = "drain", percent = 0.5 },
    ["gigadrain"] = { type = "drain", percent = 0.5 },
    ["drainpunch"] = { type = "drain", percent = 0.5 },
    ["hornleech"] = { type = "drain", percent = 0.5 },
    ["leechlife"] = { type = "drain", percent = 0.5 },
    ["drainingkiss"] = { type = "drain", percent = 0.75 },
    ["oblivionwing"] = { type = "drain", percent = 0.75 },
    ["paraboliccharge"] = { type = "drain", percent = 0.5 },
    ["strengthsap"] = { type = "drain", percent = 1.0, drainStat = "atk" },  -- Special case
    
    -- ==================
    -- STATUS MOVES
    -- ==================
    ["thunderwave"] = { type = "status", status = "paralysis" },
    ["stunspore"] = { type = "status", status = "paralysis" },
    ["glare"] = { type = "status", status = "paralysis" },
    ["nuzzle"] = { type = "status", status = "paralysis" },  -- Also does damage
    ["willowisp"] = { type = "status", status = "burn" },
    ["poisonpowder"] = { type = "status", status = "poison" },
    ["poisongas"] = { type = "status", status = "poison" },
    ["toxic"] = { type = "status", status = "badpoison" },
    ["sleeppowder"] = { type = "status", status = "sleep" },
    ["hypnosis"] = { type = "status", status = "sleep" },
    ["sing"] = { type = "status", status = "sleep" },
    ["grasswhistle"] = { type = "status", status = "sleep" },
    ["lovelykiss"] = { type = "status", status = "sleep" },
    ["darkvoid"] = { type = "status", status = "sleep" },
    ["spore"] = { type = "status", status = "sleep" },
    ["yawn"] = { type = "status", status = "drowsy" },  -- Sleep next turn
    
    -- ==================
    -- DAMAGING MOVES WITH SECONDARY EFFECTS
    -- ==================
    -- Paralysis chance
    ["thunderbolt"] = { type = "chance_status", status = "paralysis", chance = 10 },
    ["thunder"] = { type = "chance_status", status = "paralysis", chance = 30 },
    ["discharge"] = { type = "chance_status", status = "paralysis", chance = 30 },
    ["spark"] = { type = "chance_status", status = "paralysis", chance = 30 },
    ["thundershock"] = { type = "chance_status", status = "paralysis", chance = 10 },
    ["thunderfang"] = { type = "chance_status", status = "paralysis", chance = 10 },
    ["zapcannon"] = { type = "chance_status", status = "paralysis", chance = 100 },
    ["bodyslam"] = { type = "chance_status", status = "paralysis", chance = 30 },
    ["bounce"] = { type = "chance_status", status = "paralysis", chance = 30 },
    ["forcepalm"] = { type = "chance_status", status = "paralysis", chance = 30 },
    ["lick"] = { type = "chance_status", status = "paralysis", chance = 30 },
    
    -- Burn chance
    ["flamethrower"] = { type = "chance_status", status = "burn", chance = 10 },
    ["fireblast"] = { type = "chance_status", status = "burn", chance = 10 },
    ["flamewheel"] = { type = "chance_status", status = "burn", chance = 10 },
    ["heatwave"] = { type = "chance_status", status = "burn", chance = 10 },
    ["lavaplume"] = { type = "chance_status", status = "burn", chance = 30 },
    ["scald"] = { type = "chance_status", status = "burn", chance = 30 },
    ["firefang"] = { type = "chance_status", status = "burn", chance = 10 },
    ["sacredfire"] = { type = "chance_status", status = "burn", chance = 50 },
    ["inferno"] = { type = "chance_status", status = "burn", chance = 100 },
    ["ember"] = { type = "chance_status", status = "burn", chance = 10 },
    ["flareblitz"] = { type = "chance_status", status = "burn", chance = 10, recoil = 0.33 },
    
    -- Poison chance
    ["sludge"] = { type = "chance_status", status = "poison", chance = 30 },
    ["sludgebomb"] = { type = "chance_status", status = "poison", chance = 30 },
    ["sludgewave"] = { type = "chance_status", status = "poison", chance = 10 },
    ["gunkshot"] = { type = "chance_status", status = "poison", chance = 30 },
    ["poisonjab"] = { type = "chance_status", status = "poison", chance = 30 },
    ["crosspoison"] = { type = "chance_status", status = "poison", chance = 10 },
    ["poisonfang"] = { type = "chance_status", status = "badpoison", chance = 50 },
    ["poisonsting"] = { type = "chance_status", status = "poison", chance = 30 },
    ["smog"] = { type = "chance_status", status = "poison", chance = 40 },
    ["poisontail"] = { type = "chance_status", status = "poison", chance = 10 },
    
    -- Freeze chance
    ["icebeam"] = { type = "chance_status", status = "freeze", chance = 10 },
    ["blizzard"] = { type = "chance_status", status = "freeze", chance = 10 },
    ["icepunch"] = { type = "chance_status", status = "freeze", chance = 10 },
    ["icefang"] = { type = "chance_status", status = "freeze", chance = 10 },
    ["powdersnow"] = { type = "chance_status", status = "freeze", chance = 10 },
    ["freezedry"] = { type = "chance_status", status = "freeze", chance = 10 },
    
    -- Stat lowering on hit
    ["psychic"] = { type = "chance_boost", target = "enemy", stats = {spd = -1}, chance = 10 },
    ["shadowball"] = { type = "chance_boost", target = "enemy", stats = {spd = -1}, chance = 20 },
    ["energyball"] = { type = "chance_boost", target = "enemy", stats = {spd = -1}, chance = 10 },
    ["earthpower"] = { type = "chance_boost", target = "enemy", stats = {spd = -1}, chance = 10 },
    ["flashcannon"] = { type = "chance_boost", target = "enemy", stats = {spd = -1}, chance = 10 },
    ["focusblast"] = { type = "chance_boost", target = "enemy", stats = {spd = -1}, chance = 10 },
    ["acid"] = { type = "chance_boost", target = "enemy", stats = {spd = -1}, chance = 10 },
    ["acidspray"] = { type = "chance_boost", target = "enemy", stats = {spd = -2}, chance = 100 },
    ["crunch"] = { type = "chance_boost", target = "enemy", stats = {def = -1}, chance = 20 },
    ["rocksmash"] = { type = "chance_boost", target = "enemy", stats = {def = -1}, chance = 50 },
    ["crushclaw"] = { type = "chance_boost", target = "enemy", stats = {def = -1}, chance = 50 },
    ["ironhead"] = { type = "chance_flinch", chance = 30 },
    ["airslash"] = { type = "chance_flinch", chance = 30 },
    ["bite"] = { type = "chance_flinch", chance = 30 },
    ["darkpulse"] = { type = "chance_flinch", chance = 20 },
    ["zenheadbutt"] = { type = "chance_flinch", chance = 20 },
    ["headbutt"] = { type = "chance_flinch", chance = 30 },
    ["rockslide"] = { type = "chance_flinch", chance = 30 },
    ["waterfall"] = { type = "chance_flinch", chance = 20 },
    
    -- Self stat boost on hit
    ["flamecharge"] = { type = "boost_on_hit", target = "self", stats = {spe = 1} },
    ["poweruppunch"] = { type = "boost_on_hit", target = "self", stats = {atk = 1} },
    ["fierydance"] = { type = "chance_boost", target = "self", stats = {spa = 1}, chance = 50 },
    ["chargebeam"] = { type = "chance_boost", target = "self", stats = {spa = 1}, chance = 70 },
    ["metalclaw"] = { type = "chance_boost", target = "self", stats = {atk = 1}, chance = 10 },
    ["meteormash"] = { type = "chance_boost", target = "self", stats = {atk = 1}, chance = 20 },
    ["ancientpower"] = { type = "chance_boost", target = "self", stats = {atk = 1, def = 1, spa = 1, spd = 1, spe = 1}, chance = 10 },
    ["ominouswind"] = { type = "chance_boost", target = "self", stats = {atk = 1, def = 1, spa = 1, spd = 1, spe = 1}, chance = 10 },
    ["silverwind"] = { type = "chance_boost", target = "self", stats = {atk = 1, def = 1, spa = 1, spd = 1, spe = 1}, chance = 10 },
    
    -- ==================
    -- RECOIL MOVES
    -- ==================
    ["doubleedge"] = { type = "recoil", percent = 0.33 },
    ["takedown"] = { type = "recoil", percent = 0.25 },
    ["submission"] = { type = "recoil", percent = 0.25 },
    ["wildcharge"] = { type = "recoil", percent = 0.25 },
    ["volttackle"] = { type = "recoil", percent = 0.33, chanceStatus = "paralysis", chance = 10 },
    ["bravebird"] = { type = "recoil", percent = 0.33 },
    ["woodhammer"] = { type = "recoil", percent = 0.33 },
    ["headsmash"] = { type = "recoil", percent = 0.5 },
    ["headcharge"] = { type = "recoil", percent = 0.25 },
    
    -- ==================
    -- SPECIAL EFFECT MOVES
    -- ==================
    ["rapidspin"] = { type = "boost_on_hit", target = "self", stats = {spe = 1} },
    ["closecombat"] = { type = "boost_on_hit", target = "self", stats = {def = -1, spd = -1} },
    ["superpower"] = { type = "boost_on_hit", target = "self", stats = {atk = -1, def = -1} },
    ["overheat"] = { type = "boost_on_hit", target = "self", stats = {spa = -2} },
    ["dracometeor"] = { type = "boost_on_hit", target = "self", stats = {spa = -2} },
    ["leafstorm"] = { type = "boost_on_hit", target = "self", stats = {spa = -2} },
    ["psychoboost"] = { type = "boost_on_hit", target = "self", stats = {spa = -2} },
    ["hammerarm"] = { type = "boost_on_hit", target = "self", stats = {spe = -1} },
    ["vcreate"] = { type = "boost_on_hit", target = "self", stats = {def = -1, spd = -1, spe = -1} },
}

-- Get effect for a move
function effects.get(moveId)
    return effects.data[moveId]
end

-- Check if a move has any effect
function effects.hasEffect(moveId)
    return effects.data[moveId] ~= nil
end

return effects

