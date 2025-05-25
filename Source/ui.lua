local gfx <const> = playdate.graphics

local rains3xFont = gfx.font.new("fonts/font-rains-3x")
local fullCircleFont = gfx.font.new("fonts/font-full-circle")

local function drawScore(caught, missed, score)
    -- Draw one large black rectangle behind all label+value pairs
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 205, 400, 42) -- move up 12px (was 210)

    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setColor(gfx.kColorWhite)
    gfx.setFont(fullCircleFont)
    -- Draw labels
    gfx.drawTextAligned("CAUGHT", 0, 206, kTextAlignment.left)      -- was 218, now 218-12
    gfx.drawTextAligned("SCORE", 200, 206, kTextAlignment.center)
    gfx.drawTextAligned("MISSED", 400, 206, kTextAlignment.right)
    -- Draw values below labels
    gfx.drawTextAligned(tostring(caught), 0, 224, kTextAlignment.left)      -- was 236, now 236-12
    gfx.drawTextAligned(tostring(score), 200, 224, kTextAlignment.center)
    gfx.drawTextAligned(tostring(missed), 400, 224, kTextAlignment.right)
end

return {
    drawScore = drawScore,
    titleText_font = rains3xFont,
    altText_font = fullCircleFont,
}