# Pokemon Abilities Verification Checklist

This checklist verifies Pokemon abilities in the battle system. Abilities are stored in each Pokemon's data file under the `abilities` field.

## Status Legend
- ✅ Working - Fully implemented and tested
- ⚠️ Partial - Partially implemented or needs testing
- ❌ Missing - Not implemented or broken

## Note on Abilities

Abilities are stored in `data/monster/pokemon/*.lua` files in the `abilities` field (array of strings).
There are 1103 Pokemon files, each potentially having 1-3 abilities.

**Implementation Location**: Abilities should be checked/applied in:
- `data/monster/battleState.lua` - Battle state management
- `data/monster/monsterAI.lua` - AI decision making
- `data/monster/pokemonBuilder.lua` - Ability assignment (line 107-113)

**Current Status**: Abilities are assigned randomly but may not be implemented in battle logic.

---

## Common Abilities by Category

### 1. Weather Abilities
These abilities change or interact with weather:

- [ ] **Drought** (Sets sun on switch-in)
  - Status: ❌ Missing
  - Pokemon: Charizard, Torkoal, Groudon
  - Notes: Requires weather system

- [ ] **Drizzle** (Sets rain on switch-in)
  - Status: ❌ Missing
  - Pokemon: Politoed, Kyogre, Pelipper
  - Notes: Requires weather system

- [ ] **Sand Stream** (Sets sandstorm on switch-in)
  - Status: ❌ Missing
  - Pokemon: Tyranitar, Hippowdon, Gigalith
  - Notes: Requires weather system

- [ ] **Snow Warning** (Sets hail on switch-in)
  - Status: ❌ Missing
  - Pokemon: Abomasnow, Vanilluxe, Alolan Ninetales
  - Notes: Requires weather system

- [ ] **Cloud Nine** (Negates weather effects)
  - Status: ❌ Missing
  - Pokemon: Psyduck, Golduck, Altaria
  - Notes: Requires weather system

- [ ] **Air Lock** (Negates weather effects)
  - Status: ❌ Missing
  - Pokemon: Rayquaza
  - Notes: Requires weather system

---

### 2. Status Immunity Abilities

- [ ] **Limber** (Immune to paralysis)
  - Status: ❌ Missing
  - Pokemon: Ditto, Hitmonlee, Glameow
  - Notes: Check in status application

- [ ] **Water Veil** (Immune to burn)
  - Status: ❌ Missing
  - Pokemon: Golduck, Seaking, Wailord
  - Notes: Check in status application

- [ ] **Immunity** (Immune to poison)
  - Status: ❌ Missing
  - Pokemon: Snorlax, Zangoose
  - Notes: Check in status application

- [ ] **Insomnia** (Immune to sleep)
  - Status: ❌ Missing
  - Pokemon: Spinarak, Hoothoot, Delibird
  - Notes: Check in status application

- [ ] **Vital Spirit** (Immune to sleep)
  - Status: ❌ Missing
  - Pokemon: Mankey, Primeape, Delibird
  - Notes: Check in status application

- [ ] **Magma Armor** (Immune to freeze)
  - Status: ❌ Missing
  - Pokemon: Slugma, Magcargo
  - Notes: Check in status application

---

### 3. Type-Related Abilities

- [ ] **Levitate** (Immune to Ground moves)
  - Status: ❌ Missing
  - Pokemon: Many Psychic/Flying types
  - Notes: Check in type effectiveness calculation

- [ ] **Volt Absorb** (Heals from Electric moves)
  - Status: ❌ Missing
  - Pokemon: Jolteon, Lanturn, Pachirisu
  - Notes: Requires move type checking

- [ ] **Water Absorb** (Heals from Water moves)
  - Status: ❌ Missing
  - Pokemon: Vaporeon, Poliwrath, Quagsire
  - Notes: Requires move type checking

- [ ] **Flash Fire** (Immune to Fire, boosts Fire moves)
  - Status: ❌ Missing
  - Pokemon: Flareon, Arcanine, Houndoom
  - Notes: Requires move type checking and power boost

- [ ] **Lightning Rod** (Draws Electric moves, boosts Sp. Atk)
  - Status: ❌ Missing
  - Pokemon: Pikachu, Marowak, Manectric
  - Notes: Requires move redirection and stat boost

- [ ] **Motor Drive** (Immune to Electric, boosts Speed)
  - Status: ❌ Missing
  - Pokemon: Electivire
  - Notes: Requires move type checking and stat boost

- [ ] **Sap Sipper** (Immune to Grass, boosts Attack)
  - Status: ❌ Missing
  - Pokemon: Deerling, Sawsbuck, Gogoat
  - Notes: Requires move type checking and stat boost

---

### 4. Stat-Boosting Abilities

- [ ] **Intimidate** (Lowers enemy Attack on switch-in)
  - Status: ❌ Missing
  - Pokemon: Arcanine, Gyarados, Salamence
  - Notes: Requires switch-in trigger

- [ ] **Download** (Boosts Atk or SpA based on enemy defenses)
  - Status: ❌ Missing
  - Pokemon: Porygon-Z
  - Notes: Requires stat comparison

- [ ] **Adaptability** (Same-type moves do 2x damage instead of 1.5x)
  - Status: ❌ Missing
  - Pokemon: Eevee, Porygon-Z, Basculin
  - Notes: Requires STAB calculation modification

- [ ] **Huge Power** (Doubles Attack)
  - Status: ❌ Missing
  - Pokemon: Azumarill, Medicham
  - Notes: Requires stat modification

- [ ] **Pure Power** (Doubles Attack)
  - Status: ❌ Missing
  - Pokemon: Meditite, Medicham
  - Notes: Requires stat modification

- [ ] **Hustle** (1.5x Attack, 0.8x accuracy)
  - Status: ❌ Missing
  - Pokemon: Togepi, Rufflet, Deino
  - Notes: Requires stat and accuracy modification

---

### 5. Damage-Modifying Abilities

- [ ] **Thick Fat** (Takes 0.5x damage from Fire/Ice)
  - Status: ❌ Missing
  - Pokemon: Snorlax, Mamoswine, Hariyama
  - Notes: Requires type effectiveness modification

- [ ] **Filter** (Takes 0.75x damage from super-effective moves)
  - Status: ❌ Missing
  - Pokemon: Mr. Mime, Aggron
  - Notes: Requires super-effective damage modification

- [ ] **Solid Rock** (Takes 0.75x damage from super-effective moves)
  - Status: ❌ Missing
  - Pokemon: Camerupt, Rhyperior
  - Notes: Requires super-effective damage modification

- [ ] **Multiscale** (Takes 0.5x damage at full HP)
  - Status: ❌ Missing
  - Pokemon: Dragonite, Lugia
  - Notes: Requires HP checking

- [ ] **Wonder Guard** (Only takes damage from super-effective moves)
  - Status: ❌ Missing
  - Pokemon: Shedinja
  - Notes: Requires type effectiveness checking

---

### 6. Speed-Related Abilities

- [ ] **Speed Boost** (Raises Speed each turn)
  - Status: ❌ Missing
  - Pokemon: Ninjask, Yanmega, Blaziken
  - Notes: Requires end-of-turn trigger

- [ ] **Swift Swim** (2x Speed in rain)
  - Status: ❌ Missing
  - Pokemon: Golduck, Kingdra, Floatzel
  - Notes: Requires weather checking

- [ ] **Chlorophyll** (2x Speed in sun)
  - Status: ❌ Missing
  - Pokemon: Venusaur, Exeggutor, Leavanny
  - Notes: Requires weather checking

- [ ] **Sand Rush** (2x Speed in sandstorm)
  - Status: ❌ Missing
  - Pokemon: Excadrill, Stoutland
  - Notes: Requires weather checking

- [ ] **Slush Rush** (2x Speed in hail)
  - Status: ❌ Missing
  - Pokemon: Beartic, Sandslash-Alola
  - Notes: Requires weather checking

---

### 7. Recovery/Healing Abilities

- [ ] **Regenerator** (Heals 33% HP on switch-out)
  - Status: ❌ Missing
  - Pokemon: Slowbro, Tangrowth, Amoonguss
  - Notes: Requires switch-out trigger

- [ ] **Natural Cure** (Heals status on switch-out)
  - Status: ❌ Missing
  - Pokemon: Chansey, Starmie, Roserade
  - Notes: Requires switch-out trigger

- [ ] **Poison Heal** (Heals instead of taking poison damage)
  - Status: ❌ Missing
  - Pokemon: Breloom, Gliscor
  - Notes: Requires status damage modification

- [ ] **Magic Guard** (Only takes damage from attacks)
  - Status: ❌ Missing
  - Pokemon: Abra, Clefable, Sigilyph
  - Notes: Requires damage source checking

---

### 8. Move-Related Abilities

- [ ] **Mold Breaker** (Ignores enemy abilities)
  - Status: ❌ Missing
  - Pokemon: Pinsir, Rampardos, Excadrill
  - Notes: Requires ability bypass system

- [ ] **Technician** (1.5x power for moves ≤60 BP)
  - Status: ❌ Missing
  - Pokemon: Scyther, Breloom, Ambipom
  - Notes: Requires move power checking

- [ ] **Sheer Force** (1.3x power, removes secondary effects)
  - Status: ❌ Missing
  - Pokemon: Nidoking, Feraligatr, Conkeldurr
  - Notes: Requires move effect removal

- [ ] **Reckless** (1.2x power for recoil/jumping moves)
  - Status: ❌ Missing
  - Pokemon: Staraptor, Emboar
  - Notes: Requires move type checking

- [ ] **Iron Fist** (1.2x power for punching moves)
  - Status: ❌ Missing
  - Pokemon: Hitmonchan, Infernape, Conkeldurr
  - Notes: Requires move type checking

---

### 9. Entry Hazard Abilities

- [ ] **Rough Skin** (Damages contact move users)
  - Status: ❌ Missing
  - Pokemon: Carvanha, Garchomp, Druddigon
  - Notes: Requires contact move checking

- [ ] **Iron Barbs** (Damages contact move users)
  - Status: ❌ Missing
  - Pokemon: Ferroseed, Ferrothorn
  - Notes: Requires contact move checking

- [ ] **Static** (30% paralysis on contact)
  - Status: ❌ Missing
  - Pokemon: Pikachu, Electabuzz, Zapdos
  - Notes: Requires contact move checking

- [ ] **Flame Body** (30% burn on contact)
  - Status: ❌ Missing
  - Pokemon: Magmar, Magcargo, Volcarona
  - Notes: Requires contact move checking

- [ ] **Poison Point** (30% poison on contact)
  - Status: ❌ Missing
  - Pokemon: Nidoran, Roselia, Qwilfish
  - Notes: Requires contact move checking

---

### 10. Other Common Abilities

- [ ] **Synchronize** (Transfers status to enemy)
  - Status: ❌ Missing
  - Pokemon: Abra, Ralts, Umbreon
  - Notes: Requires status transfer system

- [ ] **Trace** (Copies enemy ability on switch-in)
  - Status: ❌ Missing
  - Pokemon: Ralts, Porygon
  - Notes: Requires ability copying

- [ ] **Inner Focus** (Immune to flinch)
  - Status: ❌ Missing
  - Pokemon: Abra, Zubat, Sneasel
  - Notes: Requires flinch system (which is missing)

- [ ] **Steadfast** (Raises Speed when flinched)
  - Status: ❌ Missing
  - Pokemon: Riolu, Lucario
  - Notes: Requires flinch system

- [ ] **Run Away** (Can always escape)
  - Status: ❌ Missing
  - Pokemon: Rattata, Eevee, Sentret
  - Notes: Only relevant in wild battles

- [ ] **Pickup** (Picks up items)
  - Status: ❌ Missing
  - Pokemon: Meowth, Zigzagoon, Pachirisu
  - Notes: Only relevant outside battle

- [ ] **Cute Charm** (30% infatuation on contact)
  - Status: ❌ Missing
  - Pokemon: Clefairy, Jigglypuff, Skitty
  - Notes: Requires infatuation system

---

## Implementation Status

**Total Pokemon**: 1103 (each with 1-3 abilities)
**Unique Abilities**: ~200+ different abilities

**Current Implementation**:
- ✅ Abilities stored in Pokemon data: Working
- ✅ Abilities assigned randomly: Working (pokemonBuilder.lua line 107-113)
- ❌ Abilities applied in battle: Missing
- ❌ Ability effects: Missing
- ❌ Ability triggers: Missing

**Critical Missing Systems**:
1. Weather system (affects many abilities)
2. Ability trigger system (switch-in, end-of-turn, etc.)
3. Ability effect system (stat changes, damage modification, etc.)
4. Contact move detection
5. Move type checking for abilities
6. Status immunity checking
7. Type effectiveness modification
8. Stat modification system
9. Ability bypass system (Mold Breaker)

**Testing Strategy**:
1. Sample test 10-20 Pokemon with different ability types
2. Verify abilities are assigned correctly
3. Test ability triggers (switch-in, end-of-turn, etc.)
4. Test ability effects (stat changes, damage modification, etc.)
5. Test ability interactions with moves and status

**Priority Abilities to Implement**:
1. Status immunities (Limber, Water Veil, Immunity, Insomnia, Vital Spirit)
2. Type immunities (Levitate, Volt Absorb, Water Absorb, Flash Fire)
3. Stat modifications (Intimidate, Huge Power, Adaptability)
4. Damage modifications (Thick Fat, Filter, Multiscale)
5. Contact abilities (Static, Flame Body, Rough Skin)

---

## Notes

- Abilities are currently assigned randomly but not implemented in battle logic
- Most abilities require additional systems (weather, terrain, contact detection, etc.)
- Some abilities are only relevant outside battle (Run Away, Pickup)
- Ability implementation should be done in `data/monster/battleState.lua` or a new `abilities.lua` file
- Each ability needs:
  - Trigger condition (switch-in, end-of-turn, on-hit, etc.)
  - Effect (stat change, damage modification, status application, etc.)
  - Interaction with other systems (weather, moves, status, etc.)

