-- Magepunk Experimental
-- Main entry point

-- Scene management
local currentScene = nil
local scenes = {}

function love.load()
    -- Set up window
    love.window.setTitle("Magepunk Experimental")
    love.window.setMode(1280, 720, {
        resizable = true,
        minwidth = 800,
        minheight = 600
    })
    
    -- Initialize sprite loader (for debugging file access)
    local spriteLoader = require("data.monster.spriteLoader")
    spriteLoader.init()
    
    -- Load scenes
    scenes.splash = require("scenes.splash")
    scenes.game = require("scenes.game")
    scenes.battlecards_menu = require("scenes.battlecards_menu")
    scenes.battlecards = require("scenes.battlecards")
    scenes.deck_editor = require("scenes.deck_editor")
    scenes.collection = require("scenes.collection")
    
    -- Monster Battle scenes
    scenes.monster_menu = require("scenes.monster_menu")
    scenes.monster_draft = require("scenes.monster_draft")
    scenes.monster_battle = require("scenes.monster_battle")
    scenes.monster_heal = require("scenes.monster_heal")
    
    -- Micatro scene (visual demo)
    scenes.micatro = require("scenes.micatro")
    
    -- Micatro full game scenes
    scenes.micatro_menu = require("micatro.scenes.main_menu")
    scenes.micatro_play = require("micatro.scenes.play")
    scenes.micatro_shop = require("micatro.scenes.shop")
    scenes.micatro_blind_select = require("micatro.scenes.blind_select")
    scenes.micatro_pack = require("micatro.scenes.pack")
    
    -- Initialize all scenes
    for name, scene in pairs(scenes) do
        if scene.load then
            scene.load()
        end
    end
    
    -- Start with splash screen
    switchScene("splash")
end

function switchScene(sceneName)
    if currentScene and currentScene.exit then
        currentScene.exit()
    end
    
    currentScene = scenes[sceneName]
    
    if currentScene and currentScene.enter then
        currentScene.enter()
    end
end

function love.update(dt)
    if currentScene and currentScene.update then
        currentScene.update(dt)
    end
end

function love.draw()
    if currentScene and currentScene.draw then
        currentScene.draw()
    end
end

function love.mousepressed(x, y, button)
    if currentScene and currentScene.mousepressed then
        currentScene.mousepressed(x, y, button)
    end
end

function love.mousereleased(x, y, button)
    if currentScene and currentScene.mousereleased then
        currentScene.mousereleased(x, y, button)
    end
end

function love.mousemoved(x, y, dx, dy)
    if currentScene and currentScene.mousemoved then
        currentScene.mousemoved(x, y, dx, dy)
    end
end

function love.keypressed(key)
    if currentScene and currentScene.keypressed then
        currentScene.keypressed(key)
    end
end

function love.resize(w, h)
    if currentScene and currentScene.resize then
        currentScene.resize(w, h)
    end
end

function love.wheelmoved(x, y)
    if currentScene and currentScene.wheelmoved then
        currentScene.wheelmoved(x, y)
    end
end

