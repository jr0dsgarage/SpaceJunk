-- Source/starfield.lua

local gfx <const> = playdate.graphics

local Starfield = {}
Starfield.__index = Starfield

function Starfield.new(width, height, numStars)
    local self = setmetatable({}, Starfield)
    self.width = width
    self.height = height
    self.numStars = numStars or 50
    self.stars = {}
    math.randomseed(playdate.getSecondsSinceEpoch())
    for i = 1, self.numStars do
        table.insert(self.stars, {
            x = math.random(0, self.width),
            y = math.random(0, self.height),
            size = math.random(1, 2)
        })
    end
    return self
end

function Starfield:draw(centerX, centerY, screenWidth, screenHeight)
    gfx.setColor(gfx.kColorWhite)
    local maxOffset = 3
    local dx, dy = 0, 0
    if centerX and centerY and screenWidth and screenHeight then
        dx = math.max(-maxOffset, math.min(maxOffset, (centerX - screenWidth/2) * 0.01))
        dy = math.max(-maxOffset, math.min(maxOffset, (centerY - screenHeight/2) * 0.01))
    end
    for i = 1, #self.stars do
        local px = self.stars[i].x - dx * self.stars[i].size
        local py = self.stars[i].y - dy * self.stars[i].size
        if self.stars[i].size == 1 then
            gfx.drawPixel(px, py)
        else
            gfx.drawLine(px - 2, py, px + 2, py)
            gfx.drawLine(px, py - 2, px, py + 2)
        end
    end
end

return Starfield
