import "Corelibs/object"
import "Corelibs/graphics"
import "Corelibs/sprites"
import "Corelibs/timer"
import "Corelibs/ui"

-- Global screen dimensions
_G.SCREEN_WIDTH, _G.SCREEN_HEIGHT = playdate.display.getWidth(), playdate.display.getHeight()

-- Global z-indexes for layering
_G.ZINDEX = {
    STARFIELD = 0,           -- starfield is always at the bottom
    FLYING_OBJECT_BASE = 50, -- flying objects will be 50 + i
    BEAM = 100,              -- beam and related effects
    SHIP_IMAGE = 5000,         -- background image below flying objects and beam
    SCOREBOARD = 9999,
    CRANK_INDICATOR = 10000,
    CRACKS = 500,
}

_G.SHIP_IMAGE_PATH = "sprites/ui/background_ship.png"

-- Global constants for game dimensions
_G.TIMERBAR_HEIGHT = 16
_G.SCOREBOARD_HEIGHT = 42

-- Shared layout constants
_G.INSTR_LEFT_X = 0
_G.INSTR_RIGHT_X = _G.SCREEN_WIDTH
_G.INSTR_Y = _G.SCREEN_HEIGHT - 20

-- Attach all modules to _G for global access
_G.ui = import "ui/ui.lua"
_G.BeamSprite = import "ui/beam_sprite.lua"
_G.ScorePopups = import "ui/score_popup.lua"
_G.CrankIndicatorSprite = import "ui/crank_indicator_sprite.lua"
_G.Starfield = import "graphics/starfield.lua"
_G.FlyingObjectSpawner = import "graphics/flying_object_spawner.lua"
_G.FlyingObjectSprite = import "graphics/flying_object.lua"
_G.SoundManager = import "audio/sound_manager.lua"
_G.HighScores = import "io/highscores.lua"
_G.drawBanner = import "ui/drawBanner.lua"
_G.spriteLoader = import "graphics/spriteload.lua"
_G.PaperBG = import("graphics/paper")
_G.BackgroundSprite = import "graphics/background_sprite.lua"
_G.CracksSprite = import "graphics/cracks_sprite.lua"
_G.BeamZoomSprite = import "graphics/beam_zoom_sprite.lua"

-- Import scene management and scenes
local scene_manager = import "scenes/scene_manager"
local menu_scene = import "scenes/menu_scene"
local game_scene = import "scenes/game_scene"
local score_scene = import "scenes/score_scene"
local highscore_scene = import "scenes/highscore_scene.lua"
local slide_transition_scene = import "scenes/slide_transition_scene.lua"
local instructions_scene = import "scenes/instructions_scene.lua"

-- Make scenes global for transition scene usage
_G.scene_manager = scene_manager
_G.slide_transition_scene = slide_transition_scene
_G.menu_scene = menu_scene
_G.highscore_scene = highscore_scene
_G.instructions_scene = instructions_scene


-- Initialize the playdate system
function playdate.init()
    playdate.display.setRefreshRate(30)
    playdate.display.setScale(2)

    -- Initialize the starfield
    _G.sharedStarfield = _G.Starfield.new()

    -- Initialize the sound manager
    _G.SoundManager.init()

    -- Initialize the high scores
    _G.HighScores.init()

    -- Set up the scene manager
    scene_manager.init()
end

-- Update and draw functions for the playdate system
function playdate.update()
    scene_manager.update()
    scene_manager.draw()

        playdate.graphics.sprite.update()

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


