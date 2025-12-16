// Script to split moves.lua into individual move files
const fs = require('fs');
const path = require('path');

const inputFile = path.join(__dirname, '..', 'data', 'monster', 'moves.lua');
const outputDir = path.join(__dirname, '..', 'data', 'monster', 'moves');

// Read the input file
const content = fs.readFileSync(inputFile, 'utf8');

// Parse each move entry using regex
// Format: ["movename"] = { ... },
const moveRegex = /\["([^\]]+)"\]\s*=\s*\{([^}]+)\}/g;

let match;
let count = 0;
const moveList = [];

while ((match = moveRegex.exec(content)) !== null) {
    const moveId = match[1];
    const moveData = match[2].trim();
    
    moveList.push(moveId);
    
    // Create individual file content
    const fileContent = `-- Move data for ${moveId}
return {
${moveData}
}
`;
    
    // Write the file
    const outputPath = path.join(outputDir, `${moveId}.lua`);
    fs.writeFileSync(outputPath, fileContent);
    count++;
}

console.log(`Created ${count} individual move files`);

// Create index file that lists all moves
const indexContent = `-- Index of all moves
return {
${moveList.map(m => `    "${m}"`).join(',\n')}
}
`;

fs.writeFileSync(path.join(outputDir, '_index.lua'), indexContent);
console.log('Created _index.lua with list of all moves');

