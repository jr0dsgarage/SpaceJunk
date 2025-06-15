-- Source/ui/drawBanner.lua
local gfx <const> = playdate.graphics
local drawBanner = {}

-- Internal utility to draw a black rounded rectangle behind text, with optional border
local function drawRectangleForText(x, y, w, h, border)
    gfx.setColor(gfx.kColorBlack)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    local radius = 8 -- adjust for desired roundness
    gfx.fillRoundRect(x, y, w, h, radius)
    border = border or 0
    if border > 0 then
        gfx.setColor(gfx.kColorWhite)
        gfx.setLineWidth(math.min(border, 10))
        gfx.drawRoundRect(x, y, w, h, radius)
        gfx.setLineWidth(1)
    end
end

-- Utility to determine rectangle vertical offset based on font
local function getRectYOffset(font)
    -- You may want to adjust these values for your specific fonts
    if font == ui.titleText_font then
        return 10
    else
        return 6
    end
end

-- Shared internal function for drawing a banner (rounded rect + text)
local function drawBannerCore(str, x, y, alignment, font, bannerPadding, border)
    local pad = bannerPadding or 2
    if font then gfx.setFont(font) end
    local textWidth = gfx.getTextSize(str)
    local fontObj = gfx.getFont()
    local fontHeight = fontObj and fontObj:getHeight() or 16
    local rectYOffset = getRectYOffset(font)
    local rectW, rectH = textWidth + pad*2, fontHeight + pad*2
    local rectX, rectY
    if alignment == kTextAlignment.right then
        rectX = x - textWidth - pad
    elseif alignment == kTextAlignment.left then
        rectX = x - pad
    else -- center
        rectX = x - textWidth/2 - pad
    end
    rectY = y - fontHeight/2 - pad + rectYOffset
    drawRectangleForText(rectX, rectY, rectW, rectH, border)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    if font then gfx.setFont(font) end
    gfx.drawTextAligned(str, x, y, alignment or kTextAlignment.center)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
end

-- Draws text with a black rectangle background, centered at (x, y)
function drawBanner.draw(str, x, y, font, bannerPadding, border)
    drawBannerCore(str, x, y, kTextAlignment.center, font, bannerPadding, border)
end

-- Draws text with a black rectangle background, aligned at (x, y)
function drawBanner.drawAligned(str, x, y, alignment, font, bannerPadding, border)
    drawBannerCore(str, x, y, alignment, font, bannerPadding, border)
end

return drawBanner
