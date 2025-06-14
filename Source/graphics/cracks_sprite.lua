---
-- CracksSprite: Playdate sprite for drawing cracks on the screen.
-- Handles creation, image updates, and removal.
-- @module CracksSprite
-- @usage
--   local CracksSprite = require("graphics.cracks_sprite")
--   local cracks = CracksSprite.new(scene, img, z, w, h)

local gfx <const> = playdate.graphics

local CracksSprite = {}
CracksSprite.__index = CracksSprite

--- Create a new CracksSprite.
-- @param parentScene Reference to parent scene
-- @param image Playdate image object
-- @param zindex Z-index for layering
-- @param width Width of sprite
-- @param height Height of sprite
-- @return CracksSprite instance
function CracksSprite.new(parentScene, image, zindex, width, height)
    local sprite = gfx.sprite.new(image)
    sprite:setCenter(0, 0)
    sprite:moveTo(0, 0)
    sprite:setZIndex(zindex)
    sprite:setSize(width, height)
    sprite:add()
    local self = setmetatable({ sprite = sprite }, CracksSprite)
    return self
end

--- Set the cracks image.
-- @param image Playdate image object
function CracksSprite:setImage(image)
    if self.sprite then
        self.sprite:setImage(image)
    end
end

--- Remove the cracks sprite from the scene.
function CracksSprite:remove()
    if self.sprite then
        self.sprite:remove()
        self.sprite = nil
    end
end

return CracksSprite
