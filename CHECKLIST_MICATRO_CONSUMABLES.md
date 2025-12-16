# Micatro Consumables Verification Checklist

This checklist verifies all 52 consumables in Micatro (22 Tarots + 12 Planets + 18 Spectrals).

## Status Legend
- ✅ Working - Fully implemented and tested
- ⚠️ Partial - Partially implemented or needs testing
- ❌ Missing - Not implemented or broken

---

## Tarot Cards (22 cards)

### Enhancement Tarots (mod_conv)
- [ ] **The Magician** (c_magician)
  - Status: ⚠️ Partial
  - Effect: Apply enhancement to selected card
  - Implementation: `consumable_effects.lua` line 77-96
  - Notes: Requires card selection (max_highlighted)

- [ ] **The Empress** (c_empress)
  - Status: ⚠️ Partial
  - Effect: Apply enhancement to selected card
  - Implementation: `consumable_effects.lua` line 77-96
  - Notes: Requires card selection (max_highlighted)

- [ ] **The Hierophant** (c_heirophant)
  - Status: ⚠️ Partial
  - Effect: Apply enhancement to selected card
  - Implementation: `consumable_effects.lua` line 77-96
  - Notes: Requires card selection (max_highlighted)

- [ ] **The Chariot** (c_chariot)
  - Status: ⚠️ Partial
  - Effect: Apply enhancement to selected card
  - Implementation: `consumable_effects.lua` line 77-96
  - Notes: Requires card selection (max_highlighted)

- [ ] **Strength** (c_strength)
  - Status: ⚠️ Partial
  - Effect: Increase rank by 1 (up_rank)
  - Implementation: `consumable_effects.lua` line 80-89
  - Notes: Rank up system - verify it works correctly

### Suit Conversion Tarots (suit_conv)
- [ ] **The Star** (c_star)
  - Status: ⚠️ Partial
  - Effect: Convert suit to Hearts
  - Implementation: `consumable_effects.lua` line 98-104
  - Notes: Requires card selection

- [ ] **The Moon** (c_moon)
  - Status: ⚠️ Partial
  - Effect: Convert suit to Clubs
  - Implementation: `consumable_effects.lua` line 98-104
  - Notes: Requires card selection

- [ ] **The Sun** (c_sun)
  - Status: ⚠️ Partial
  - Effect: Convert suit to Diamonds
  - Implementation: `consumable_effects.lua` line 98-104
  - Notes: Requires card selection

- [ ] **The World** (c_world)
  - Status: ⚠️ Partial
  - Effect: Convert suit to Spades
  - Implementation: `consumable_effects.lua` line 98-104
  - Notes: Requires card selection

### Special Tarots
- [ ] **The Fool** (c_fool)
  - Status: ⚠️ Partial
  - Effect: Create last used tarot/planet
  - Implementation: `consumable_effects.lua` line 62-75
  - Notes: Requires tracking last_tarot/last_planet

- [ ] **The High Priestess** (c_high_priestess)
  - Status: ⚠️ Partial
  - Effect: Create up to 2 planet cards
  - Implementation: `consumable_effects.lua` line 113-122
  - Notes: Requires consumable slot checking

- [ ] **The Emperor** (c_emperor)
  - Status: ⚠️ Partial
  - Effect: Create up to 2 tarot cards
  - Implementation: `consumable_effects.lua` line 124-133
  - Notes: Requires consumable slot checking

- [ ] **The Hermit** (c_hermit)
  - Status: ⚠️ Partial
  - Effect: Double money (max $20)
  - Implementation: `consumable_effects.lua` line 135-139
  - Notes: Verify money calculation

- [ ] **Wheel of Fortune** (c_wheel_of_fortune)
  - Status: ⚠️ Partial
  - Effect: 1 in 4 chance to add edition to joker
  - Implementation: `consumable_effects.lua` line 141-153
  - Notes: Random chance system

- [ ] **The Hanged Man** (c_hanged_man)
  - Status: ⚠️ Partial
  - Effect: Destroy selected cards
  - Implementation: `consumable_effects.lua` line 106-111
  - Notes: Requires card selection

- [ ] **Death** (c_death)
  - Status: ⚠️ Partial
  - Effect: Convert left card into right card
  - Implementation: `consumable_effects.lua` line 172-180
  - Notes: Requires 2 card selection

- [ ] **Temperance** (c_temperance)
  - Status: ⚠️ Partial
  - Effect: Get sell value of all jokers (max $50)
  - Implementation: `consumable_effects.lua` line 155-163
  - Notes: Requires joker sell value calculation

- [ ] **Judgement** (c_judgement)
  - Status: ⚠️ Partial
  - Effect: Create random joker
  - Implementation: `consumable_effects.lua` line 165-170
  - Notes: Requires joker slot checking

- [x] **The Lovers** (c_lovers)
  - Status: ✅ Working
  - Effect: Enhances 1 selected card into a Wild Card (m_wild)
  - Implementation: `consumable_effects.lua` line 77-96 (generic mod_conv handler)
  - Notes: Handled by generic enhancement system, applied via play.lua line 1076-1105

- [x] **Justice** (c_justice)
  - Status: ✅ Working
  - Effect: Enhances 1 selected card into a Glass Card (m_glass)
  - Implementation: `consumable_effects.lua` line 77-96 (generic mod_conv handler)
  - Notes: Handled by generic enhancement system, applied via play.lua line 1076-1105

- [x] **The Devil** (c_devil)
  - Status: ✅ Working
  - Effect: Enhances 1 selected card into a Gold Card (m_gold)
  - Implementation: `consumable_effects.lua` line 77-96 (generic mod_conv handler)
  - Notes: Handled by generic enhancement system, applied via play.lua line 1076-1105

- [x] **The Tower** (c_tower)
  - Status: ✅ Working
  - Effect: Enhances 1 selected card into a Stone Card (m_stone)
  - Implementation: `consumable_effects.lua` line 77-96 (generic mod_conv handler)
  - Notes: Handled by generic enhancement system, applied via play.lua line 1076-1105

---

## Planet Cards (12 cards)

All planets level up a specific hand type. Implementation: `consumable_effects.lua` line 186-210

- [ ] **Mercury** (c_mercury)
  - Status: ⚠️ Partial
  - Effect: +1 level to High Card
  - Notes: Verify hand leveling works

- [ ] **Venus** (c_venus)
  - Status: ⚠️ Partial
  - Effect: +1 level to Pair
  - Notes: Verify hand leveling works

- [ ] **Earth** (c_earth)
  - Status: ⚠️ Partial
  - Effect: +1 level to Two Pair
  - Notes: Verify hand leveling works

- [ ] **Mars** (c_mars)
  - Status: ⚠️ Partial
  - Effect: +1 level to Three of a Kind
  - Notes: Verify hand leveling works

- [ ] **Jupiter** (c_jupiter)
  - Status: ⚠️ Partial
  - Effect: +1 level to Straight
  - Notes: Verify hand leveling works

- [ ] **Saturn** (c_saturn)
  - Status: ⚠️ Partial
  - Effect: +1 level to Flush
  - Notes: Verify hand leveling works

- [ ] **Uranus** (c_uranus)
  - Status: ⚠️ Partial
  - Effect: +1 level to Full House
  - Notes: Verify hand leveling works

- [ ] **Neptune** (c_neptune)
  - Status: ⚠️ Partial
  - Effect: +1 level to Four of a Kind
  - Notes: Verify hand leveling works

- [ ] **Pluto** (c_pluto)
  - Status: ⚠️ Partial
  - Effect: +1 level to Straight Flush
  - Notes: Verify hand leveling works

- [ ] **Planet X** (c_planet_x)
  - Status: ⚠️ Partial
  - Effect: +1 level to Five of a Kind
  - Notes: Verify hand leveling works

- [ ] **Ceres** (c_ceres)
  - Status: ⚠️ Partial
  - Effect: +1 level to Flush House
  - Notes: Verify hand leveling works

- [ ] **Eris** (c_eris)
  - Status: ⚠️ Partial
  - Effect: +1 level to Flush Five
  - Notes: Verify hand leveling works

**Planet Special Note**: All planets also update Constellation joker if present (line 204-208)

---

## Spectral Cards (18 cards)

### Card Destruction/Creation
- [ ] **Familiar** (c_familiar)
  - Status: ⚠️ Partial
  - Effect: Destroy 1 random card, add 3 enhanced face cards
  - Implementation: `consumable_effects.lua` line 219-235
  - Notes: Verify card creation works

- [ ] **Grim** (c_grim)
  - Status: ⚠️ Partial
  - Effect: Destroy 1 random card, add 2 enhanced Aces
  - Implementation: `consumable_effects.lua` line 237-252
  - Notes: Verify card creation works

- [ ] **Incantation** (c_incantation)
  - Status: ⚠️ Partial
  - Effect: Destroy 1 random card, add 4 enhanced number cards
  - Implementation: `consumable_effects.lua` line 254-270
  - Notes: Verify card creation works

### Seal Cards
- [ ] **Talisman** (c_talisman)
  - Status: ⚠️ Partial
  - Effect: Apply seal to selected card
  - Implementation: `consumable_effects.lua` line 272-281
  - Notes: Requires card selection

- [ ] **Deja Vu** (c_deja_vu)
  - Status: ⚠️ Partial
  - Effect: Apply seal to selected card
  - Implementation: `consumable_effects.lua` line 272-281
  - Notes: Requires card selection

- [ ] **Trance** (c_trance)
  - Status: ⚠️ Partial
  - Effect: Apply seal to selected card
  - Implementation: `consumable_effects.lua` line 272-281
  - Notes: Requires card selection

- [ ] **Medium** (c_medium)
  - Status: ⚠️ Partial
  - Effect: Apply seal to selected card
  - Implementation: `consumable_effects.lua` line 272-281
  - Notes: Requires card selection

### Special Effects
- [ ] **Aura** (c_aura)
  - Status: ⚠️ Partial
  - Effect: Add random edition to selected card
  - Implementation: `consumable_effects.lua` line 283-290
  - Notes: Requires card selection

- [ ] **Wraith** (c_wraith)
  - Status: ⚠️ Partial
  - Effect: Create rare joker, set money to $0
  - Implementation: `consumable_effects.lua` line 292-299
  - Notes: Verify money reset works

- [ ] **Sigil** (c_sigil)
  - Status: ⚠️ Partial
  - Effect: Convert all hand cards to one suit
  - Implementation: `consumable_effects.lua` line 301-308
  - Notes: Verify suit conversion works

- [ ] **Ouija** (c_ouija)
  - Status: ⚠️ Partial
  - Effect: Convert all hand cards to one rank, -1 hand size
  - Implementation: `consumable_effects.lua` line 310-319
  - Notes: Verify hand size reduction works

- [ ] **Ectoplasm** (c_ectoplasm)
  - Status: ⚠️ Partial
  - Effect: Add Negative to random joker, -1 hand size
  - Implementation: `consumable_effects.lua` line 321-329
  - Notes: Verify hand size reduction works

- [ ] **Immolate** (c_immolate)
  - Status: ⚠️ Partial
  - Effect: Destroy 5 random cards, gain $20
  - Implementation: `consumable_effects.lua` line 331-341
  - Notes: Verify money gain works

- [ ] **Ankh** (c_ankh)
  - Status: ⚠️ Partial
  - Effect: Copy random joker, destroy all others
  - Implementation: `consumable_effects.lua` line 343-355
  - Notes: Verify joker copying works

- [ ] **Hex** (c_hex)
  - Status: ⚠️ Partial
  - Effect: Add Polychrome to random joker, destroy all others
  - Implementation: `consumable_effects.lua` line 357-370
  - Notes: Verify joker modification works

- [ ] **Cryptid** (c_cryptid)
  - Status: ⚠️ Partial
  - Effect: Create 2 copies of selected card
  - Implementation: `consumable_effects.lua` line 372-386
  - Notes: Requires card selection

- [ ] **The Soul** (c_soul)
  - Status: ⚠️ Partial
  - Effect: Create legendary joker
  - Implementation: `consumable_effects.lua` line 388-393
  - Notes: Verify joker creation works

- [ ] **Black Hole** (c_black_hole)
  - Status: ⚠️ Partial
  - Effect: Level up all hands by 1
  - Implementation: `consumable_effects.lua` line 395-400
  - Notes: Verify all hands level up

---

## Summary

**Total Consumables**: 52
- Tarots: 22 (all implemented - The Lovers, Justice, The Devil, and The Tower are handled by generic mod_conv system)
- Planets: 12 (all implemented, need testing)
- Spectrals: 18 (all implemented, need testing)

**Common Issues to Check**:
1. Card selection requirements (max_highlighted, min_highlighted)
2. Slot availability checking (joker_slots, consumable_slots)
3. Money calculations
4. Card creation/destruction
5. Hand size modifications
6. Hand leveling system
7. Joker modifications (editions, copying)
8. Suit/rank conversions
9. Seal application

**Implementation Status**:
- All 52 consumables are now implemented
- The Lovers, Justice, The Devil, and The Tower were already working via the generic mod_conv enhancement handler
- All enhancement types (m_wild, m_glass, m_gold, m_stone) are properly supported

