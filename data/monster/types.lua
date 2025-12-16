-- Type Data (Auto-generated)
local types = {}

types.all = {"Normal", "Fire", "Water", "Electric", "Grass", "Ice", "Fighting", "Poison", "Ground", "Flying", "Psychic", "Bug", "Rock", "Ghost", "Dragon", "Dark", "Steel", "Fairy"}

-- Type colors for UI
types.colors = {
    Normal = {0.66, 0.66, 0.47}, Fire = {0.93, 0.51, 0.19}, Water = {0.39, 0.56, 0.94},
    Electric = {0.97, 0.82, 0.17}, Grass = {0.47, 0.78, 0.30}, Ice = {0.59, 0.85, 0.84},
    Fighting = {0.76, 0.18, 0.16}, Poison = {0.64, 0.24, 0.63}, Ground = {0.89, 0.75, 0.40},
    Flying = {0.66, 0.56, 0.95}, Psychic = {0.98, 0.33, 0.53}, Bug = {0.65, 0.73, 0.10},
    Rock = {0.71, 0.63, 0.21}, Ghost = {0.45, 0.34, 0.59}, Dragon = {0.44, 0.21, 0.99},
    Dark = {0.44, 0.34, 0.27}, Steel = {0.72, 0.72, 0.81}, Fairy = {0.84, 0.52, 0.68}
}

-- Damage taken chart: defender -> attacker -> multiplier code
-- 0=1x, 1=2x (super effective), 2=0.5x (resist), 3=0x (immune)
types.chart = {
    ["bug"] = {["Normal"] = 0, ["Fire"] = 1, ["Water"] = 0, ["Electric"] = 0, ["Grass"] = 2, ["Ice"] = 0, ["Fighting"] = 2, ["Poison"] = 0, ["Ground"] = 2, ["Flying"] = 1, ["Psychic"] = 0, ["Bug"] = 0, ["Rock"] = 1, ["Ghost"] = 0, ["Dragon"] = 0, ["Dark"] = 0, ["Steel"] = 0, ["Fairy"] = 0},
    ["dark"] = {["Normal"] = 0, ["Fire"] = 0, ["Water"] = 0, ["Electric"] = 0, ["Grass"] = 0, ["Ice"] = 0, ["Fighting"] = 1, ["Poison"] = 0, ["Ground"] = 0, ["Flying"] = 0, ["Psychic"] = 3, ["Bug"] = 1, ["Rock"] = 0, ["Ghost"] = 2, ["Dragon"] = 0, ["Dark"] = 2, ["Steel"] = 0, ["Fairy"] = 1},
    ["dragon"] = {["Normal"] = 0, ["Fire"] = 2, ["Water"] = 2, ["Electric"] = 2, ["Grass"] = 2, ["Ice"] = 1, ["Fighting"] = 0, ["Poison"] = 0, ["Ground"] = 0, ["Flying"] = 0, ["Psychic"] = 0, ["Bug"] = 0, ["Rock"] = 0, ["Ghost"] = 0, ["Dragon"] = 1, ["Dark"] = 0, ["Steel"] = 0, ["Fairy"] = 1},
    ["electric"] = {["Normal"] = 0, ["Fire"] = 0, ["Water"] = 0, ["Electric"] = 2, ["Grass"] = 0, ["Ice"] = 0, ["Fighting"] = 0, ["Poison"] = 0, ["Ground"] = 1, ["Flying"] = 2, ["Psychic"] = 0, ["Bug"] = 0, ["Rock"] = 0, ["Ghost"] = 0, ["Dragon"] = 0, ["Dark"] = 0, ["Steel"] = 2, ["Fairy"] = 0},
    ["fairy"] = {["Normal"] = 0, ["Fire"] = 0, ["Water"] = 0, ["Electric"] = 0, ["Grass"] = 0, ["Ice"] = 0, ["Fighting"] = 2, ["Poison"] = 1, ["Ground"] = 0, ["Flying"] = 0, ["Psychic"] = 0, ["Bug"] = 2, ["Rock"] = 0, ["Ghost"] = 0, ["Dragon"] = 3, ["Dark"] = 2, ["Steel"] = 1, ["Fairy"] = 0},
    ["fighting"] = {["Normal"] = 0, ["Fire"] = 0, ["Water"] = 0, ["Electric"] = 0, ["Grass"] = 0, ["Ice"] = 0, ["Fighting"] = 0, ["Poison"] = 0, ["Ground"] = 0, ["Flying"] = 1, ["Psychic"] = 1, ["Bug"] = 2, ["Rock"] = 2, ["Ghost"] = 0, ["Dragon"] = 0, ["Dark"] = 2, ["Steel"] = 0, ["Fairy"] = 1},
    ["fire"] = {["Normal"] = 0, ["Fire"] = 2, ["Water"] = 1, ["Electric"] = 0, ["Grass"] = 2, ["Ice"] = 2, ["Fighting"] = 0, ["Poison"] = 0, ["Ground"] = 1, ["Flying"] = 0, ["Psychic"] = 0, ["Bug"] = 2, ["Rock"] = 1, ["Ghost"] = 0, ["Dragon"] = 0, ["Dark"] = 0, ["Steel"] = 2, ["Fairy"] = 2},
    ["flying"] = {["Normal"] = 0, ["Fire"] = 0, ["Water"] = 0, ["Electric"] = 1, ["Grass"] = 2, ["Ice"] = 1, ["Fighting"] = 2, ["Poison"] = 0, ["Ground"] = 3, ["Flying"] = 0, ["Psychic"] = 0, ["Bug"] = 2, ["Rock"] = 1, ["Ghost"] = 0, ["Dragon"] = 0, ["Dark"] = 0, ["Steel"] = 0, ["Fairy"] = 0},
    ["ghost"] = {["Normal"] = 3, ["Fire"] = 0, ["Water"] = 0, ["Electric"] = 0, ["Grass"] = 0, ["Ice"] = 0, ["Fighting"] = 3, ["Poison"] = 2, ["Ground"] = 0, ["Flying"] = 0, ["Psychic"] = 0, ["Bug"] = 2, ["Rock"] = 0, ["Ghost"] = 1, ["Dragon"] = 0, ["Dark"] = 1, ["Steel"] = 0, ["Fairy"] = 0},
    ["grass"] = {["Normal"] = 0, ["Fire"] = 1, ["Water"] = 2, ["Electric"] = 2, ["Grass"] = 2, ["Ice"] = 1, ["Fighting"] = 0, ["Poison"] = 1, ["Ground"] = 2, ["Flying"] = 1, ["Psychic"] = 0, ["Bug"] = 1, ["Rock"] = 0, ["Ghost"] = 0, ["Dragon"] = 0, ["Dark"] = 0, ["Steel"] = 0, ["Fairy"] = 0},
    ["ground"] = {["Normal"] = 0, ["Fire"] = 0, ["Water"] = 1, ["Electric"] = 3, ["Grass"] = 1, ["Ice"] = 1, ["Fighting"] = 0, ["Poison"] = 2, ["Ground"] = 0, ["Flying"] = 0, ["Psychic"] = 0, ["Bug"] = 0, ["Rock"] = 2, ["Ghost"] = 0, ["Dragon"] = 0, ["Dark"] = 0, ["Steel"] = 0, ["Fairy"] = 0},
    ["ice"] = {["Normal"] = 0, ["Fire"] = 1, ["Water"] = 0, ["Electric"] = 0, ["Grass"] = 0, ["Ice"] = 2, ["Fighting"] = 1, ["Poison"] = 0, ["Ground"] = 0, ["Flying"] = 0, ["Psychic"] = 0, ["Bug"] = 0, ["Rock"] = 1, ["Ghost"] = 0, ["Dragon"] = 0, ["Dark"] = 0, ["Steel"] = 1, ["Fairy"] = 0},
    ["normal"] = {["Normal"] = 0, ["Fire"] = 0, ["Water"] = 0, ["Electric"] = 0, ["Grass"] = 0, ["Ice"] = 0, ["Fighting"] = 1, ["Poison"] = 0, ["Ground"] = 0, ["Flying"] = 0, ["Psychic"] = 0, ["Bug"] = 0, ["Rock"] = 0, ["Ghost"] = 3, ["Dragon"] = 0, ["Dark"] = 0, ["Steel"] = 0, ["Fairy"] = 0},
    ["poison"] = {["Normal"] = 0, ["Fire"] = 0, ["Water"] = 0, ["Electric"] = 0, ["Grass"] = 2, ["Ice"] = 0, ["Fighting"] = 2, ["Poison"] = 2, ["Ground"] = 1, ["Flying"] = 0, ["Psychic"] = 1, ["Bug"] = 2, ["Rock"] = 0, ["Ghost"] = 0, ["Dragon"] = 0, ["Dark"] = 0, ["Steel"] = 0, ["Fairy"] = 2},
    ["psychic"] = {["Normal"] = 0, ["Fire"] = 0, ["Water"] = 0, ["Electric"] = 0, ["Grass"] = 0, ["Ice"] = 0, ["Fighting"] = 2, ["Poison"] = 0, ["Ground"] = 0, ["Flying"] = 0, ["Psychic"] = 2, ["Bug"] = 1, ["Rock"] = 0, ["Ghost"] = 1, ["Dragon"] = 0, ["Dark"] = 1, ["Steel"] = 0, ["Fairy"] = 0},
    ["rock"] = {["Normal"] = 2, ["Fire"] = 2, ["Water"] = 1, ["Electric"] = 0, ["Grass"] = 1, ["Ice"] = 0, ["Fighting"] = 1, ["Poison"] = 2, ["Ground"] = 1, ["Flying"] = 2, ["Psychic"] = 0, ["Bug"] = 0, ["Rock"] = 0, ["Ghost"] = 0, ["Dragon"] = 0, ["Dark"] = 0, ["Steel"] = 1, ["Fairy"] = 0},
    ["steel"] = {["Normal"] = 2, ["Fire"] = 1, ["Water"] = 0, ["Electric"] = 0, ["Grass"] = 2, ["Ice"] = 2, ["Fighting"] = 1, ["Poison"] = 3, ["Ground"] = 1, ["Flying"] = 2, ["Psychic"] = 2, ["Bug"] = 2, ["Rock"] = 2, ["Ghost"] = 0, ["Dragon"] = 2, ["Dark"] = 0, ["Steel"] = 2, ["Fairy"] = 2},
    ["stellar"] = {["Normal"] = 0, ["Fire"] = 0, ["Water"] = 0, ["Electric"] = 0, ["Grass"] = 0, ["Ice"] = 0, ["Fighting"] = 0, ["Poison"] = 0, ["Ground"] = 0, ["Flying"] = 0, ["Psychic"] = 0, ["Bug"] = 0, ["Rock"] = 0, ["Ghost"] = 0, ["Dragon"] = 0, ["Dark"] = 0, ["Steel"] = 0, ["Fairy"] = 0},
    ["water"] = {["Normal"] = 0, ["Fire"] = 2, ["Water"] = 2, ["Electric"] = 1, ["Grass"] = 1, ["Ice"] = 2, ["Fighting"] = 0, ["Poison"] = 0, ["Ground"] = 0, ["Flying"] = 0, ["Psychic"] = 0, ["Bug"] = 0, ["Rock"] = 0, ["Ghost"] = 0, ["Dragon"] = 0, ["Dark"] = 0, ["Steel"] = 2, ["Fairy"] = 0},
}

-- Get effectiveness multiplier
function types.getEffectiveness(atkType, defType)
    local chart = types.chart[string.lower(defType)]
    if not chart then return 1 end
    local val = chart[atkType]
    if val == 1 then return 2 end      -- Super effective
    if val == 2 then return 0.5 end    -- Not very effective
    if val == 3 then return 0 end      -- Immune
    return 1                            -- Normal
end

-- Get effectiveness against dual type
function types.getDualEffectiveness(atkType, defTypes)
    local mult = 1
    for _, defType in ipairs(defTypes) do
        mult = mult * types.getEffectiveness(atkType, defType)
    end
    return mult
end

return types
