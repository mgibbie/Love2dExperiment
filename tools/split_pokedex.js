// Script to split pokedex.lua into individual Pokemon files
const fs = require('fs');
const path = require('path');

const inputFile = path.join(__dirname, '..', 'data', 'monster', 'pokedex.lua');
const outputDir = path.join(__dirname, '..', 'data', 'monster', 'pokemon');

// Read the input file
const content = fs.readFileSync(inputFile, 'utf8');

// Find the pokemon data section
const dataStart = content.indexOf('pokedex.pokemon = {');
const dataEnd = content.lastIndexOf('}', content.indexOf('-- Get list of all pokemon IDs'));

const pokemonSection = content.substring(dataStart, dataEnd);

// Parse each Pokemon entry - need to handle nested braces
const pokemonList = [];
let count = 0;

// Match the start of each entry
const entryStartRegex = /\["([^\]]+)"\]\s*=\s*\{/g;
let match;
const entries = [];

while ((match = entryStartRegex.exec(pokemonSection)) !== null) {
    entries.push({
        id: match[1],
        startIndex: match.index + match[0].length
    });
}

// For each entry, find where it ends by counting braces
for (let i = 0; i < entries.length; i++) {
    const entry = entries[i];
    const startIdx = entry.startIndex;
    
    // Find the end by counting braces (we're already inside the first {)
    let braceCount = 1;
    let endIdx = startIdx;
    
    for (let j = startIdx; j < pokemonSection.length && braceCount > 0; j++) {
        if (pokemonSection[j] === '{') braceCount++;
        else if (pokemonSection[j] === '}') braceCount--;
        endIdx = j;
    }
    
    const pokemonData = pokemonSection.substring(startIdx, endIdx).trim();
    pokemonList.push(entry.id);
    
    // Create individual file content with proper formatting
    const fileContent = `-- Pokemon data for ${entry.id}
return {
    ${pokemonData}
}
`;
    
    // Write the file
    const outputPath = path.join(outputDir, `${entry.id}.lua`);
    fs.writeFileSync(outputPath, fileContent);
    count++;
}

console.log(`Created ${count} individual Pokemon files`);

// Create index file that lists all Pokemon
const indexContent = `-- Index of all Pokemon
return {
${pokemonList.map(p => `    "${p}"`).join(',\n')}
}
`;

fs.writeFileSync(path.join(outputDir, '_index.lua'), indexContent);
console.log('Created _index.lua with list of all Pokemon');
