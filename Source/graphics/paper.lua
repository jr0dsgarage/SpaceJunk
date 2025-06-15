---
-- Paper module for drawing a paper-style background and text.
-- Provides a helper to draw a paper background with title and lines.
-- @module Paper
-- @usage
--   local Paper = require("graphics.paper")
--   Paper.draw(x, y, w, h, options)

local gfx <const> = playdate.graphics -- Playdate graphics module
local sysFont = gfx.getSystemFont(gfx.font.kVariantNormal) -- System font (normal variant)

local Paper = {} -- Table for Paper module methods

--- Helper to draw plain text with a font.
-- @param font Playdate font object
-- @param text String to draw
-- @param x X position
-- @param y Y position
local function drawText(font, text, x, y)
    if not font then return end
    gfx.setColor(gfx.kColorBlack)
    font:drawText(text, x, y)
end

--- Draw a paper background with alternating bars and border.
-- @param x X position
-- @param y Y position
-- @param w Width
-- @param h Height
-- @param options Table with keys: titleText, lineText, fonts, dither, cornerRadius, borderWidth, borderColor, fillColor, scrollOffset, visibleLines
function Paper.draw(x, y, w, h, options)
    options = options or {}
    local titleText = options.titleText or ""
    local lineText = options.lineText or {}
    local titleFont = options.titleFont
    local lineFont = options.lineFont
    local dither = options.dither or 0.75
    local cornerRadius = options.cornerRadius or 8
    local borderWidth = options.borderWidth or 2
    local barPadding = 8

    -- Draw paper background
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(x, y, w, h, cornerRadius)

    -- Draw title background rectangle
    local titleHeight = titleFont and titleFont:getHeight()
    local titleRectY = y + 8
    local titleRectH = titleHeight + 8
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(x , titleRectY, w, titleRectH)
    -- Draw title text (no outline)
    drawText(titleFont, titleText, x + 16, titleRectY + 4)

    -- Calculate how many lines fit in the given paper height
    local visibleLines = Paper.getVisibleLines(h, lineFont, barPadding)

    -- Start drawing bars below the title rectangle
    local lineY = titleRectY + titleRectH + 4
    for i = 1, math.min(#lineText, visibleLines) do
        local text = lineText[i]
        if not text then break end
        local isDithered = (i % 2 == 1)
        local font = lineFont
        local lineHeight = font and font:getHeight() or 16
        -- Draw bar (dithered or white)
        if isDithered then
            gfx.setDitherPattern(dither, gfx.image.kDitherTypeBayer8x8)
            gfx.fillRect(x, lineY + 1, w, lineHeight + barPadding)
            gfx.setDitherPattern(0.0, gfx.image.kDitherTypeBayer8x8)
        else
            gfx.setColor(gfx.kColorWhite)
            gfx.fillRect(x + 8, lineY + 1, w - 16, lineHeight + barPadding)
        end
        drawText(font, text, x + 20, lineY + 5)
        lineY = lineY + lineHeight + barPadding
    end

    -- Draw border
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(borderWidth)
    gfx.drawRoundRect(x, y, w, h, cornerRadius)
end

-- Utility to calculate how many lines fit in the given paper height
function Paper.getVisibleLines(paperHeight, lineFont, barPadding)
    local fontHeight = (lineFont and lineFont.getHeight and lineFont:getHeight()) or 16
    local padding = barPadding or 8
    -- Subtract title area (title height + 8 + 8 + 4)
    local titleHeight = (lineFont and lineFont.getHeight and lineFont:getHeight()) or 16
    local titleArea = titleHeight + 8 + 8 + 4
    local available = paperHeight - titleArea
    if available <= 0 then return 0 end
    local lineBlock = fontHeight + padding
    return math.floor(available / lineBlock)
end

return Paper
