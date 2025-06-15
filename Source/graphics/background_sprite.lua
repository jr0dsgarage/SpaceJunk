---
-- BackgroundSprite: Playdate sprite for the background ship image.
-- Handles creation and removal of the background sprite.
-- @module BackgroundSprite
-- @usage
--   local BackgroundSprite = require("graphics.background_sprite")
--   local bg = BackgroundSprite.new(scene, img, z, w, h)

local gfx <const> = playdate.graphics -- Playdate graphics module

local BackgroundSprite = {} -- Table for BackgroundSprite methods and metatable
BackgroundSprite.__index = BackgroundSprite -- Metatable index for BackgroundSprite

--- Create a new BackgroundSprite.
-- @param parentScene Reference to parent scene
-- @param bgImg Playdate image object
-- @param zindex Z-index for layering
-- @param width Width of sprite
-- @param height Height of sprite
-- @return BackgroundSprite instance
function BackgroundSprite.new(parentScene, bgImg, zindex, width, height)
    local sprite = gfx.sprite.new(bgImg)
    sprite:setCenter(0, 0)
    sprite:moveTo(0, 0)
    sprite:setZIndex(zindex)
    sprite:setSize(width, height)
    sprite:add()
    local self = setmetatable({ sprite = sprite }, BackgroundSprite)
    return self
end

--- Remove the background sprite from the scene.
function BackgroundSprite:remove()
    if self.sprite then
        self.sprite:remove()
        self.sprite = nil
    end
end

return BackgroundSprite
