-- Love2D Configuration

function love.conf(t)
    t.title = "Magepunk Experimental"
    t.version = "11.4"                  -- Love2D version
    
    t.window.width = 1280
    t.window.height = 720
    t.window.minwidth = 800
    t.window.minheight = 600
    t.window.resizable = true
    t.window.vsync = 1
    
    t.console = false                   -- Set to true for debugging
    
    t.modules.audio = true
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = true
    t.modules.sound = true
    t.modules.system = true
    t.modules.thread = true
    t.modules.timer = true
    t.modules.touch = true
    t.modules.video = true
    t.modules.window = true
end

