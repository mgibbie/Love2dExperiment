-- Sprite Loader for Monster Battle
-- Loads and caches Pokemon sprites from assets folder

local spriteLoader = {}

-- Sprite cache
local cache = {}
local flipCache = {}  -- Track which sprites need to be flipped (front used as back)
local debugMode = false  -- Set to true to see loading debug messages
local initStatus = "Not initialized"

-- Sprite path - now using local assets folder
local SPRITE_PATH = "assets/sprites/pokemon/"

-- Debug log helper
local function debugLog(msg)
    if debugMode then
        print("[SpriteLoader] " .. msg)
    end
end

-- Convert Pokemon number to sprite ID
-- Base form sprite ID = Pokedex number × 32
-- CAP Pokemon (negative num): 536870912 + (|num| × 32)
function spriteLoader.nameToSpriteId(name, num)
    if num then
        if num < 0 then
            -- CAP Pokemon use special ID formula
            return "s" .. (536870912 + (math.abs(num) * 32))
        else
            return "s" .. (num * 32)
        end
    end
    return nil
end

-- Get sprite path for a Pokemon by its pokedex number
-- Options: back (bool), shiny (bool)
-- Returns: path, needsFlip (true if using front sprite as back fallback)
function spriteLoader.getSpritePath(num, options)
    options = options or {}
    
    local spriteId
    if num < 0 then
        -- CAP Pokemon: 536870912 + (|num| × 32)
        spriteId = "s" .. (536870912 + (math.abs(num) * 32))
    else
        spriteId = "s" .. (num * 32)
    end
    
    -- Build suffix based on options
    local suffix = ""
    if options.back then suffix = suffix .. "-b" end
    if options.shiny then suffix = suffix .. "-s" end
    
    -- Try PNG first, then GIF
    local baseName = spriteId .. suffix
    for _, ext in ipairs({".png", ".gif"}) do
        local fullPath = SPRITE_PATH .. baseName .. ext
        local info = love.filesystem.getInfo(fullPath)
        if info then
            return fullPath, false
        end
    end
    
    -- Fallback to front sprite if back not available (will be flipped)
    if options.back then
        local frontBase = spriteId .. (options.shiny and "-s" or "")
        for _, ext in ipairs({".png", ".gif"}) do
            local frontPath = SPRITE_PATH .. frontBase .. ext
            local frontInfo = love.filesystem.getInfo(frontPath)
            if frontInfo then
                debugLog("Back sprite not found, using flipped front for num " .. num)
                return frontPath, true  -- needs flip
            end
        end
    end
    
    debugLog("Not found for num " .. num .. " (spriteId: " .. spriteId .. ")")
    return nil, false
end

-- Initialize and test file access
function spriteLoader.init()
    local testPath = SPRITE_PATH .. "s32.png"
    local info = love.filesystem.getInfo(testPath)
    
    if info then
        initStatus = "OK"
        local spriteFiles = love.filesystem.getDirectoryItems(SPRITE_PATH)
        local count = 0
        for _, f in ipairs(spriteFiles) do
            if f:match("%.png$") then count = count + 1 end
        end
        initStatus = initStatus .. " [" .. count .. " sprites]"
    else
        initStatus = "No sprites found"
    end
end

-- Get initialization status for debugging
function spriteLoader.getStatus()
    return initStatus
end

-- Load a sprite image for a Pokemon
-- Options: back (bool), shiny (bool)
-- Returns: image, needsFlip
function spriteLoader.loadSprite(num, options)
    options = options or {}
    local cacheKey = num .. "_" .. (options.back and "b" or "") .. (options.shiny and "s" or "")
    
    -- Check cache
    if cache[cacheKey] then
        return cache[cacheKey], flipCache[cacheKey] or false
    end
    
    -- Get path
    local path, needsFlip = spriteLoader.getSpritePath(num, options)
    if not path then
        debugLog("No path found for Pokemon #" .. num)
        return nil, false
    end
    
    -- Load image
    local success, image = pcall(love.graphics.newImage, path)
    if success and image then
        debugLog("Loaded sprite for #" .. num .. " from " .. path .. (needsFlip and " (flipped)" or ""))
        cache[cacheKey] = image
        flipCache[cacheKey] = needsFlip
        return image, needsFlip
    else
        debugLog("Failed to load image: " .. tostring(image))
        return nil, false
    end
end

-- Get sprite for a Pokemon instance (from pokemonBuilder)
-- Returns: image, needsFlip
function spriteLoader.getSpriteForPokemon(pokemon, options)
    if not pokemon then
        debugLog("getSpriteForPokemon: pokemon is nil")
        return nil, false
    end
    if not pokemon.num then
        debugLog("getSpriteForPokemon: pokemon.num is nil, name=" .. (pokemon.name or "?"))
        return nil, false
    end
    debugLog("getSpriteForPokemon: " .. pokemon.name .. " #" .. pokemon.num)
    return spriteLoader.loadSprite(pokemon.num, options)
end

-- Clear the cache
function spriteLoader.clearCache()
    cache = {}
    flipCache = {}
end

-- Get cache stats
function spriteLoader.getCacheStats()
    local count = 0
    for _ in pairs(cache) do
        count = count + 1
    end
    return { count = count }
end

-- Draw a Pokemon sprite centered at position
-- scale: base scale factor
-- options.maxSize: maximum width/height in pixels (will scale down to fit)
-- options.back: use back sprite (or flipped front as fallback)
-- options.alpha: opacity (0-1, default 1)
function spriteLoader.drawSprite(pokemon, x, y, scale, options)
    scale = scale or 1
    options = options or {}
    local maxSize = options.maxSize or 80  -- Default max size
    local alpha = options.alpha or 1
    
    local sprite, needsFlip = spriteLoader.getSpriteForPokemon(pokemon, options)
    
    if sprite then
        local w, h = sprite:getDimensions()
        
        -- Calculate scale to fit within maxSize
        local fitScale = 1
        local maxDim = math.max(w, h)
        if maxDim > maxSize then
            fitScale = maxSize / maxDim
        end
        
        local finalScale = scale * fitScale
        local finalW = w * finalScale
        local finalH = h * finalScale
        
        -- Center the sprite at x, y with alpha
        love.graphics.setColor(1, 1, 1, alpha)
        
        if needsFlip then
            -- Flip horizontally: negative X scale, adjust position
            love.graphics.draw(sprite, x + finalW / 2, y - finalH / 2, 0, -finalScale, finalScale)
        else
            love.graphics.draw(sprite, x - finalW / 2, y - finalH / 2, 0, finalScale, finalScale)
        end
        return true
    else
        -- Fallback: draw placeholder
        spriteLoader.drawPlaceholder(pokemon, x, y, scale, options)
        return false
    end
end

-- Draw a placeholder when sprite isn't available
function spriteLoader.drawPlaceholder(pokemon, x, y, scale, options)
    local size = 96 * scale
    local halfSize = size / 2
    
    -- Draw a colored circle based on primary type
    local typeColors = {
        Normal = {0.66, 0.66, 0.47},
        Fire = {0.93, 0.51, 0.19},
        Water = {0.39, 0.56, 0.94},
        Electric = {0.97, 0.82, 0.17},
        Grass = {0.47, 0.78, 0.30},
        Ice = {0.59, 0.85, 0.84},
        Fighting = {0.76, 0.18, 0.16},
        Poison = {0.64, 0.24, 0.63},
        Ground = {0.89, 0.75, 0.40},
        Flying = {0.66, 0.56, 0.95},
        Psychic = {0.98, 0.33, 0.53},
        Bug = {0.65, 0.73, 0.10},
        Rock = {0.72, 0.63, 0.21},
        Ghost = {0.45, 0.34, 0.60},
        Dragon = {0.44, 0.21, 0.99},
        Dark = {0.44, 0.34, 0.27},
        Steel = {0.72, 0.72, 0.82},
        Fairy = {0.84, 0.52, 0.68}
    }
    
    local primaryType = pokemon.types and pokemon.types[1] or "Normal"
    local color = typeColors[primaryType] or {0.5, 0.5, 0.5}
    
    -- Draw circle background
    love.graphics.setColor(color[1], color[2], color[3], 0.8)
    love.graphics.circle("fill", x, y, halfSize)
    
    -- Draw border
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", x, y, halfSize)
    
    -- Draw Pokemon number
    if pokemon.num then
        love.graphics.setColor(1, 1, 1)
        local font = love.graphics.newFont(14 * scale)
        love.graphics.setFont(font)
        local numText = "#" .. pokemon.num
        local textW = font:getWidth(numText)
        love.graphics.print(numText, x - textW / 2, y - font:getHeight() / 2)
    end
    
    -- Draw name if fits
    if pokemon.name then
        love.graphics.setColor(1, 1, 1, 0.9)
        local nameFont = love.graphics.newFont(10 * scale)
        love.graphics.setFont(nameFont)
        local shortName = string.sub(pokemon.name, 1, 8)
        local nameW = nameFont:getWidth(shortName)
        love.graphics.print(shortName, x - nameW / 2, y + halfSize - nameFont:getHeight() - 2)
    end
end

-- Draw minisprite (smaller icon version)
function spriteLoader.drawMinisprite(pokemon, x, y, scale)
    scale = scale or 1
    local sprite = spriteLoader.getSpriteForPokemon(pokemon)
    
    if sprite then
        local w, h = sprite:getDimensions()
        local miniScale = scale * 0.5  -- Minisprites are half size
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(sprite, x, y, 0, miniScale, miniScale)
        return w * miniScale, h * miniScale
    else
        -- Draw tiny placeholder
        love.graphics.setColor(0.5, 0.5, 0.5, 0.8)
        love.graphics.rectangle("fill", x, y, 40 * scale, 30 * scale, 4, 4)
        love.graphics.setColor(1, 1, 1)
        if pokemon.num then
            local font = love.graphics.newFont(10)
            love.graphics.setFont(font)
            love.graphics.print("#" .. pokemon.num, x + 2, y + 8)
        end
        return 40 * scale, 30 * scale
    end
end

return spriteLoader

