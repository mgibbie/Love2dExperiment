-- Sprite Atlas System
-- Manages sprite sheets and provides quads for rendering

local M = {}

-- Atlas definitions with tile sizes
M.atlases = {
    cards = {
        path = "assets/sprites/cards.png",
        tileW = 71,
        tileH = 95,
        image = nil,
        quads = {}
    },
    jokers = {
        path = "assets/sprites/jokers.png",
        tileW = 71,
        tileH = 95,
        image = nil,
        quads = {}
    },
    tarots = {
        path = "assets/sprites/tarots.png",
        tileW = 71,
        tileH = 95,
        image = nil,
        quads = {}
    },
    vouchers = {
        path = "assets/sprites/vouchers.png",
        tileW = 71,
        tileH = 95,
        image = nil,
        quads = {}
    },
    enhancers = {
        path = "assets/sprites/enhancers.png",
        tileW = 71,
        tileH = 95,
        image = nil,
        quads = {}
    },
    boosters = {
        path = "assets/sprites/boosters.png",
        tileW = 71,
        tileH = 95,
        image = nil,
        quads = {}
    },
    blinds = {
        path = "assets/sprites/blinds.png",
        tileW = 34,
        tileH = 34,
        image = nil,
        quads = {}
    },
    stickers = {
        path = "assets/sprites/stickers.png",
        tileW = 71,
        tileH = 95,
        image = nil,
        quads = {}
    }
}

-- Playing card positions in cards.png
-- Layout: 4 rows (Hearts, Clubs, Diamonds, Spades), 13 columns (2-10, J, Q, K, A)
M.SUIT_ROWS = {
    Hearts = 0,
    Clubs = 1,
    Diamonds = 2,
    Spades = 3
}

M.RANK_COLS = {
    ["2"] = 0, ["3"] = 1, ["4"] = 2, ["5"] = 3, ["6"] = 4,
    ["7"] = 5, ["8"] = 6, ["9"] = 7, ["10"] = 8,
    ["J"] = 9, ["Q"] = 10, ["K"] = 11, ["A"] = 12
}

-- Enhancement positions in enhancers.png
-- Note: These positions are 0-indexed (x=0 is first column, y=0 is first row)
-- Positions should match the enhancement data definitions
M.ENHANCEMENT_POS = {
    m_bonus = {x = 1, y = 1},    -- Red/Bonus card overlay (from enhancement data)
    m_mult = {x = 2, y = 1},     -- Mult card (from enhancement data)
    m_wild = {x = 3, y = 1},     -- Wild card (from enhancement data)
    m_glass = {x = 5, y = 1},    -- Glass/cracked overlay (from enhancement data)
    m_steel = {x = 6, y = 1},    -- Steel/metallic (from enhancement data)
    m_stone = {x = 5, y = 0},    -- Stone card (from enhancement data: pos = {x = 5, y = 0})
    m_gold = {x = 6, y = 0},     -- Gold card (from enhancement data: pos = {x = 6, y = 0})
    m_lucky = {x = 4, y = 1}     -- Lucky clover (from enhancement data)
}

-- Seal positions (in enhancers.png)
M.SEAL_POS = {
    Gold = {x = 2, y = 0},
    Purple = {x = 4, y = 4},
    Red = {x = 5, y = 4},
    Blue = {x = 6, y = 4}
}

-- Card back positions (deck colors in enhancers.png)
M.DECK_BACK_POS = {
    red = {x = 0, y = 2},
    blue = {x = 1, y = 2},
    yellow = {x = 2, y = 2},
    green = {x = 3, y = 2},
    black = {x = 4, y = 2},
    magic = {x = 5, y = 2},
    nebula = {x = 6, y = 2}
}

-- Loaded state
local loaded = false

-- Load all atlases
function M.load()
    if loaded then return end
    
    for name, atlas in pairs(M.atlases) do
        local success, result = pcall(function()
            if love.filesystem.getInfo(atlas.path) then
                atlas.image = love.graphics.newImage(atlas.path)
                atlas.image:setFilter("nearest", "nearest")
                return true
            end
            return false
        end)
        
        if not success or not result then
            print("Warning: Could not load atlas: " .. atlas.path)
        end
    end
    
    loaded = true
end

-- Get or create a quad for a specific tile position
function M.getQuad(atlasName, posX, posY)
    local atlas = M.atlases[atlasName]
    if not atlas or not atlas.image then
        return nil
    end
    
    -- Create cache key
    local key = posX .. "_" .. posY
    
    -- Return cached quad if exists
    if atlas.quads[key] then
        return atlas.quads[key], atlas.image
    end
    
    -- Create new quad
    local imgW, imgH = atlas.image:getDimensions()
    local quad = love.graphics.newQuad(
        posX * atlas.tileW,
        posY * atlas.tileH,
        atlas.tileW,
        atlas.tileH,
        imgW, imgH
    )
    
    atlas.quads[key] = quad
    return quad, atlas.image
end

-- Get quad for a playing card
function M.getPlayingCardQuad(rank, suit)
    local col = M.RANK_COLS[rank]
    local row = M.SUIT_ROWS[suit]
    
    if not col or not row then
        return nil, nil
    end
    
    return M.getQuad("cards", col, row)
end

-- Get quad for a joker by position
function M.getJokerQuad(posX, posY)
    return M.getQuad("jokers", posX, posY)
end

-- Get quad for a tarot/planet/spectral by position
function M.getTarotQuad(posX, posY)
    return M.getQuad("tarots", posX, posY)
end

-- Get quad for a voucher by position
function M.getVoucherQuad(posX, posY)
    return M.getQuad("vouchers", posX, posY)
end

-- Get quad for an enhancement overlay
function M.getEnhancementQuad(enhancementKey)
    local pos = M.ENHANCEMENT_POS[enhancementKey]
    if not pos then return nil, nil end
    return M.getQuad("enhancers", pos.x, pos.y)
end

-- Get quad for a seal
function M.getSealQuad(sealKey)
    local pos = M.SEAL_POS[sealKey]
    if not pos then return nil, nil end
    return M.getQuad("enhancers", pos.x, pos.y)
end

-- Get quad for a deck back
function M.getDeckBackQuad(deckKey)
    local pos = M.DECK_BACK_POS[deckKey]
    if not pos then 
        pos = M.DECK_BACK_POS.red  -- Default to red
    end
    return M.getQuad("enhancers", pos.x, pos.y)
end

-- Get the atlas image directly
function M.getImage(atlasName)
    local atlas = M.atlases[atlasName]
    if atlas then
        return atlas.image
    end
    return nil
end

-- Get tile dimensions for an atlas
function M.getTileSize(atlasName)
    local atlas = M.atlases[atlasName]
    if atlas then
        return atlas.tileW, atlas.tileH
    end
    return 71, 95  -- Default
end

-- Check if sprites are loaded
function M.isLoaded()
    return loaded
end

-- Unload all atlases (for cleanup)
function M.unload()
    for name, atlas in pairs(M.atlases) do
        atlas.image = nil
        atlas.quads = {}
    end
    loaded = false
end

return M

