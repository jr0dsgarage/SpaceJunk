-- scenes/scene_manager.lua
local scene_manager = {}

local currentScene = nil

function scene_manager.setScene(scene, ...)
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

return scene_manager
