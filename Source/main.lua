import "Corelibs/object"
import "Corelibs/graphics"
import "Corelibs/sprites"
import "Corelibs/timer"
import "Corelibs/ui"

-- Global screen dimensions
_G.SCREEN_WIDTH, _G.SCREEN_HEIGHT = playdate.display.getWidth(), playdate.display.getHeight()

-- Global z-indexes for layering
_G.ZINDEX = {
    BACKGROUND = -100,
    FLYING_OBJECT_BASE = 100, -- flying objects will be 100 + i
    SCOREBOARD = 9999,
    CRANK_INDICATOR = 10000,
    CRACKS = 5000,
}

-- Global constants for game dimensions
_G.TIMERBAR_HEIGHT = 16
_G.SCOREBOARD_HEIGHT = 42

-- Attach all modules to _G for global access
_G.ui = import "ui/ui.lua"
_G.BeamSprite = import "ui/beam_sprite.lua"
_G.ScorePopups = import "ui/score_popup.lua"
_G.CrankIndicatorSprite = import "ui/crank_indicator_sprite.lua"
_G.Starfield = import "graphics/starfield.lua"
_G.FlyingObjectSpawner = import "graphics/flying_object_spawner.lua"
_G.FlyingObjectSprite = import "graphics/flying_object.lua"
_G.SoundManager = import "audio/sound_manager.lua"
_G.HighScores = import "highscores.lua"
_G.drawBanner = import "ui/drawBanner.lua"


-- Import scene management and scenes
local scene_manager = import "scenes/scene_manager"
local menu_scene = import "scenes/menu_scene"
local game_scene = import "scenes/game_scene"
local score_scene = import "scenes/score_scene"
local highscore_scene = import "scenes/highscore_scene.lua"

function playdate.update()
    scene_manager.update()
    scene_manager.draw()
    if scene_manager.usesSprites and scene_manager.usesSprites() then
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

function _G.switchToHighScoreScene()
    scene_manager.setScene(highscore_scene)
end

