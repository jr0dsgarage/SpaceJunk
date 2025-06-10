local gfx <const> = playdate.graphics -- Add this line to define gfx

-- scenes/scene_manager.lua
local scene_manager = {}

local currentScene = nil

-- Constants for starfield and layout
local STARFIELD_CENTER_Y = 120
local SCREEN_HEIGHT = _G.SCREEN_HEIGHT or 240

-- Initialize the global starfield (3x3 screens, centered)
local function ensureStarfield()
    if not _G.sharedStarfield then
        _G.sharedStarfield = _G.Starfield.new()
        _G.sharedStarfield.parallaxX = 0
        _G.sharedStarfield.parallaxY = STARFIELD_CENTER_Y
    end
end

function scene_manager.clear()
    print ("Clearing scene manager")
    playdate.graphics.sprite.removeAll()
    if _G.ui and _G.ui.reset then _G.ui.reset() end
end

function scene_manager.setScene(scene, ...)
    ensureStarfield()
    scene_manager.clear()
    if currentScene and currentScene.leave then
        currentScene:leave()
    end
    currentScene = scene
    if currentScene and currentScene.enter then
        currentScene:enter(...)
    end
end

function scene_manager.update()
    -- Centralize crank-based Y parallax for menu and highscore scenes
    if (currentScene == _G.menu_scene or currentScene == _G.highscore_scene) and _G.sharedStarfield then
        local crankChange = playdate.getCrankChange()
        if math.abs(crankChange) > 0 then
            local maxOffset = SCREEN_HEIGHT / 1.5
            local centerY = STARFIELD_CENTER_Y
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
    local width = _G.SCREEN_WIDTH or 400
    local height = _G.SCREEN_HEIGHT or 240
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, width, height)
    
    -- Only draw the starfield if not in the transition scene
    if currentScene ~= _G.slide_transition_scene then
        local offsetX = 0
        if currentScene == _G.highscore_scene then
            offsetX = 2 * width
        end
        if _G.sharedStarfield and _G.sharedStarfield.draw then
            _G.sharedStarfield:draw(width / 2 + offsetX, height / 2, 3 * width, height, 0,
            _G.sharedStarfield.parallaxY or 0)
        end
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
