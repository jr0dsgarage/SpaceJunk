-- Source/ui/paper.lua
local gfx <const> = playdate.graphics
local sysFont = gfx.getSystemFont(gfx.font.kVariantNormal)

local Paper = {}

-- Helper to draw plain text 
local function drawText(font, text, x, y)
    if not font then return end
    gfx.setColor(gfx.kColorBlack)
    font:drawText(text, x, y)
end

-- Draw a paper background with alternating bars and border, and calculate bar heights from text/objects
-- x, y, w, h: paper rect
-- options: {titleText, lineText, fonts, dither, cornerRadius, borderWidth, borderColor, fillColor, scrollOffset, visibleLines}
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
    local scrollOffset = options.scrollOffset or 0
    local visibleLines = options.visibleLines or #lineText

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

    -- Start drawing bars below the title rectangle, with scroll offset
    local lineY = titleRectY + titleRectH + 4 - (scrollOffset % 1) * ((lineFont and lineFont:getHeight() or 16) + barPadding)
    local firstIdx = math.floor(scrollOffset) + 1
    for i = 0, visibleLines - 1 do
        local idx = firstIdx + i
        local text = lineText[idx]
        if not text then break end
        local isDithered = (idx % 2 == 1)
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
        -- Draw instruction text 
        drawText(font, text, x + 20, lineY + 5)
        lineY = lineY + lineHeight + barPadding
    end

    -- Draw border
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(borderWidth)
    gfx.drawRoundRect(x, y, w, h, cornerRadius)
end

-- Add scroll state and update for PaperBG
Paper.scrollOffset = 0
Paper.maxScroll = 0
Paper.visibleLines = 7

function Paper.setScrollParams(numLines, visibleLines)
    Paper.visibleLines = visibleLines or 7
    Paper.maxScroll = math.max(0, numLines - Paper.visibleLines)
    if Paper.scrollOffset > Paper.maxScroll then
        Paper.scrollOffset = Paper.maxScroll
    end
end

function Paper.scrollBy(delta)
    Paper.scrollOffset = math.max(0, math.min(Paper.scrollOffset + delta, Paper.maxScroll))
end

function Paper.cranked(change)
    Paper.scrollBy(-change * 0.04)
end

function Paper.upButtonDown()
    Paper.scrollBy(-1)
end

function Paper.downButtonDown()
    Paper.scrollBy(1)
end

return Paper
