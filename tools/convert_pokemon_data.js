/**
 * Pokemon Data Converter
 * Converts Pokemon Showdown TypeScript data to Lua format
 */

const fs = require('fs');
const path = require('path');

const PS_DATA = path.join(__dirname, '..', 'pokemon-showdown-master', 'data');
const OUTPUT_DIR = path.join(__dirname, '..', 'data', 'monster');

// Helper to escape Lua strings
function luaString(str) {
    if (!str) return '""';
    return `"${str.replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n')}"`;
}

// Convert Pokedex
function convertPokedex() {
    console.log('Converting Pokedex...');
    const content = fs.readFileSync(path.join(PS_DATA, 'pokedex.ts'), 'utf8');
    
    const pokemon = {};
    const lines = content.split('\n');
    
    let currentId = null;
    let currentData = {};
    let braceDepth = 0;
    let inPokemon = false;
    
    for (const line of lines) {
        // Start of a new pokemon entry (tab + identifier + colon + brace)
        const startMatch = line.match(/^\t([a-z][a-z0-9]*): \{$/);
        if (startMatch && braceDepth === 0) {
            currentId = startMatch[1];
            currentData = {};
            braceDepth = 1;
            inPokemon = true;
            continue;
        }
        
        if (inPokemon) {
            braceDepth += (line.match(/{/g) || []).length;
            braceDepth -= (line.match(/}/g) || []).length;
            
            // Extract num (including negative for CAP Pokemon)
            const numMatch = line.match(/num: (-?\d+)/);
            if (numMatch) currentData.num = parseInt(numMatch[1]);
            
            // Extract name
            const nameMatch = line.match(/name: "([^"]+)"/);
            if (nameMatch) currentData.name = nameMatch[1];
            
            // Extract types
            const typesMatch = line.match(/types: \[([^\]]+)\]/);
            if (typesMatch) {
                currentData.types = typesMatch[1].match(/"([^"]+)"/g)?.map(t => t.replace(/"/g, '')) || [];
            }
            
            // Extract baseStats
            const statsMatch = line.match(/baseStats: \{([^}]+)\}/);
            if (statsMatch) {
                const s = statsMatch[1];
                currentData.baseStats = {
                    hp: parseInt(s.match(/hp: (\d+)/)?.[1] || 0),
                    atk: parseInt(s.match(/atk: (\d+)/)?.[1] || 0),
                    def: parseInt(s.match(/def: (\d+)/)?.[1] || 0),
                    spa: parseInt(s.match(/spa: (\d+)/)?.[1] || 0),
                    spd: parseInt(s.match(/spd: (\d+)/)?.[1] || 0),
                    spe: parseInt(s.match(/spe: (\d+)/)?.[1] || 0)
                };
            }
            
            // Extract abilities
            const abilMatch = line.match(/abilities: \{([^}]+)\}/);
            if (abilMatch) {
                const matches = abilMatch[1].match(/"([^"]+)"/g);
                currentData.abilities = matches ? matches.map(a => a.replace(/"/g, '')) : [];
            }
            
            // Check for baseSpecies (skip alternate forms)
            if (line.includes('baseSpecies:')) {
                currentData.isForm = true;
            }
            
            // End of pokemon entry
            if (braceDepth === 0) {
                inPokemon = false;
                
                // Save if valid, not an alternate form, and not Pokestar Pokemon
                // CAP Pokemon are -1 to -100ish, Pokestar are -5000+ (filter those out)
                const isPokestar = currentData.num < -100;
                if (currentData.num && currentData.name && currentData.baseStats && !currentData.isForm && !isPokestar) {
                    pokemon[currentId] = currentData;
                }
                currentId = null;
                currentData = {};
            }
        }
    }
    
    // Write Lua file
    let lua = '-- Pokemon Data (Auto-generated)\nlocal pokedex = {}\n\npokedex.pokemon = {\n';
    
    const sorted = Object.entries(pokemon).sort((a, b) => a[1].num - b[1].num);
    
    for (const [id, data] of sorted) {
        lua += `    ["${id}"] = {\n`;
        lua += `        num = ${data.num},\n`;
        lua += `        name = ${luaString(data.name)},\n`;
        lua += `        types = {${data.types.map(t => luaString(t)).join(', ')}},\n`;
        lua += `        baseStats = { hp = ${data.baseStats.hp}, atk = ${data.baseStats.atk}, def = ${data.baseStats.def}, spa = ${data.baseStats.spa}, spd = ${data.baseStats.spd}, spe = ${data.baseStats.spe} },\n`;
        lua += `        abilities = {${(data.abilities || []).map(a => luaString(a)).join(', ')}}\n`;
        lua += `    },\n`;
    }
    
    lua += '}\n\n';
    lua += '-- Get list of all pokemon IDs\npokedex.allIds = {}\nfor id, _ in pairs(pokedex.pokemon) do\n    table.insert(pokedex.allIds, id)\nend\n\n';
    lua += 'function pokedex.getRandom()\n    return pokedex.allIds[math.random(1, #pokedex.allIds)]\nend\n\n';
    lua += 'return pokedex\n';
    
    fs.writeFileSync(path.join(OUTPUT_DIR, 'pokedex.lua'), lua);
    console.log(`  Wrote ${sorted.length} Pokemon`);
}

// Convert Moves
function convertMoves() {
    console.log('Converting Moves...');
    const content = fs.readFileSync(path.join(PS_DATA, 'moves.ts'), 'utf8');
    
    const moves = {};
    const lines = content.split('\n');
    
    let currentId = null;
    let currentData = {};
    let braceDepth = 0;
    let inMove = false;
    let blockText = '';
    
    for (const line of lines) {
        // Start of a new move entry
        const startMatch = line.match(/^\t"?([a-z0-9]+)"?: \{$/);
        if (startMatch && braceDepth === 0) {
            currentId = startMatch[1];
            currentData = {};
            braceDepth = 1;
            inMove = true;
            blockText = '';
            continue;
        }
        
        if (inMove) {
            braceDepth += (line.match(/{/g) || []).length;
            braceDepth -= (line.match(/}/g) || []).length;
            blockText += line + '\n';
            
            // End of move entry
            if (braceDepth === 0) {
                inMove = false;
                
                // Parse the collected block (negative nums for CAP moves)
                const numMatch = blockText.match(/num: (-?\d+)/);
                const nameMatch = blockText.match(/name: "([^"]+)"/);
                const typeMatch = blockText.match(/type: "([^"]+)"/);
                const categoryMatch = blockText.match(/category: "([^"]+)"/);
                const basePowerMatch = blockText.match(/basePower: (\d+)/);
                const accuracyMatch = blockText.match(/accuracy: (true|\d+)/);
                const ppMatch = blockText.match(/pp: (\d+)/);
                const priorityMatch = blockText.match(/priority: (-?\d+)/);
                
                // Skip Z-moves and Max moves only (allow CAP and other non-standard)
                const isZMove = blockText.includes('isZ:');
                const isMax = blockText.includes('isMax');
                
                if (nameMatch && typeMatch && categoryMatch && !isZMove && !isMax) {
                    moves[currentId] = {
                        num: parseInt(numMatch?.[1] || 0),
                        name: nameMatch[1],
                        type: typeMatch[1],
                        category: categoryMatch[1],
                        basePower: parseInt(basePowerMatch?.[1] || 0),
                        accuracy: accuracyMatch?.[1] === 'true' ? 100 : parseInt(accuracyMatch?.[1] || 100),
                        pp: parseInt(ppMatch?.[1] || 5),
                        priority: parseInt(priorityMatch?.[1] || 0)
                    };
                }
                
                currentId = null;
                currentData = {};
                blockText = '';
            }
        }
    }
    
    // Write Lua file
    let lua = '-- Move Data (Auto-generated)\nlocal moves = {}\n\nmoves.data = {\n';
    
    const sorted = Object.entries(moves).sort((a, b) => a[1].num - b[1].num);
    
    for (const [id, data] of sorted) {
        lua += `    ["${id}"] = {\n`;
        lua += `        name = ${luaString(data.name)},\n`;
        lua += `        type = ${luaString(data.type)},\n`;
        lua += `        category = ${luaString(data.category)},\n`;
        lua += `        basePower = ${data.basePower},\n`;
        lua += `        accuracy = ${data.accuracy},\n`;
        lua += `        pp = ${data.pp},\n`;
        lua += `        priority = ${data.priority}\n`;
        lua += `    },\n`;
    }
    
    lua += '}\n\nreturn moves\n';
    
    fs.writeFileSync(path.join(OUTPUT_DIR, 'moves.lua'), lua);
    console.log(`  Wrote ${sorted.length} Moves`);
}

// Convert Learnsets
function convertLearnsets() {
    console.log('Converting Learnsets...');
    const content = fs.readFileSync(path.join(PS_DATA, 'learnsets.ts'), 'utf8');
    
    const learnsets = {};
    const lines = content.split('\n');
    
    let currentId = null;
    let braceDepth = 0;
    let inLearnset = false;
    let learnsetText = '';
    
    for (const line of lines) {
        // Start of a new pokemon learnset entry
        const startMatch = line.match(/^\t([a-z][a-z0-9]*): \{$/);
        if (startMatch && braceDepth === 0) {
            currentId = startMatch[1];
            braceDepth = 1;
            learnsetText = '';
            continue;
        }
        
        if (currentId) {
            braceDepth += (line.match(/{/g) || []).length;
            braceDepth -= (line.match(/}/g) || []).length;
            
            // Check for learnset block
            if (line.includes('learnset: {')) {
                inLearnset = true;
            }
            
            if (inLearnset) {
                learnsetText += line + '\n';
            }
            
            // End of pokemon entry
            if (braceDepth === 0) {
                // Extract move IDs from learnset
                const moveMatches = learnsetText.match(/\t\t(\w+): \[/g);
                if (moveMatches) {
                    const moveList = moveMatches.map(m => m.match(/(\w+):/)[1]);
                    learnsets[currentId] = moveList;
                }
                
                currentId = null;
                inLearnset = false;
                learnsetText = '';
            }
        }
    }
    
    // Write Lua file
    let lua = '-- Learnset Data (Auto-generated)\nlocal learnsets = {}\n\nlearnsets.data = {\n';
    
    for (const [id, moveList] of Object.entries(learnsets)) {
        if (moveList.length > 0) {
            lua += `    ["${id}"] = {${moveList.map(m => `"${m}"`).join(', ')}},\n`;
        }
    }
    
    lua += '}\n\n';
    lua += 'function learnsets.getMovesFor(pokemonId)\n    return learnsets.data[pokemonId] or {}\nend\n\n';
    lua += 'return learnsets\n';
    
    fs.writeFileSync(path.join(OUTPUT_DIR, 'learnsets.lua'), lua);
    console.log(`  Wrote ${Object.keys(learnsets).length} Learnsets`);
}

// Convert Type Chart
function convertTypes() {
    console.log('Converting Types...');
    const content = fs.readFileSync(path.join(PS_DATA, 'typechart.ts'), 'utf8');
    
    const types = ['Normal', 'Fire', 'Water', 'Electric', 'Grass', 'Ice', 'Fighting', 
                   'Poison', 'Ground', 'Flying', 'Psychic', 'Bug', 'Rock', 'Ghost', 
                   'Dragon', 'Dark', 'Steel', 'Fairy'];
    
    const effectiveness = {};
    const lines = content.split('\n');
    
    let currentType = null;
    let braceDepth = 0;
    let inDamageTaken = false;
    let dmgText = '';
    
    for (const line of lines) {
        // Start of a type entry
        const startMatch = line.match(/^\t(\w+): \{$/);
        if (startMatch && braceDepth === 0) {
            currentType = startMatch[1];
            braceDepth = 1;
            continue;
        }
        
        if (currentType) {
            braceDepth += (line.match(/{/g) || []).length;
            braceDepth -= (line.match(/}/g) || []).length;
            
            if (line.includes('damageTaken: {')) {
                inDamageTaken = true;
                dmgText = '';
            }
            
            if (inDamageTaken) {
                dmgText += line + '\n';
                if (line.includes('},')) {
                    inDamageTaken = false;
                    
                    effectiveness[currentType] = {};
                    for (const t of types) {
                        const match = dmgText.match(new RegExp(`${t}: (\\d+)`));
                        if (match) {
                            effectiveness[currentType][t] = parseInt(match[1]);
                        }
                    }
                }
            }
            
            if (braceDepth === 0) {
                currentType = null;
            }
        }
    }
    
    // Write Lua file
    let lua = '-- Type Data (Auto-generated)\nlocal types = {}\n\n';
    lua += 'types.all = {"Normal", "Fire", "Water", "Electric", "Grass", "Ice", "Fighting", "Poison", "Ground", "Flying", "Psychic", "Bug", "Rock", "Ghost", "Dragon", "Dark", "Steel", "Fairy"}\n\n';
    
    lua += '-- Type colors for UI\ntypes.colors = {\n';
    lua += '    Normal = {0.66, 0.66, 0.47}, Fire = {0.93, 0.51, 0.19}, Water = {0.39, 0.56, 0.94},\n';
    lua += '    Electric = {0.97, 0.82, 0.17}, Grass = {0.47, 0.78, 0.30}, Ice = {0.59, 0.85, 0.84},\n';
    lua += '    Fighting = {0.76, 0.18, 0.16}, Poison = {0.64, 0.24, 0.63}, Ground = {0.89, 0.75, 0.40},\n';
    lua += '    Flying = {0.66, 0.56, 0.95}, Psychic = {0.98, 0.33, 0.53}, Bug = {0.65, 0.73, 0.10},\n';
    lua += '    Rock = {0.71, 0.63, 0.21}, Ghost = {0.45, 0.34, 0.59}, Dragon = {0.44, 0.21, 0.99},\n';
    lua += '    Dark = {0.44, 0.34, 0.27}, Steel = {0.72, 0.72, 0.81}, Fairy = {0.84, 0.52, 0.68}\n';
    lua += '}\n\n';
    
    lua += '-- Damage taken chart: defender -> attacker -> multiplier code\n';
    lua += '-- 0=1x, 1=2x (super effective), 2=0.5x (resist), 3=0x (immune)\n';
    lua += 'types.chart = {\n';
    
    for (const [defType, matchups] of Object.entries(effectiveness)) {
        lua += `    ["${defType}"] = {`;
        const entries = [];
        for (const [atkType, val] of Object.entries(matchups)) {
            entries.push(`["${atkType}"] = ${val}`);
        }
        lua += entries.join(', ');
        lua += '},\n';
    }
    
    lua += '}\n\n';
    
    lua += `-- Get effectiveness multiplier
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
`;
    
    fs.writeFileSync(path.join(OUTPUT_DIR, 'types.lua'), lua);
    console.log('  Wrote Type Chart');
}

// Run all conversions
console.log('=== Pokemon Data Converter ===\n');
convertPokedex();
convertMoves();
convertLearnsets();
convertTypes();
console.log('\nDone!');
