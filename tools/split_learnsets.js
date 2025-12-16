// Script to split learnsets.lua into individual Pokemon files
const fs = require('fs');
const path = require('path');

const inputFile = path.join(__dirname, '..', 'data', 'monster', 'learnsets.lua');
const outputDir = path.join(__dirname, '..', 'data', 'monster', 'learnsets');

// Read the input file
const content = fs.readFileSync(inputFile, 'utf8');

// Parse each Pokemon's learnset using regex
// Format: ["pokemonname"] = {...},
const pokemonRegex = /\["([^\]]+)"\]\s*=\s*(\{[^}]+\})/g;

let match;
let count = 0;
const pokemonList = [];

while ((match = pokemonRegex.exec(content)) !== null) {
    const pokemonId = match[1];
    const movesArray = match[2];
    
    pokemonList.push(pokemonId);
    
    // Create individual file content
    const fileContent = `-- Learnset for ${pokemonId}
return ${movesArray}
`;
    
    // Write the file
    const outputPath = path.join(outputDir, `${pokemonId}.lua`);
    fs.writeFileSync(outputPath, fileContent);
    count++;
}

console.log(`Created ${count} individual learnset files`);

// Create index file that lists all Pokemon (for the loader)
const indexContent = `-- Index of all Pokemon with learnsets
return {
${pokemonList.map(p => `    "${p}"`).join(',\n')}
}
`;

fs.writeFileSync(path.join(outputDir, '_index.lua'), indexContent);
console.log('Created _index.lua with list of all Pokemon');

