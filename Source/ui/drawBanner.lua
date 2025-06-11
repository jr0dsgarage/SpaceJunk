-- Source/ui/drawBanner.lua
local gfx <const> = playdate.graphics
local drawBanner = {}

-- Internal utility to draw a black rounded rectangle behind text
local function drawRectangleForText(x, y, w, h)
    gfx.setColor(gfx.kColorBlack)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    local radius = 8 -- adjust for desired roundness
    gfx.fillRoundRect(x, y, w, h, radius)
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

-- Draws text with a black rectangle background, centered at (x, y)
function drawBanner.draw(str, x, y, font, bannerPadding)
    local bannerPadding = bannerPadding or 2
    if font then gfx.setFont(font) end
    local textWidth = gfx.getTextSize(str)
    local fontObj = gfx.getFont()
    local fontHeight = fontObj and fontObj:getHeight() or 16
    local rectYOffset = getRectYOffset(font)
    local rectW, rectH = textWidth + bannerPadding*2, fontHeight + bannerPadding *2
    
    local rectX, rectY = x - textWidth/2 - bannerPadding, y - fontHeight/2 - bannerPadding + rectYOffset
    drawRectangleForText(rectX, rectY, rectW, rectH)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    if font then gfx.setFont(font) end
    gfx.drawTextAligned(str, x, y, kTextAlignment.center)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
end

-- Draws text with a black rectangle background, aligned at (x, y)
function drawBanner.drawAligned(str, x, y, alignment, font)
    if font then gfx.setFont(font) end
    local w = gfx.getTextSize(str)
    local fontObj = gfx.getFont()
    local h = fontObj and fontObj:getHeight() or 16
    local rectW, rectH = w + 4, h + 4
    local rectYOffset = getRectYOffset(font)
    local rectX
    if alignment == kTextAlignment.center then
        rectX = x - w/2 - 2
    elseif alignment == kTextAlignment.right then
        rectX = x - w - 2
    else -- left
        rectX = x - 2
    end
    local rectY = y - h/2 - 2 + rectYOffset
    drawRectangleForText(rectX, rectY, rectW, rectH)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    if font then gfx.setFont(font) end
    gfx.drawTextAligned(str, x, y, alignment)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
end

return drawBanner
