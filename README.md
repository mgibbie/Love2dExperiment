# Love2D Experiment

A collection of experimental game projects built with Love2D (Lua).

## Projects

This repository contains multiple game experiments and prototypes:

### Battlecards
A Svelte 5 + TypeScript roguelike deckbuilder card game (Vite build). Features card battles, deck editing, and collection management.

### Micatro
A card game inspired by Balatro mechanics with consumables, vouchers, and jokers.

### Monster Battle
A monster collection and battle system with drafting, healing, and battle mechanics.

### Itemslot
A modular game system with Balatro integration, featuring an infinite grid world, player movement, and interactive objects.

## Structure

- `main.lua` - Main entry point with scene management
- `scenes/` - Game scene implementations
- `data/` - Game data (cards, monsters, battle logic)
- `ui/` - UI components
- `assets/` - Game assets (sprites, sounds, shaders)
- `micatro/` - Micatro game implementation
- `itemslot/` - Itemslot game module
- `tools/` - Utility scripts for data processing

## Requirements

- Love2D 11.x or later
- Lua 5.1+

## Running

Simply drag the project folder onto Love2D or run:
```bash
love .
```

## Documentation

See `balatro-docs/` for extracted game mechanics documentation (enhancements, editions, vouchers, consumables, seals, tags, blinds, challenges).

## License

This is an experimental project. Various game mechanics and assets may be inspired by existing games like Balatro (by LocalThunk/Playstack).

