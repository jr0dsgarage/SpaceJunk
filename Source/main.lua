--- Main entry point for SpaceJunk Playdate game.
-- Sets up global modules, scenes, and the main update loop.

import "Corelibs/object"
import "Corelibs/graphics"
import "Corelibs/sprites"
import "Corelibs/timer"
import "Corelibs/ui"

-- Attach all modules to _G for global access
-- Import ui functions and sprites
_G.ui = import "ui/ui.lua"
_G.BeamSprite = import "ui/beam_sprite.lua"
_G.ScorePopups = import "ui/score_popup.lua"
_G.CrankIndicatorSprite = import "ui/crank_indicator_sprite.lua"
_G.drawBanner = import "ui/drawBanner.lua"

-- Import game utilities
_G.SoundManager = import "audio/sound_manager.lua"
_G.HighScores = import "io/highscores.lua"

-- Import graphics functions and sprite loaders
_G.FlyingObjectSpawner = import "graphics/flying_object_spawner.lua"
_G.FlyingObjectSprite = import "graphics/flying_object.lua"
_G.Starfield = import "graphics/starfield.lua"
_G.spriteLoader = import "graphics/spriteload.lua"
_G.PaperBG = import("graphics/paper")
_G.BackgroundSprite = import "graphics/background_sprite.lua"
_G.CracksSprite = import "graphics/cracks_sprite.lua"
_G.BeamZoomSprite = import "graphics/beam_zoom_sprite.lua"
_G.CrtOverlay = import "graphics/crt_overlay.lua"

-- Import scene management and scenes
local scene_manager = import "scenes/scene_manager"
local menu_scene = import "scenes/menu_scene"
local game_scene = import "scenes/game_scene"
local score_scene = import "scenes/score_scene"
local highscore_scene = import "scenes/highscore_scene"
local slide_transition_scene = import "scenes/slide_transition_scene"
local instructions_scene = import "scenes/instructions_scene"

-- Make menu scenes global for transition scene usage
_G.scene_manager = scene_manager
_G.slide_transition_scene = slide_transition_scene
_G.menu_scene = menu_scene
_G.highscore_scene = highscore_scene
_G.instructions_scene = instructions_scene

-- Initialize the starfield
_G.sharedStarfield = _G.Starfield.new()
-- Start with the menu scene
scene_manager.setScene(menu_scene)

--- Main update loop for Playdate system.
function playdate.update()
    scene_manager.update()
    scene_manager.draw()
    
    if scene_manager.usesSprites() then
        playdate.graphics.sprite.update()
    end

    playdate.timer.updateTimers()
end

function playdate.AButtonDown()
    scene_manager.AButtonDown()
end

function playdate.BButtonDown()
    scene_manager.BButtonDown()
end

function playdate.rightButtonDown()
    scene_manager.rightButtonDown()
end

function playdate.leftButtonDown()
    scene_manager.leftButtonDown()
end

function _G.switchToGameScene()
    scene_manager.setScene(game_scene)
end

function _G.switchToMenuScene()
    scene_manager.setScene(menu_scene)
end

function _G.switchToScoreScene(score, caught, missed)
    scene_manager.setScene(score_scene, score, caught, missed)
end

function _G.switchToHighScoreScene()
    scene_manager.setScene(highscore_scene)
end


