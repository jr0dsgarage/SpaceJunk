-- Source/beam_sprite.lua

local gfx <const> = playdate.graphics

local BeamSprite = {}
BeamSprite.__index = BeamSprite

function BeamSprite.new(scene)
    local self = setmetatable({}, BeamSprite)
    self.scene = scene
    local sprite = gfx.sprite.new()
    sprite:setCenter(0, 0)
    sprite:moveTo(0, 0)
    sprite:setZIndex(200) -- above flying objects
    sprite:setSize(_G.SCREEN_WIDTH, _G.SCREEN_HEIGHT)
    sprite.draw = function(_)
        local cx, cy = math.floor(scene.beamX + 0.5), math.floor(scene.beamY + 0.5)
        local innerRadius = math.floor(scene.beamRadius + 0.5)
        local outerRadius = math.floor(scene.beamRadius + (scene.beamRadius / 10) + 0.5)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawCircleAtPoint(cx, cy, innerRadius)
        gfx.drawCircleAtPoint(cx, cy, outerRadius)
    end
    sprite:add()
    self.sprite = sprite
    return self
end

return BeamSprite
