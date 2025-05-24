import "Corelibs/object"
import "Corelibs/graphics"
import "Corelibs/sprites"
import "Corelibs/timer"
import "Corelibs/ui"

_G.ui = import "ui"
local scene_manager = import "scenes/scene_manager"
local menu_scene = import "scenes/menu_scene"
local game_scene = import "scenes/game_scene"

function playdate.update()
    scene_manager.update()
    scene_manager.draw()
    playdate.graphics.sprite.update()
    playdate.timer.updateTimers()
end

function playdate.AButtonDown()
    scene_manager.AButtonDown()
end

-- Start with the menu scene
scene_manager.setScene(menu_scene)

_G.switchToGameScene = function()
    scene_manager.setScene(game_scene)
end