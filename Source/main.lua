import "Corelibs/object"
import "Corelibs/graphics"
import "Corelibs/sprites"
import "Corelibs/timer"
import "Corelibs/ui"

-- Attach all modules to _G for global access
_G.FlyingObjectSprite = import "flying_object.lua"
_G.BeamSprite = import "beam_sprite.lua"
_G.Starfield = import "starfield.lua"
_G.ScorePopups = import "score_popup.lua"
_G.CrankIndicatorSprite = import "crank_indicator_sprite.lua"
_G.SoundManager = import "sound_manager.lua"
_G.FlyingObjectSpawner = import "flying_object_spawner.lua"
_G.ui = import "ui"

-- Import scene management and scenes
local scene_manager = import "scenes/scene_manager"
local menu_scene = import "scenes/menu_scene"
local game_scene = import "scenes/game_scene"
local score_scene = import "scenes/score_scene"

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

function _G.switchToGameScene()
    scene_manager.setScene(game_scene)
end

function _G.switchToMenuScene()
    scene_manager.setScene(menu_scene)
end

function _G.switchToScoreScene(score, caught, missed)
    scene_manager.setScene(score_scene, score, caught, missed)
end

