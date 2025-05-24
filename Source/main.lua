import "Corelibs/object"
import "Corelibs/graphics"
import "Corelibs/sprites"
import "Corelibs/timer"
import "Corelibs/ui"

local gfx <const> = playdate.graphics

local circleRadius = 20
local screenWidth, screenHeight = 400, 240
local circleX, circleY = screenWidth/2, screenHeight/2 -- Initial circle position

-- Add this: generate random dots
local numDots = 50
local dots = {}
math.randomseed(playdate.getSecondsSinceEpoch())
for i = 1, numDots do
    table.insert(dots, {
        x = math.random(0, screenWidth),
        y = math.random(0, screenHeight),
        size = math.random(1, 2) -- Random size between 1 and 3
    })
end

function myGameSetup()

end

myGameSetup()

function playdate.update()
    gfx.clear(gfx.kColorBlack)

    -- Draw white dots in the background
    gfx.setColor(gfx.kColorWhite)
    local maxOffset = 3
    local dx = math.max(-maxOffset, math.min(maxOffset, (circleX - screenWidth/2) * 0.01))
    local dy = math.max(-maxOffset, math.min(maxOffset, (circleY - screenHeight/2) * 0.01))
    for i = 1, #dots do
        -- Larger dots move more with parallax
        local px = dots[i].x - dx * dots[i].size
        local py = dots[i].y - dy * dots[i].size
        if dots[i].size == 1 then
            gfx.drawPixel(px, py)
        else
            gfx.fillCircleAtPoint(px, py, dots[i].size)
        end
    end

    -- Draw the circle at its current position
    local cx, cy = math.floor(circleX + 0.5), math.floor(circleY + 0.5)
    local innerRadius = math.floor(circleRadius + 0.5)
    local outerRadius = math.floor(circleRadius + (circleRadius / 10) + 0.5)
    gfx.drawCircleAtPoint(cx, cy, innerRadius)
    gfx.drawCircleAtPoint(cx, cy, outerRadius)

    -- Movement speed inversely proportional to radius
    local moveSpeed = math.max(5, math.floor(circleRadius / 5))
    if playdate.buttonIsPressed(playdate.kButtonUp) then
        circleY = circleY - moveSpeed
    end
    if playdate.buttonIsPressed(playdate.kButtonDown) then
        circleY = circleY + moveSpeed
    end
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        circleX = circleX - moveSpeed
    end
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        circleX = circleX + moveSpeed
    end

    -- Clamp circle center to screen boundaries
    circleX = math.max(0, math.min(screenWidth, circleX))
    circleY = math.max(0, math.min(screenHeight, circleY))

    -- Update circle radius based on crank (logarithmic feel)
    local crankChange = playdate.getCrankChange()
    local scale = math.max(0.1, math.log(circleRadius) / 10)
    circleRadius = math.max(5, math.min(100, circleRadius - crankChange * scale))

    playdate.timer.updateTimers()

    -- Show crank alert if crank is docked
    if playdate.isCrankDocked() then
        playdate.ui.crankIndicator:draw()
    end
end