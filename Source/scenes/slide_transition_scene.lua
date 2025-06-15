---
-- Slide transition scene module for animated scene transitions with parallax.
-- Uses global parallax constants and handles direction-based transitions.
-- @module slide_transition_scene
-- @usage
--   local slide_transition_scene = require("scenes.slide_transition_scene")
--   slide_transition_scene:enter(direction)

local gfx <const> = playdate.graphics -- Playdate graphics module
local slide_transition_scene = {} -- Table for slide transition scene methods and state

local DURATION = 0.5 -- Duration of the transition in seconds
local FPS = 30 -- Frames per second for the transition
local TOTAL_FRAMES = math.floor(DURATION * FPS) -- Total frames in the transition

-- Parallax constants (use globals from scene_manager.lua)
local MENU_PARALLAX_X = _G.MENU_PARALLAX_X -- Parallax X for menu scene
local HIGHSCORE_PARALLAX_X = _G.HIGHSCORE_PARALLAX_X -- Parallax X for highscore scene
local INSTRUCTIONS_PARALLAX_X = _G.INSTRUCTIONS_PARALLAX_X -- Parallax X for instructions scene

--- Enter the slide transition scene.
-- @param direction Integer indicating transition direction
function slide_transition_scene:enter(direction)
    self.frame = 0
    self.direction = direction or 1
    self.menu_scene = _G.menu_scene
    self.highscore_scene = _G.highscore_scene
    self.instructions_scene = _G.instructions_scene
    self.starfield = _G.sharedStarfield
    self.width = _G.SCREEN_WIDTH
    self.height = _G.SCREEN_HEIGHT

    -- Map directions to scene pairs for cleaner logic
    local transitions = {
        [-2] = {from = self.menu_scene, to = self.instructions_scene},
        [-3] = {from = self.instructions_scene, to = self.menu_scene},
        [1]  = {from = self.menu_scene, to = self.highscore_scene},
        [-1] = {from = self.highscore_scene, to = self.menu_scene}
    }
    local scene_pair = transitions[self.direction]
    if scene_pair then
        self.fromScene = scene_pair.from
        self.toScene = scene_pair.to
    else
        self.fromScene = self.menu_scene
        self.toScene = self.highscore_scene
    end
end

--- Update the slide transition scene, advancing the frame and checking for scene change.
function slide_transition_scene:update()
    self.frame = self.frame + 1
    if self.frame >= TOTAL_FRAMES then
        local actions = {
            [-2] = function() if _G.scene_manager then _G.scene_manager.setScene(_G.instructions_scene) end end,
            [-3] = function() if _G.scene_manager then _G.scene_manager.setScene(_G.menu_scene) end end,
            [1]  = function() if _G.scene_manager then _G.scene_manager.setScene(_G.highscore_scene) end end,
            [-1] = function() if _G.scene_manager then _G.scene_manager.setScene(_G.menu_scene) end end,
        }
        local action = actions[self.direction]
        if action then action() end
    end
end

--- Draw the slide transition scene, including parallax starfield and scene slides.
function slide_transition_scene:draw()
    local width = self.width or (_G and _G.SCREEN_WIDTH) or 400
    local height = self.height or (_G and _G.SCREEN_HEIGHT) or 240
    local t = math.min((self.frame or 0) / (TOTAL_FRAMES or 1), 1)
    local fromX, toX
    -- Determine slide offsets for scenes
    if self.direction == -2 then -- Menu -> Instructions
        fromX = t * width
        toX = -width + t * width
    elseif self.direction == -3 then -- Instructions -> Menu
        fromX = -t * width
        toX = width - t * width
    elseif self.direction == 1 then -- Menu -> Highscore
        fromX = -t * width
        toX = width - t * width
    elseif self.direction == -1 then -- Highscore -> Menu
        fromX = t * width
        toX = -width + t * width
    else
        fromX = 0
        toX = 0
    end
    -- Always clear the background
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, width, height)
    -- Starfield parallax interpolation (correct direction)
    local fromParallaxX, toParallaxX = MENU_PARALLAX_X, MENU_PARALLAX_X
    if self.fromScene == _G.menu_scene and self.toScene == _G.highscore_scene then
        fromParallaxX, toParallaxX = MENU_PARALLAX_X, HIGHSCORE_PARALLAX_X
    elseif self.fromScene == _G.highscore_scene and self.toScene == _G.menu_scene then
        fromParallaxX, toParallaxX = HIGHSCORE_PARALLAX_X, MENU_PARALLAX_X
    elseif self.fromScene == _G.menu_scene and self.toScene == _G.instructions_scene then
        fromParallaxX, toParallaxX = MENU_PARALLAX_X, INSTRUCTIONS_PARALLAX_X
    elseif self.fromScene == _G.instructions_scene and self.toScene == _G.menu_scene then
        fromParallaxX, toParallaxX = INSTRUCTIONS_PARALLAX_X, MENU_PARALLAX_X
    end
    -- Use standard lerp: from + (to - from) * t
    local baseParallaxX = fromParallaxX + (toParallaxX - fromParallaxX) * t
    local starfield = _G.sharedStarfield
    if starfield and starfield.draw then
        starfield:draw(width/2, height/2, 3 * width, height, baseParallaxX, starfield.parallaxY or 0)
    end
    if self.fromScene and self.fromScene.draw then
        self.fromScene:draw(fromX, true)
    end
    if self.toScene and self.toScene.draw then
        self.toScene:draw(toX, true)
    end
end

return slide_transition_scene
