---
-- CrtOverlay: Playdate sprite for CRT monitor overlay, stretched to play-field.
-- @module CrtOverlay
-- @usage
--   local CrtOverlay = require("graphics.crt_overlay")
--   local overlay = CrtOverlay.new(parentScene)

local gfx <const> = playdate.graphics

local CrtOverlay = {}
CrtOverlay.__index = CrtOverlay

--- Create a new CrtOverlay sprite.
-- @param parentScene Reference to the parent scene (for layout info)
-- @return CrtOverlay instance
function CrtOverlay.new(parentScene)
    local self = setmetatable({}, CrtOverlay)
    self.parentScene = parentScene
    local crtImg = gfx.image.new("sprites/ship_backgrounds/CRT_monitor_resized_cropped_transp.png")
    local outlineImg = gfx.image.new("sprites/ship_backgrounds/crt_outline.png")
    local playfieldY = _G.TIMERBAR_HEIGHT + 5
    local playfieldHeight = _G.SCREEN_HEIGHT - (_G.TIMERBAR_HEIGHT + _G.SCOREBOARD_HEIGHT)
    local playfieldWidth = _G.SCREEN_WIDTH
    local imgW, imgH = 400, 240
    if crtImg and crtImg.getSize then
        imgW, imgH = crtImg:getSize()
    end
    local scaleX = (playfieldWidth / imgW) * 1.025-- slightly smaller in x
    local scaleY = (playfieldHeight / imgH) * 1.05 -- slightly smaller in y
    self.sprite = gfx.sprite.new(crtImg)
    self.sprite:setCenter(0.5, 0.5)
    self.sprite:moveTo(_G.SCREEN_WIDTH/2, playfieldY + playfieldHeight/2)
    local crtZ = _G.ZINDEX and _G.ZINDEX.CRT_MONITOR or 3000
    self.sprite:setZIndex(crtZ)
    self.sprite:setScale(scaleX, scaleY)
    self.sprite:add()
    -- Add outline sprite on top
    self.outlineSprite = gfx.sprite.new(outlineImg)
    self.outlineSprite:setCenter(0.5, 0.5)
    self.outlineSprite:moveTo(_G.SCREEN_WIDTH/2, playfieldY + playfieldHeight/2)
    self.outlineSprite:setZIndex(crtZ + 1)
    self.outlineSprite:setScale(scaleX, scaleY)
    self.outlineSprite:add()
    return self
end

function CrtOverlay:remove()
    if self.sprite then
        self.sprite:remove()
        self.sprite = nil
    end
    if self.outlineSprite then
        self.outlineSprite:remove()
        self.outlineSprite = nil
    end
end

return CrtOverlay
