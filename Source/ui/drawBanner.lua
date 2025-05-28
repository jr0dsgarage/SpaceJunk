-- Source/ui/drawBanner.lua
local gfx <const> = playdate.graphics
local drawBanner = {}

-- Internal utility to draw a black rectangle behind text
local function drawRectangleForText(x, y, w, h)
    gfx.setColor(gfx.kColorBlack)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    gfx.fillRect(x, y, w, h)
end

-- Utility to determine rectangle vertical offset based on font
local function getRectYOffset(font)
    -- You may want to adjust these values for your specific fonts
    if font == ui.titleText_font then
        return 10
    else
        return 8
    end
end

-- Draws text with a black rectangle background, centered at (x, y)
function drawBanner.draw(str, x, y, font)
    if font then gfx.setFont(font) end
    local w = gfx.getTextSize(str)
    local fontObj = gfx.getFont()
    local h = fontObj and fontObj:getHeight() or 16
    local rectW, rectH = w + 4, h + 4
    local rectYOffset = getRectYOffset(font)
    local rectX, rectY = x - w/2 - 2, y - h/2 - 2 + rectYOffset
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
