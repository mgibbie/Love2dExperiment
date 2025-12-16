-- Micatro Module Loader
-- Convenience module to load all Micatro components

local M = {}

-- Core modules
M.GameState = require("micatro.core.game_state")
M.Events = require("micatro.core.events")
M.Scoring = require("micatro.core.scoring")
M.Card = require("micatro.core.card")
M.CardArea = require("micatro.core.card_area")
M.JokerEffects = require("micatro.core.joker_effects")
M.ConsumableEffects = require("micatro.core.consumable_effects")
M.Sound = require("micatro.core.sound")
M.Animation = require("micatro.core.animation")
M.Sprites = require("micatro.core.sprites")

-- Data modules
M.Data = {
    Jokers = require("micatro.data.jokers"),
    Tarots = require("micatro.data.tarots"),
    Planets = require("micatro.data.planets"),
    Spectrals = require("micatro.data.spectrals"),
    Vouchers = require("micatro.data.vouchers"),
    Decks = require("micatro.data.decks"),
    Blinds = require("micatro.data.blinds"),
    Hands = require("micatro.data.hands"),
    Enhancements = require("micatro.data.enhancements"),
    Editions = require("micatro.data.editions"),
    Seals = require("micatro.data.seals")
}

-- UI modules
M.UI = {
    Button = require("micatro.ui.button"),
    Tooltip = require("micatro.ui.tooltip"),
    ScoreDisplay = require("micatro.ui.score_display"),
    CardRender = require("micatro.ui.card_render")
}

-- Version
M.VERSION = "0.1.0"
M.NAME = "Micatro"
M.DESCRIPTION = "A Balatro Clone"

-- Initialize all systems
function M.init()
    -- Initialize sprite system
    M.Sprites.load()
    
    -- Initialize sound system
    M.Sound.init()
    
    -- Load card render shaders and sprites
    M.UI.CardRender.loadShaders()
    M.UI.CardRender.loadSprites()
    
    print(M.NAME .. " v" .. M.VERSION .. " initialized")
end

-- Get a summary of all content
function M.getContentSummary()
    local decks = M.Data.Decks.getAll()
    local blinds = require("micatro.data.blinds")
    
    local blindCount = 0
    for _ in pairs(blinds.BLINDS) do blindCount = blindCount + 1 end
    
    local deckCount = 0
    for _ in pairs(decks) do deckCount = deckCount + 1 end
    
    return {
        jokers = M.Data.Jokers.count(),
        tarots = M.Data.Tarots.count(),
        planets = M.Data.Planets.count(),
        spectrals = M.Data.Spectrals.count(),
        vouchers = M.Data.Vouchers.count(),
        decks = deckCount,
        blinds = blindCount,
        enhancements = 8,
        editions = 5,
        seals = 4,
        hands = 12
    }
end

-- Print content summary
function M.printContentSummary()
    local summary = M.getContentSummary()
    print("=== " .. M.NAME .. " Content ===")
    print("Jokers: " .. summary.jokers)
    print("Tarot Cards: " .. summary.tarots)
    print("Planet Cards: " .. summary.planets)
    print("Spectral Cards: " .. summary.spectrals)
    print("Vouchers: " .. summary.vouchers)
    print("Decks: " .. summary.decks)
    print("Blinds: " .. summary.blinds)
    print("Enhancements: " .. summary.enhancements)
    print("Editions: " .. summary.editions)
    print("Seals: " .. summary.seals)
    print("Hand Types: " .. summary.hands)
    print("===========================")
end

return M

