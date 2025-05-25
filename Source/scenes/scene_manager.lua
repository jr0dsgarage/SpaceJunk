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

function scene_manager.usesSprites()
    return currentScene and currentScene.usesSprites and currentScene:usesSprites()
end

return scene_manager
