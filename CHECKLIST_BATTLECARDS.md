# Battlecards Verification Checklist

This checklist verifies all 31 cards in the Battlecards game mode.

## Status Legend
- ✅ Working - Fully implemented and tested
- ⚠️ Partial - Partially implemented or needs testing
- ❌ Missing - Not implemented or broken

---

## Neutral Cards (4 cards)

### Creatures
- [ ] **Recruit** (Common, 1 cost, 1/2)
  - Status: ⚠️ Partial
  - Keywords: None
  - Effect: "A basic fighter ready for battle."
  - Notes: Basic creature, should work but needs testing

- [ ] **Wandering Merchant** (Uncommon, 2 cost, 2/2)
  - Status: ⚠️ Partial
  - Keywords: Battlecry
  - Effect: "Battlecry: Draw a card."
  - Notes: Requires Battlecry keyword implementation

### Spells
- [ ] **Arcane Bolt** (Common, 2 cost)
  - Status: ⚠️ Partial
  - Keywords: None
  - Effect: "Deal 3 damage to any target."
  - Notes: Requires spell targeting system

- [ ] **Healing Potion** (Common, 1 cost)
  - Status: ⚠️ Partial
  - Keywords: None
  - Effect: "Restore 5 health to your hero."
  - Notes: Requires hero healing system

---

## Centurion Cards (8 cards)

### Creatures
- [ ] **Shield Bearer** (Common, 2 cost, 1/4)
  - Status: ⚠️ Partial
  - Keywords: Taunt
  - Effect: "Taunt"
  - Notes: Requires Taunt keyword implementation

- [ ] **Legion Commander** (Rare, 4 cost, 3/4)
  - Status: ⚠️ Partial
  - Keywords: Battlecry
  - Tribe: Soldier
  - Effect: "Battlecry: Give adjacent creatures +1/+1."
  - Notes: Requires adjacent creature targeting

- [ ] **Golden Guardian** (Epic, 5 cost, 4/6)
  - Status: ⚠️ Partial
  - Keywords: Taunt, Divine Shield
  - Effect: "Taunt. Divine Shield."
  - Notes: Requires both Taunt and Divine Shield keywords

- [ ] **Acidspitter** (Rare, 3 cost, 2/2)
  - Status: ⚠️ Partial
  - Keywords: Deathtouch, Deathrattle
  - Tribe: Beast
  - Effect: "Deathtouch. Deathrattle: Deal 1 damage to a random opponent or creature."
  - Notes: Requires Deathtouch and Deathrattle keywords

- [ ] **Acidspitter Nest** (Epic, 5 cost, 0/7)
  - Status: ⚠️ Partial
  - Keywords: None
  - Tribe: Construct
  - Effect: "At the end of your turn create two Acidspitters."
  - Notes: Requires end-of-turn trigger system

### Spells
- [ ] **Fortify** (Common, 2 cost)
  - Status: ⚠️ Partial
  - Keywords: None
  - Effect: "Give a creature +0/+3 and Taunt."
  - Notes: Requires creature buff system

- [ ] **Rallying Cry** (Uncommon, 3 cost)
  - Status: ⚠️ Partial
  - Keywords: None
  - Effect: "Give all friendly creatures +1/+1."
  - Notes: Requires board-wide buff system

---

## Naturalist Cards (5 cards)

### Creatures
- [ ] **Forest Sprite** (Common, 1 cost, 1/1)
  - Status: ⚠️ Partial
  - Keywords: Deathrattle
  - Tribe: Spirit
  - Effect: "Deathrattle: Summon a 1/1 Seedling."
  - Notes: Requires Deathrattle and token summoning

- [ ] **Pack Wolf** (Uncommon, 3 cost, 3/3)
  - Status: ⚠️ Partial
  - Keywords: Battlecry
  - Tribe: Beast
  - Effect: "Battlecry: If you control another Beast, gain +2/+2."
  - Notes: Requires conditional Battlecry

- [ ] **Ancient Treant** (Legendary, 6 cost, 5/8)
  - Status: ⚠️ Partial
  - Keywords: Taunt
  - Tribe: Elemental
  - Effect: "Taunt. At end of turn, restore 2 health to your hero."
  - Notes: Requires end-of-turn trigger

### Spells
- [ ] **Wild Growth** (Common, 2 cost)
  - Status: ⚠️ Partial
  - Keywords: None
  - Effect: "Summon two 1/1 Animal tokens."
  - Notes: Requires token summoning

- [ ] **Nature's Blessing** (Rare, 3 cost)
  - Status: ⚠️ Partial
  - Keywords: None
  - Effect: "Restore 8 health. Draw a card."
  - Notes: Requires healing and card draw

---

## Bounty Hunter Cards (14 cards)

### Creatures
- [ ] **Shadow Stalker** (Uncommon, 2 cost, 3/2)
  - Status: ⚠️ Partial
  - Keywords: Stealth
  - Effect: "Stealth"
  - Notes: Requires Stealth keyword

- [ ] **Contract Killer** (Rare, 4 cost, 4/3)
  - Status: ⚠️ Partial
  - Keywords: Battlecry
  - Effect: "Battlecry: Destroy a creature with 3 or less health."
  - Notes: Requires conditional destruction

- [ ] **Guild Assassin** (Legendary, 5 cost, 5/4)
  - Status: ⚠️ Partial
  - Keywords: Stealth, Deathtouch
  - Effect: "Stealth. Deathtouch."
  - Notes: Requires both keywords

- [ ] **Tumbleweed Tactician** (Uncommon, 4 cost, 3/3)
  - Status: ⚠️ Partial
  - Keywords: Battlecry
  - Tribe: Lizardfolk
  - Effect: "Battlecry: Deal 3 damage to target creature. If it dies, create a 2/1 Tumbleweed with Rush."
  - Notes: Complex conditional effect

- [ ] **The Lone Ranger** (Legendary, 2 cost, 2/2)
  - Status: ⚠️ Partial
  - Keywords: Battlecry
  - Tribe: Human
  - Effect: "Battlecry: Choose one - Destroy creature with cost 4 or less; or Copy creature with cost 2 or less."
  - Notes: Requires choose-one mechanic

- [ ] **Running Gunner** (Common, 3 cost, 3/2)
  - Status: ⚠️ Partial
  - Keywords: Rush, Deathrattle
  - Tribe: Human
  - Effect: "Rush. Deathrattle: Deal 1 damage to each enemy creature and opponent."
  - Notes: Requires Rush and multi-target Deathrattle

- [ ] **Paid Off Patrolman** (Common, 7 cost, 5/8)
  - Status: ⚠️ Partial
  - Keywords: Taunt
  - Tribe: Human
  - Effect: "Taunt. Costs 1 less for each coin in your graveyard."
  - Notes: Requires cost reduction based on graveyard

- [ ] **Officer Octo** (Legendary, 4 cost, 2/2)
  - Status: ⚠️ Partial
  - Keywords: Battlecry
  - Tribe: Beast
  - Effect: "Battlecry: Quickdraw 8."
  - Notes: Requires Quickdraw mechanic

- [ ] **Landlocked Privateer** (Common, 1 cost, 1/2)
  - Status: ⚠️ Partial
  - Keywords: None
  - Tribe: Pirate
  - Effect: "Inspire: Quickdraw 2."
  - Notes: Requires Inspire keyword

- [ ] **Harried Herdsman** (Uncommon, 5 cost, 4/5)
  - Status: ⚠️ Partial
  - Keywords: None
  - Tribe: Human
  - Effect: "After you cast a Fire spell, each Beast you control attacks a random enemy."
  - Notes: Requires spell type detection and triggered attacks

### Spells
- [ ] **Mark Target** (Common, 1 cost)
  - Status: ⚠️ Partial
  - Keywords: None
  - Effect: "Mark an enemy creature. When it dies, draw 2 cards."
  - Notes: Requires marking/death tracking system

- [ ] **Backstab** (Common, 0 cost)
  - Status: ⚠️ Partial
  - Keywords: None
  - Effect: "Deal 2 damage to an undamaged creature."
  - Notes: Requires damage state checking

- [ ] **Westward Prosperity** (Legendary, 1 cost)
  - Status: ⚠️ Partial
  - Keywords: Quest
  - Effect: "Quest: Quickdraw 9 cards. Reward: Deal 9 damage to all enemies."
  - Notes: Requires Quest system

- [ ] **Silencer** (Uncommon, 1 cost)
  - Status: ⚠️ Partial
  - Keywords: Aura
  - Effect: "Enchant Hero Weapon. Whenever you attack a creature, Silence it."
  - Notes: Requires Aura/Enchantment system

- [ ] **Regroup** (Uncommon, 1 cost)
  - Status: ⚠️ Partial
  - Keywords: None
  - Effect: "Draw a card for each creature you control that died this turn."
  - Notes: Requires death tracking this turn

---

## Summary

**Total Cards**: 31
- Neutral: 4
- Centurion: 8
- Naturalist: 5
- Bounty Hunter: 14

**Keywords Required**:
- Battlecry (multiple cards)
- Taunt (multiple cards)
- Deathrattle (multiple cards)
- Stealth (2 cards)
- Deathtouch (2 cards)
- Divine Shield (1 card)
- Rush (1 card)
- Quest (1 card)
- Aura (1 card)
- Inspire (1 card)

**Systems Required**:
- Spell targeting
- Hero healing
- Creature buffing
- Token summoning
- End-of-turn triggers
- Death tracking
- Conditional effects
- Choose-one mechanics
- Cost reduction
- Quickdraw mechanic
- Quest system
- Aura/Enchantment system

