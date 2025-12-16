-- Card Renderer
-- Handles rendering cards with sprites, shaders and effects

local Card = require("micatro.core.card")
local Sprites = require("micatro.core.sprites")

local CardRender = {}

-- Shaders cache
local shaders = {}
local shadersLoaded = false

-- Card dimensions
local CARD_WIDTH = 71
local CARD_HEIGHT = 95

-- Load shaders
function CardRender.loadShaders()
    if shadersLoaded then return end
    
    local shaderFiles = {
        foil = "assets/shaders/foil.glsl",
        holographic = "assets/shaders/holo.glsl",
        polychrome = "assets/shaders/polychrome.glsl",
        negative = "assets/shaders/negative.glsl",
        dissolve = "assets/shaders/dissolve.glsl",
        flash = "assets/shaders/flash.glsl"
    }
    
    -- Also try the original shaders folder
    local fallbackPaths = {
        foil = "shaders/foil.glsl",
        holographic = "shaders/holographic.glsl",
        polychrome = "shaders/polychrome.glsl",
        negative = "shaders/negative.glsl"
    }
    
    for name, path in pairs(shaderFiles) do
        local code = love.filesystem.read(path)
        if not code and fallbackPaths[name] then
            code = love.filesystem.read(fallbackPaths[name])
        end
        if code then
            local success, shader = pcall(love.graphics.newShader, code)
            if success then
                shaders[name] = shader
            end
        end
    end
    
    shadersLoaded = true
end

-- Load sprites
function CardRender.loadSprites()
    Sprites.load()
end

-- Get shader for edition
function CardRender.getShader(editionKey)
    if not editionKey then return nil end
    
    local shaderMap = {
        e_foil = "foil",
        e_holo = "holographic",
        e_polychrome = "polychrome",
        e_negative = "negative"
    }
    
    local shaderName = shaderMap[editionKey]
    if shaderName then
        return shaders[shaderName]
    end
    return nil
end

-- Safe shader uniform send
local function safeSend(shader, name, value)
    if shader and shader:hasUniform(name) then
        pcall(shader.send, shader, name, value)
    end
end

-- Draw a playing card with actual sprites
function CardRender.drawPlayingCard(card, x, y, width, height, time)
    width = width or CARD_WIDTH
    height = height or CARD_HEIGHT
    time = time or 0
    
    -- Get the card sprite
    local quad, image = Sprites.getPlayingCardQuad(card.rank, card.suit)
    
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(card.rotation or 0)
    love.graphics.scale(card.scale or 1, card.scale or 1)
    love.graphics.shear((card.rotationY or 0) * 0.1, (card.rotationX or 0) * 0.1)
    
    -- Calculate scale to fit desired size
    local scaleX = width / CARD_WIDTH
    local scaleY = height / CARD_HEIGHT
    
    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", -width/2 + 3, -height/2 + 3, width, height, 6)
    
    -- White card background
    if card.selected then
        love.graphics.setColor(0.9, 0.95, 1, card.alpha or 1)
    elseif card.highlighting then
        love.graphics.setColor(1, 1, 0.9, card.alpha or 1)
    else
        love.graphics.setColor(1, 1, 1, card.alpha or 1)
    end
    love.graphics.rectangle("fill", -width/2, -height/2, width, height, 6)
    
    -- Card border
    love.graphics.setColor(0.7, 0.7, 0.75, card.alpha or 1)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", -width/2, -height/2, width, height, 6)
    
    -- Draw base layer enhancements FIRST (gold, steel, stone - these replace the card background)
    if card.enhancement and (card.enhancement == "m_gold" or card.enhancement == "m_steel" or card.enhancement == "m_stone") then
        CardRender.drawEnhancementOverlay(card.enhancement, width, height, true)  -- true = base layer
    end
    
    -- Apply edition shader if present
    local shader = CardRender.getShader(card.edition)
    if shader then
        safeSend(shader, "iTime", time)
        safeSend(shader, "uRotation", {card.rotationY or 0, -(card.rotationX or 0)})
        love.graphics.setShader(shader)
    end
    
    -- Draw the card sprite (numbers and symbols)
    if quad and image then
        love.graphics.setColor(1, 1, 1, card.alpha or 1)
        love.graphics.draw(image, quad, -width/2, -height/2, 0, scaleX, scaleY)
    else
        -- Fallback: draw a placeholder if sprite not available
        CardRender.drawPlayingCardFallback(card, width, height)
    end
    
    love.graphics.setShader()
    
    -- Draw overlay enhancements AFTER card sprite (glass, bonus, mult - these go on top)
    if card.enhancement and (card.enhancement == "m_glass" or card.enhancement == "m_bonus" or card.enhancement == "m_mult" or card.enhancement == "m_wild" or card.enhancement == "m_lucky") then
        CardRender.drawEnhancementOverlay(card.enhancement, width, height, false)  -- false = overlay
    end
    
    -- Draw seal
    if card.seal then
        CardRender.drawSeal(card.seal, width, height)
    end
    
    -- Selection border
    if card.selected then
        love.graphics.setColor(0.3, 0.5, 1, 1)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", -width/2, -height/2, width, height, 6)
    end
    
    love.graphics.pop()
end

-- Fallback rendering when sprites aren't loaded
function CardRender.drawPlayingCardFallback(card, width, height)
    -- Card background
    love.graphics.setColor(1, 1, 1, card.alpha or 1)
    love.graphics.rectangle("fill", -width/2, -height/2, width, height, 6)
    
    -- Border
    love.graphics.setColor(0.4, 0.4, 0.5, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", -width/2, -height/2, width, height, 6)
    
    -- Suit color
    local isRed = card.suit == "Hearts" or card.suit == "Diamonds"
    if isRed then
        love.graphics.setColor(0.85, 0.15, 0.15, 1)
    else
        love.graphics.setColor(0.1, 0.1, 0.1, 1)
    end
    
    -- Rank
    local rankFont = love.graphics.newFont(18)
    love.graphics.setFont(rankFont)
    love.graphics.printf(card.rank or "?", -width/2, -height/2 + 8, width, "center")
    
    -- Suit symbol
    local suitSymbols = {
        Hearts = "♥",
        Diamonds = "♦",
        Clubs = "♣",
        Spades = "♠"
    }
    local suitFont = love.graphics.newFont(28)
    love.graphics.setFont(suitFont)
    love.graphics.printf(suitSymbols[card.suit] or "?", -width/2, -5, width, "center")
end

-- Draw enhancement overlay
-- isBaseLayer: true for base layers (gold, steel, stone), false for overlays (glass, bonus, mult)
function CardRender.drawEnhancementOverlay(enhancement, width, height, isBaseLayer)
    isBaseLayer = isBaseLayer or false
    local quad, image = Sprites.getEnhancementQuad(enhancement)
    
    if quad and image then
        local scaleX = width / CARD_WIDTH
        local scaleY = height / CARD_HEIGHT
        
        -- Set opacity based on enhancement type and layer type
        local opacity = 1.0
        if isBaseLayer then
            -- Base layers (gold, steel, stone) are fully opaque
            opacity = 1.0
        else
            -- Overlays have different opacities and blend modes
            if enhancement == "m_glass" then
                opacity = 0.8  -- Glass overlay should be visible but not completely opaque
            elseif enhancement == "m_bonus" then
                -- Bonus cards should be a subtle overlay that doesn't obscure the card
                opacity = 0.25  -- Very transparent so card details remain clear
            elseif enhancement == "m_mult" then
                opacity = 0.4  -- Mult overlay is semi-transparent
            else
                opacity = 0.7  -- Default for other overlays
            end
        end
        
        -- Use multiply blend mode for bonus/mult to avoid making card opaque
        if enhancement == "m_bonus" or enhancement == "m_mult" then
            love.graphics.setBlendMode("multiply", "premultiplied")
        end
        
        love.graphics.setColor(1, 1, 1, opacity)
        love.graphics.draw(image, quad, -width/2, -height/2, 0, scaleX, scaleY)
        
        -- Reset blend mode
        if enhancement == "m_bonus" or enhancement == "m_mult" then
            love.graphics.setBlendMode("alpha")
        end
    else
        -- Fallback: colored indicator
        local enhColors = {
            m_bonus = {0.3, 0.5, 0.9, 0.4},
            m_mult = {0.9, 0.3, 0.3, 0.4},
            m_wild = {0.9, 0.6, 0.2, 0.4},
            m_glass = {0.6, 0.8, 0.95, 0.3},
            m_steel = {0.7, 0.7, 0.8, 0.4},
            m_stone = {0.5, 0.4, 0.35, 0.5},
            m_gold = {1, 0.85, 0.3, 0.4},  -- Gold should be yellow/golden
            m_lucky = {0.3, 0.8, 0.4, 0.4}
        }
        local col = enhColors[enhancement]
        if col then
            local alpha = isBaseLayer and col[4] or (col[4] * 0.7)  -- Overlays are more transparent
            love.graphics.setColor(col[1], col[2], col[3], alpha)
            love.graphics.rectangle("fill", -width/2 + 3, -height/2 + 3, width - 6, height - 6, 4)
        end
    end
end

-- Draw seal on card
function CardRender.drawSeal(seal, width, height)
    local quad, image = Sprites.getSealQuad(seal)
    
    if quad and image then
        local scaleX = width / CARD_WIDTH
        local scaleY = height / CARD_HEIGHT
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.draw(image, quad, -width/2, -height/2, 0, scaleX, scaleY)
    else
        -- Fallback: colored circle
        local sealColors = {
            Gold = {1, 0.85, 0.3},
            Red = {1, 0.3, 0.3},
            Blue = {0.3, 0.5, 1},
            Purple = {0.7, 0.3, 0.9}
        }
        local col = sealColors[seal] or {1, 1, 1}
        love.graphics.setColor(col[1], col[2], col[3], 0.9)
        love.graphics.circle("fill", -width/2 + 12, height/2 - 12, 8)
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.setLineWidth(2)
        love.graphics.circle("line", -width/2 + 12, height/2 - 12, 8)
    end
end

-- Draw a joker card with sprite
function CardRender.drawJokerCard(card, x, y, width, height, time)
    width = width or CARD_WIDTH
    height = height or CARD_HEIGHT
    time = time or 0
    
    -- Get joker position from data
    local posX, posY = 0, 0
    if card.data and card.data.pos then
        posX = card.data.pos.x or 0
        posY = card.data.pos.y or 0
    end
    
    local quad, image = Sprites.getJokerQuad(posX, posY)
    
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(card.rotation or 0)
    love.graphics.scale(card.scale or 1, card.scale or 1)
    love.graphics.shear((card.rotationY or 0) * 0.1, (card.rotationX or 0) * 0.1)
    
    local scaleX = width / CARD_WIDTH
    local scaleY = height / CARD_HEIGHT
    
    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", -width/2 + 3, -height/2 + 3, width, height, 6)
    
    -- Apply edition shader
    local shader = CardRender.getShader(card.edition)
    if shader then
        safeSend(shader, "iTime", time)
        safeSend(shader, "uRotation", {card.rotationY or 0, -(card.rotationX or 0)})
        love.graphics.setShader(shader)
    end
    
    if quad and image then
        -- Trigger highlight
        if card.triggering then
            love.graphics.setColor(1, 1, 0.8, card.alpha or 1)
        else
            love.graphics.setColor(1, 1, 1, card.alpha or 1)
        end
        love.graphics.draw(image, quad, -width/2, -height/2, 0, scaleX, scaleY)
    else
        -- Fallback
        CardRender.drawJokerCardFallback(card, width, height)
    end
    
    love.graphics.setShader()
    love.graphics.pop()
end

-- Fallback joker rendering
function CardRender.drawJokerCardFallback(card, width, height)
    love.graphics.setColor(0.95, 0.95, 0.98, card.alpha or 1)
    love.graphics.rectangle("fill", -width/2, -height/2, width, height, 6)
    
    -- Rarity color
    local rarityColors = {
        {0.5, 0.6, 0.7, 0.3},
        {0.3, 0.7, 0.4, 0.3},
        {0.8, 0.3, 0.3, 0.3},
        {0.7, 0.4, 0.9, 0.4}
    }
    local rarity = card.data and card.data.rarity or 1
    local col = rarityColors[rarity] or rarityColors[1]
    love.graphics.setColor(col[1], col[2], col[3], col[4])
    love.graphics.rectangle("fill", -width/2 + 5, -5, width - 10, 25, 4)
    
    -- Border
    love.graphics.setColor(0.4, 0.4, 0.5, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", -width/2, -height/2, width, height, 6)
    
    -- Name
    love.graphics.setColor(0.2, 0.2, 0.3, 1)
    local nameFont = love.graphics.newFont(11)
    love.graphics.setFont(nameFont)
    local name = card.data and card.data.name or "Joker"
    love.graphics.printf(name, -width/2 + 2, -height/2 + 8, width - 4, "center")
end

-- Draw a consumable card (tarot/planet/spectral)
function CardRender.drawConsumableCard(card, x, y, width, height, time)
    width = width or CARD_WIDTH * 0.9
    height = height or CARD_HEIGHT * 0.9
    time = time or 0
    
    -- Get position from data
    local posX, posY = 0, 0
    if card.data and card.data.pos then
        posX = card.data.pos.x or 0
        posY = card.data.pos.y or 0
    end
    
    local quad, image = Sprites.getTarotQuad(posX, posY)
    
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(card.rotation or 0)
    love.graphics.scale(card.scale or 1, card.scale or 1)
    love.graphics.shear((card.rotationY or 0) * 0.1, (card.rotationX or 0) * 0.1)
    
    local scaleX = width / CARD_WIDTH
    local scaleY = height / CARD_HEIGHT
    
    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", -width/2 + 3, -height/2 + 3, width, height, 6)
    
    -- Apply edition shader if present
    local shader = CardRender.getShader(card.edition)
    if shader then
        safeSend(shader, "iTime", time)
        safeSend(shader, "uRotation", {card.rotationY or 0, -(card.rotationX or 0)})
        love.graphics.setShader(shader)
    end
    
    if quad and image then
        love.graphics.setColor(1, 1, 1, card.alpha or 1)
        love.graphics.draw(image, quad, -width/2, -height/2, 0, scaleX, scaleY)
    else
        -- Fallback
        CardRender.drawConsumableCardFallback(card, width, height)
    end
    
    love.graphics.setShader()
    love.graphics.pop()
end

-- Fallback consumable rendering
function CardRender.drawConsumableCardFallback(card, width, height)
    local typeColors = {
        Tarot = {0.92, 0.85, 0.7},
        Planet = {0.7, 0.8, 0.9},
        Spectral = {0.75, 0.7, 0.9}
    }
    local setType = card.data and card.data.set or "Tarot"
    local bgColor = typeColors[setType] or {0.9, 0.9, 0.9}
    
    love.graphics.setColor(bgColor[1], bgColor[2], bgColor[3], card.alpha or 1)
    love.graphics.rectangle("fill", -width/2, -height/2, width, height, 6)
    
    love.graphics.setColor(0.4, 0.4, 0.5, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", -width/2, -height/2, width, height, 6)
    
    love.graphics.setColor(0.2, 0.2, 0.3, 1)
    local nameFont = love.graphics.newFont(10)
    love.graphics.setFont(nameFont)
    local name = card.data and card.data.name or "Card"
    love.graphics.printf(name, -width/2 + 2, -height/2 + 8, width - 4, "center")
end

-- Draw a voucher
function CardRender.drawVoucherCard(card, x, y, width, height, time)
    width = width or 90
    height = height or 70
    
    local posX, posY = 0, 0
    if card.data and card.data.pos then
        posX = card.data.pos.x or 0
        posY = card.data.pos.y or 0
    end
    
    local quad, image = Sprites.getVoucherQuad(posX, posY)
    
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.scale(card.scale or 1, card.scale or 1)
    
    local scaleX = width / CARD_WIDTH
    local scaleY = height / CARD_HEIGHT
    
    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", -width/2 + 2, -height/2 + 2, width, height, 6)
    
    if quad and image then
        love.graphics.setColor(1, 1, 1, card.alpha or 1)
        love.graphics.draw(image, quad, -width/2, -height/2, 0, scaleX, scaleY)
    else
        -- Fallback
        love.graphics.setColor(0.9, 0.75, 0.4, 1)
        love.graphics.rectangle("fill", -width/2, -height/2, width, height, 6)
        love.graphics.setColor(0.6, 0.5, 0.3, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", -width/2, -height/2, width, height, 6)
    end
    
    love.graphics.pop()
end

-- Draw any card based on type
function CardRender.draw(card, x, y, width, height, time)
    if card.type == Card.TYPE.PLAYING then
        CardRender.drawPlayingCard(card, x, y, width, height, time)
    elseif card.type == Card.TYPE.JOKER then
        CardRender.drawJokerCard(card, x, y, width, height, time)
    elseif card.type == Card.TYPE.VOUCHER then
        CardRender.drawVoucherCard(card, x, y, width, height, time)
    elseif card.type == Card.TYPE.TAROT or card.type == Card.TYPE.PLANET or card.type == Card.TYPE.SPECTRAL then
        CardRender.drawConsumableCard(card, x, y, width, height, time)
    else
        -- Fallback for any other type
        CardRender.drawConsumableCard(card, x, y, width, height, time)
    end
end

return CardRender
