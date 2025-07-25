---
-- Scene Manager module for handling scene transitions and starfield parallax.
-- Provides global parallax constants and manages scene lifecycle.
-- @module scene_manager
-- @usage
--   local scene_manager = require("scenes.scene_manager")
--   scene_manager.setScene(menu_scene)

local gfx <const> = playdate.graphics -- Playdate graphics module

-- scenes/scene_manager.lua
local scene_manager = {} -- Table for scene manager methods and state

local currentScene = nil -- Holds the currently active scene

--- Parallax constants for scene types (shared with transition scene)
-- @field MENU_PARALLAX_X Parallax X for menu scene
-- @field HIGHSCORE_PARALLAX_X Parallax X for highscore scene
-- @field INSTRUCTIONS_PARALLAX_X Parallax X for instructions scene
_G.MENU_PARALLAX_X = 0
_G.HIGHSCORE_PARALLAX_X = 5
_G.INSTRUCTIONS_PARALLAX_X = -5

--- Clear all sprites and reset starfield if missing.
function scene_manager.clear()
    playdate.graphics.sprite.removeAll()
    -- Recreate starfield if missing (e.g., after score scene B button)
    if not _G.sharedStarfield then
        _G.sharedStarfield = _G.Starfield.new()
    end
    if _G.ui and _G.ui.reset then _G.ui.reset() end
end

--- Set the current scene, handling transitions and parallax.
-- @param scene Scene table to activate
-- @param ... Additional arguments for scene's enter method
function scene_manager.setScene(scene, ...)
    scene_manager.clear()
    if currentScene and currentScene.leave then
        currentScene:leave()
    end
    
    -- Set starfield parallaxX for each scene type
    if scene == _G.menu_scene then
        _G.sharedStarfield.parallaxX = _G.MENU_PARALLAX_X
    elseif scene == _G.highscore_scene then
        _G.sharedStarfield.parallaxX = _G.HIGHSCORE_PARALLAX_X
    elseif scene == _G.instructions_scene then
        _G.sharedStarfield.parallaxX = _G.INSTRUCTIONS_PARALLAX_X
    end
    currentScene = scene
    if currentScene and currentScene.enter then
        currentScene:enter(...)
    end
end

function scene_manager.update()
    -- Centralize crank-based Y parallax for all scenes
    if _G.sharedStarfield then
        local crankChange = playdate.getCrankChange()
        if math.abs(crankChange) > 0 then
            local maxOffset = _G.SCREEN_HEIGHT / 1.5
            local centerY = 120
            local newY = (_G.sharedStarfield.parallaxY or centerY) - crankChange * 0.5
            if newY < centerY - maxOffset then newY = centerY - maxOffset end
            if newY > centerY + maxOffset then newY = centerY + maxOffset end
            _G.sharedStarfield.parallaxY = newY
        end
    end
    if currentScene and currentScene.update then
        currentScene:update()
    end
end

function scene_manager.draw()
    -- Always clear the screen to black first
    gfx.clear(gfx.kColorBlack)
    
    -- Always draw the starfield as the background, regardless of scene
    if _G.sharedStarfield and _G.sharedStarfield.draw then
        _G.sharedStarfield:draw(_G.SCREEN_WIDTH / 2, _G.SCREEN_HEIGHT / 2, 3 * _G.SCREEN_WIDTH, _G.SCREEN_HEIGHT, _G.sharedStarfield.parallaxX, _G.sharedStarfield.parallaxY)
    end
    
    if currentScene and currentScene.draw then
        currentScene:draw()
    end
end

function scene_manager.AButtonDown()
    if currentScene and currentScene.AButtonDown then
        currentScene:AButtonDown()
    end
end

function scene_manager.BButtonDown()
    if currentScene and currentScene.BButtonDown then
        currentScene:BButtonDown()
    end
end

function scene_manager.rightButtonDown()
    if currentScene and currentScene.rightButtonDown then
        currentScene:rightButtonDown()
    end
end

function scene_manager.leftButtonDown()
    if currentScene and currentScene.leftButtonDown then
        currentScene:leftButtonDown()
    end
end

function scene_manager.usesSprites()
    return currentScene and currentScene.usesSprites and currentScene:usesSprites()
end

return scene_manager
