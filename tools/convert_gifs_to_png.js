// Convert GIF back sprites to PNG for Love2D compatibility
const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const spritesDir = path.join(__dirname, '..', 'assets', 'sprites', 'pokemon');

async function convertGifs() {
    const files = fs.readdirSync(spritesDir);
    const gifs = files.filter(f => f.endsWith('.gif'));
    
    console.log(`Found ${gifs.length} GIF files to convert`);
    
    let converted = 0;
    let errors = 0;
    
    for (const gif of gifs) {
        const gifPath = path.join(spritesDir, gif);
        const pngName = gif.replace('.gif', '.png');
        const pngPath = path.join(spritesDir, pngName);
        
        // Skip if PNG already exists
        if (fs.existsSync(pngPath)) {
            continue;
        }
        
        try {
            await sharp(gifPath, { animated: false })
                .png()
                .toFile(pngPath);
            converted++;
            
            if (converted % 100 === 0) {
                console.log(`Converted ${converted} files...`);
            }
        } catch (err) {
            console.error(`Error converting ${gif}: ${err.message}`);
            errors++;
        }
    }
    
    console.log(`\nDone! Converted ${converted} GIFs to PNG`);
    if (errors > 0) {
        console.log(`Errors: ${errors}`);
    }
    
    // Remove old GIF files after successful conversion
    console.log('\nRemoving original GIF files...');
    for (const gif of gifs) {
        const gifPath = path.join(spritesDir, gif);
        const pngPath = path.join(spritesDir, gif.replace('.gif', '.png'));
        
        if (fs.existsSync(pngPath)) {
            fs.unlinkSync(gifPath);
        }
    }
    console.log('Cleanup complete!');
}

convertGifs().catch(console.error);

