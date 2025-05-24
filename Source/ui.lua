local gfx <const> = playdate.graphics

local rains3xFont = gfx.font.new("fonts/font-rains-3x")
local fullCircleFont = gfx.font.new("fonts/font-full-circle")

local function drawScore(caught, missed, score)
    -- Draw one large black rectangle behind all label+value pairs
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 210, 400, 32) -- Full width of the screen

    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setColor(gfx.kColorWhite)
    gfx.setFont(fullCircleFont)
    -- Draw labels
    gfx.drawTextAligned("CAUGHT", 0, 214, kTextAlignment.left)
    gfx.drawTextAligned("SCORE", 200, 214, kTextAlignment.center)
    gfx.drawTextAligned("MISSED", 400, 214, kTextAlignment.right)
    -- Draw values below labels
    gfx.drawTextAligned(tostring(caught), 0, 230, kTextAlignment.left)
    gfx.drawTextAligned(tostring(score), 200, 230, kTextAlignment.center)
    gfx.drawTextAligned(tostring(missed), 400, 230, kTextAlignment.right)
end

return {
    drawScore = drawScore,
    titleText_font = rains3xFont,
    altText_font = fullCircleFont,
}