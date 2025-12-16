# Pokemon Moves Verification Checklist

This checklist verifies all 843 moves in the Pokemon battle system.

## Status Legend
- ✅ Working - Fully implemented and tested
- ⚠️ Partial - Partially implemented or needs testing
- ❌ Missing - Not implemented or broken

## Move Categories

### 1. Basic Damage Moves (No Effects)
These moves should have:
- Damage calculation working
- Accuracy checks working
- PP system working
- Type effectiveness working

**Sample moves to test** (representative of each type):
- [ ] **Pound** (Normal, 40 BP, 100% acc)
- [ ] **Scratch** (Normal, 40 BP, 100% acc)
- [ ] **Tackle** (Normal, 40 BP, 100% acc)
- [ ] **Ember** (Fire, 40 BP, 100% acc) - Has 10% burn chance
- [ ] **Water Gun** (Water, 40 BP, 100% acc)
- [ ] **Thunder Shock** (Electric, 40 BP, 100% acc) - Has 10% paralysis chance
- [ ] **Vine Whip** (Grass, 45 BP, 100% acc)
- [ ] **Peck** (Flying, 35 BP, 100% acc)
- [ ] **Bite** (Dark, 60 BP, 100% acc) - Has 30% flinch chance

**Total basic moves**: ~400+ moves
**Status**: ⚠️ Partial - Need to verify damage calculation and accuracy

---

### 2. Status Moves (Pure Status, No Damage)
Implementation: `moveEffects.lua` lines 111-126

- [ ] **Thunder Wave** (Paralysis)
  - Status: ⚠️ Partial
  - Implementation: Line 111
  - Notes: Verify paralysis applies correctly

- [ ] **Stun Spore** (Paralysis)
  - Status: ⚠️ Partial
  - Implementation: Line 112
  - Notes: Verify paralysis applies correctly

- [ ] **Glare** (Paralysis)
  - Status: ⚠️ Partial
  - Implementation: Line 113
  - Notes: Verify paralysis applies correctly

- [ ] **Will-O-Wisp** (Burn)
  - Status: ⚠️ Partial
  - Implementation: Line 115
  - Notes: Verify burn applies correctly

- [ ] **Poison Powder** (Poison)
  - Status: ⚠️ Partial
  - Implementation: Line 116
  - Notes: Verify poison applies correctly

- [ ] **Poison Gas** (Poison)
  - Status: ⚠️ Partial
  - Implementation: Line 117
  - Notes: Verify poison applies correctly

- [ ] **Toxic** (Bad Poison)
  - Status: ⚠️ Partial
  - Implementation: Line 118
  - Notes: Verify toxic counter increments

- [ ] **Sleep Powder** (Sleep)
  - Status: ⚠️ Partial
  - Implementation: Line 119
  - Notes: Verify sleep applies correctly

- [ ] **Hypnosis** (Sleep)
  - Status: ⚠️ Partial
  - Implementation: Line 120
  - Notes: Verify sleep applies correctly

- [ ] **Sing** (Sleep)
  - Status: ⚠️ Partial
  - Implementation: Line 121
  - Notes: Verify sleep applies correctly

- [ ] **Grass Whistle** (Sleep)
  - Status: ⚠️ Partial
  - Implementation: Line 122
  - Notes: Verify sleep applies correctly

- [ ] **Lovely Kiss** (Sleep)
  - Status: ⚠️ Partial
  - Implementation: Line 123
  - Notes: Verify sleep applies correctly

- [ ] **Dark Void** (Sleep)
  - Status: ⚠️ Partial
  - Implementation: Line 124
  - Notes: Verify sleep applies correctly

- [ ] **Spore** (Sleep)
  - Status: ⚠️ Partial
  - Implementation: Line 125
  - Notes: Verify sleep applies correctly

- [ ] **Yawn** (Drowsy - Sleep next turn)
  - Status: ❌ Missing
  - Implementation: Line 126 (marked as drowsy, needs special handling)
  - Notes: Requires delayed status application

---

### 3. Stat Boosting Moves (Self)
Implementation: `moveEffects.lua` lines 17-49

**Major stat boosts**:
- [ ] **Swords Dance** (+2 Attack)
  - Status: ⚠️ Partial
  - Implementation: Line 17
  - Notes: Verify stat stages work correctly

- [ ] **Dragon Dance** (+1 Attack, +1 Speed)
  - Status: ⚠️ Partial
  - Implementation: Line 18
  - Notes: Verify multiple stat changes

- [ ] **Calm Mind** (+1 Sp. Atk, +1 Sp. Def)
  - Status: ⚠️ Partial
  - Implementation: Line 19
  - Notes: Verify multiple stat changes

- [ ] **Nasty Plot** (+2 Sp. Atk)
  - Status: ⚠️ Partial
  - Implementation: Line 20
  - Notes: Verify stat stages work correctly

- [ ] **Agility** (+2 Speed)
  - Status: ⚠️ Partial
  - Implementation: Line 21
  - Notes: Verify speed boost affects turn order

- [ ] **Quiver Dance** (+1 Sp. Atk, +1 Sp. Def, +1 Speed)
  - Status: ⚠️ Partial
  - Implementation: Line 24
  - Notes: Verify triple stat boost

- [ ] **Shell Smash** (+2 Atk/SpA/Spe, -1 Def/SpD)
  - Status: ⚠️ Partial
  - Implementation: Line 25
  - Notes: Verify mixed boost/lower

- [ ] **Belly Drum** (+6 Attack, costs 50% HP)
  - Status: ⚠️ Partial
  - Implementation: Line 47
  - Notes: Verify HP cost works

**Total stat boosting moves**: ~30 moves
**Status**: ⚠️ Partial - Need to verify stat stage system

---

### 4. Stat Lowering Moves (Enemy)
Implementation: `moveEffects.lua` lines 54-76

- [ ] **Growl** (-1 Attack)
  - Status: ⚠️ Partial
  - Implementation: Line 54
  - Notes: Verify stat lowering works

- [ ] **Leer** (-1 Defense)
  - Status: ⚠️ Partial
  - Implementation: Line 55
  - Notes: Verify stat lowering works

- [ ] **String Shot** (-2 Speed)
  - Status: ⚠️ Partial
  - Implementation: Line 57
  - Notes: Verify speed reduction affects turn order

- [ ] **Scary Face** (-2 Speed)
  - Status: ⚠️ Partial
  - Implementation: Line 58
  - Notes: Verify speed reduction

- [ ] **Screech** (-2 Defense)
  - Status: ⚠️ Partial
  - Implementation: Line 60
  - Notes: Verify defense lowering

- [ ] **Memento** (-2 Attack, -2 Sp. Atk, user faints)
  - Status: ⚠️ Partial
  - Implementation: Line 71
  - Notes: Verify self-faint works

**Total stat lowering moves**: ~20 moves
**Status**: ⚠️ Partial - Need to verify stat stage system

---

### 5. Healing Moves
Implementation: `moveEffects.lua` lines 81-92

- [ ] **Recover** (50% HP)
  - Status: ⚠️ Partial
  - Implementation: Line 81
  - Notes: Verify healing calculation

- [ ] **Soft-Boiled** (50% HP)
  - Status: ⚠️ Partial
  - Implementation: Line 82
  - Notes: Verify healing calculation

- [ ] **Milk Drink** (50% HP)
  - Status: ⚠️ Partial
  - Implementation: Line 83
  - Notes: Verify healing calculation

- [ ] **Rest** (100% HP, applies Sleep)
  - Status: ⚠️ Partial
  - Implementation: Line 89
  - Notes: Verify sleep application

- [ ] **Wish** (50% HP, delayed)
  - Status: ❌ Missing
  - Implementation: Line 90 (marked as delayed, needs special handling)
  - Notes: Requires delayed healing system

**Total healing moves**: ~12 moves
**Status**: ⚠️ Partial - Need to verify healing calculations

---

### 6. Draining Moves (Damage + Heal)
Implementation: `moveEffects.lua` lines 97-106

- [ ] **Absorb** (50% drain)
  - Status: ⚠️ Partial
  - Implementation: Line 97
  - Notes: Verify drain calculation

- [ ] **Mega Drain** (50% drain)
  - Status: ⚠️ Partial
  - Implementation: Line 98
  - Notes: Verify drain calculation

- [ ] **Giga Drain** (50% drain)
  - Status: ⚠️ Partial
  - Implementation: Line 99
  - Notes: Verify drain calculation

- [ ] **Drain Punch** (50% drain)
  - Status: ⚠️ Partial
  - Implementation: Line 100
  - Notes: Verify drain calculation

- [ ] **Draining Kiss** (75% drain)
  - Status: ⚠️ Partial
  - Implementation: Line 103
  - Notes: Verify higher drain percentage

- [ ] **Strength Sap** (100% drain, drains Attack stat)
  - Status: ❌ Missing
  - Implementation: Line 106 (special case with drainStat)
  - Notes: Requires stat draining system

**Total draining moves**: ~10 moves
**Status**: ⚠️ Partial - Need to verify drain calculations

---

### 7. Damaging Moves with Status Chance
Implementation: `moveEffects.lua` lines 132-196

**Paralysis chance**:
- [ ] **Thunderbolt** (10% paralysis)
  - Status: ⚠️ Partial
  - Implementation: Line 132
  - Notes: Verify chance calculation

- [ ] **Thunder** (30% paralysis)
  - Status: ⚠️ Partial
  - Implementation: Line 133
  - Notes: Verify chance calculation

- [ ] **Zap Cannon** (100% paralysis)
  - Status: ⚠️ Partial
  - Implementation: Line 138
  - Notes: Verify guaranteed status

**Burn chance**:
- [ ] **Flamethrower** (10% burn)
  - Status: ⚠️ Partial
  - Implementation: Line 145
  - Notes: Verify chance calculation

- [ ] **Fire Blast** (10% burn)
  - Status: ⚠️ Partial
  - Implementation: Line 146
  - Notes: Verify chance calculation

- [ ] **Scald** (30% burn)
  - Status: ⚠️ Partial
  - Implementation: Line 150
  - Notes: Verify chance calculation

- [ ] **Inferno** (100% burn)
  - Status: ⚠️ Partial
  - Implementation: Line 153
  - Notes: Verify guaranteed status

**Poison chance**:
- [ ] **Sludge Bomb** (30% poison)
  - Status: ⚠️ Partial
  - Implementation: Line 159
  - Notes: Verify chance calculation

- [ ] **Poison Fang** (50% bad poison)
  - Status: ⚠️ Partial
  - Implementation: Line 164
  - Notes: Verify bad poison application

**Freeze chance**:
- [ ] **Ice Beam** (10% freeze)
  - Status: ⚠️ Partial
  - Implementation: Line 170
  - Notes: Verify chance calculation

- [ ] **Blizzard** (10% freeze)
  - Status: ⚠️ Partial
  - Implementation: Line 171
  - Notes: Verify chance calculation

**Total status chance moves**: ~50 moves
**Status**: ⚠️ Partial - Need to verify chance calculations

---

### 8. Moves with Stat Changes on Hit
Implementation: `moveEffects.lua` lines 178-208

- [ ] **Psychic** (10% chance -1 Sp. Def)
  - Status: ⚠️ Partial
  - Implementation: Line 178
  - Notes: Verify chance stat lowering

- [ ] **Shadow Ball** (20% chance -1 Sp. Def)
  - Status: ⚠️ Partial
  - Implementation: Line 179
  - Notes: Verify chance stat lowering

- [ ] **Acid Spray** (100% chance -2 Sp. Def)
  - Status: ⚠️ Partial
  - Implementation: Line 185
  - Notes: Verify guaranteed stat lowering

- [ ] **Flame Charge** (Always +1 Speed)
  - Status: ⚠️ Partial
  - Implementation: Line 199
  - Notes: Verify guaranteed stat boost

- [ ] **Power-Up Punch** (Always +1 Attack)
  - Status: ⚠️ Partial
  - Implementation: Line 200
  - Notes: Verify guaranteed stat boost

- [ ] **Ancient Power** (10% chance all stats +1)
  - Status: ⚠️ Partial
  - Implementation: Line 205
  - Notes: Verify multi-stat boost chance

**Total stat change on hit moves**: ~20 moves
**Status**: ⚠️ Partial - Need to verify on-hit effects

---

### 9. Recoil Moves
Implementation: `moveEffects.lua` lines 212-220

- [ ] **Double-Edge** (33% recoil)
  - Status: ⚠️ Partial
  - Implementation: Line 212
  - Notes: Verify recoil calculation

- [ ] **Take Down** (25% recoil)
  - Status: ⚠️ Partial
  - Implementation: Line 213
  - Notes: Verify recoil calculation

- [ ] **Volt Tackle** (33% recoil, 10% paralysis)
  - Status: ⚠️ Partial
  - Implementation: Line 216
  - Notes: Verify recoil + status chance

- [ ] **Head Smash** (50% recoil)
  - Status: ⚠️ Partial
  - Implementation: Line 219
  - Notes: Verify high recoil

**Total recoil moves**: ~10 moves
**Status**: ⚠️ Partial - Need to verify recoil calculations

---

### 10. Self-Stat Lowering Moves (on hit)
Implementation: `moveEffects.lua` lines 226-233

- [ ] **Close Combat** (-1 Def, -1 Sp. Def)
  - Status: ⚠️ Partial
  - Implementation: Line 226
  - Notes: Verify self stat lowering

- [ ] **Superpower** (-1 Atk, -1 Def)
  - Status: ⚠️ Partial
  - Implementation: Line 227
  - Notes: Verify self stat lowering

- [ ] **Overheat** (-2 Sp. Atk)
  - Status: ⚠️ Partial
  - Implementation: Line 228
  - Notes: Verify self stat lowering

- [ ] **V-create** (-1 Def, -1 Sp. Def, -1 Speed)
  - Status: ⚠️ Partial
  - Implementation: Line 233
  - Notes: Verify triple self stat lowering

**Total self-lowering moves**: ~8 moves
**Status**: ⚠️ Partial - Need to verify self stat changes

---

### 11. Special Effect Moves
These moves have unique mechanics that may not be fully implemented:

- [ ] **Flinch moves** (Iron Head, Air Slash, etc.)
  - Status: ❌ Missing
  - Implementation: Line 189-196 (marked but not implemented)
  - Notes: Flinch prevents opponent from moving next turn

- [ ] **Multi-hit moves** (Double Slap, Fury Attack, etc.)
  - Status: ⚠️ Partial
  - Notes: Need to verify multiple hits work

- [ ] **Priority moves** (Quick Attack, Mach Punch, etc.)
  - Status: ⚠️ Partial
  - Notes: Need to verify priority affects turn order

- [ ] **OHKO moves** (Guillotine, Fissure, etc.)
  - Status: ⚠️ Partial
  - Notes: Need to verify accuracy calculation

- [ ] **Weather moves** (Rain Dance, Sunny Day, etc.)
  - Status: ❌ Missing
  - Notes: Weather system not implemented

- [ ] **Terrain moves** (Electric Terrain, etc.)
  - Status: ❌ Missing
  - Notes: Terrain system not implemented

- [ ] **Entry hazard moves** (Spikes, Stealth Rock, etc.)
  - Status: ❌ Missing
  - Notes: Entry hazard system not implemented

---

## Summary

**Total Moves**: 843
- Basic damage moves: ~400
- Status moves: ~15
- Stat boosting moves: ~30
- Stat lowering moves: ~20
- Healing moves: ~12
- Draining moves: ~10
- Status chance moves: ~50
- Stat change on hit: ~20
- Recoil moves: ~10
- Self-lowering moves: ~8
- Special effect moves: ~268 (many may be missing implementations)

**Critical Missing Systems**:
1. Flinch mechanic
2. Weather system
3. Terrain system
4. Entry hazards
5. Delayed effects (Wish, Yawn)
6. Stat draining (Strength Sap)
7. Multi-hit moves (need verification)
8. Priority system (need verification)
9. OHKO moves (need verification)

**Implementation Status**:
- ✅ Move data structure: Working
- ✅ Damage calculation: ⚠️ Partial (needs testing)
- ✅ Accuracy checks: ⚠️ Partial (needs testing)
- ✅ PP system: ⚠️ Partial (needs testing)
- ✅ Type effectiveness: ⚠️ Partial (needs testing)
- ✅ Status conditions: ⚠️ Partial (needs testing)
- ✅ Stat stages: ⚠️ Partial (needs testing)
- ✅ Move effects: ⚠️ Partial (~100 moves have effects defined)
- ❌ Flinch: Missing
- ❌ Weather: Missing
- ❌ Terrain: Missing
- ❌ Entry hazards: Missing

