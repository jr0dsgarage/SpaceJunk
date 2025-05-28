local gfx <const> = playdate.graphics -- Add this line to define gfx

-- scenes/scene_manager.lua
local scene_manager = {}

local currentScene = nil

function scene_manager.clear()
    playdate.graphics.sprite.removeAll()
    if _G.ui and _G.ui.reset then _G.ui.reset() end
end

function scene_manager.setScene(scene, ...)
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
            _G.sharedStarfield:draw(width/2 + offsetX, height/2, 3 * width, height)
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
