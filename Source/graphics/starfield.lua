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
    self.parallaxX = 0
    self.parallaxY = 0
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

function Starfield:setParallaxOffset(px, py)
    self.parallaxX = px or 0
    self.parallaxY = py or 0
end

function Starfield:scrollParallaxY(dy, screenHeight)
    local maxY = ((self.height or ((screenHeight or 240) * 3)) - (screenHeight or 240)) / 2
    local newY = (self.parallaxY or 0) + dy
    if maxY > 0 then
        newY = math.max(-maxY, math.min(newY, maxY))
    else
        newY = 0
    end
    self:setParallaxOffset(self.parallaxX or 0, newY)
end

function Starfield:draw(centerX, centerY, screenWidth, screenHeight, parallaxX, parallaxY)
    gfx.setColor(gfx.kColorWhite)
    local maxOffset = 3
    local dx, dy = 0, 0
    if centerX and centerY and screenWidth and screenHeight then
        dx = math.max(-maxOffset, math.min(maxOffset, (centerX - screenWidth/2) * 0.01))
        dy = math.max(-maxOffset, math.min(maxOffset, (centerY - screenHeight/2) * 0.01))
    end
    dx = dx + (parallaxX or self.parallaxX or 0)
    dy = dy + (parallaxY or self.parallaxY or 0)
    for i = 1, #self.stars do
        local px = self.stars[i].x - dx * self.stars[i].size
        local py = self.stars[i].y - dy * (self.stars[i].size == 1 and 1 or 1.5)
        if self.stars[i].size == 1 then
            gfx.drawPixel(px, py)
        else
            gfx.setLineWidth(1)
            gfx.drawLine(px - 2, py, px + 2, py)
            gfx.drawLine(px, py - 2, px, py + 2)
        end
    end
end

return Starfield
