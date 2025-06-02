-- Source/ui/paper.lua
local gfx <const> = playdate.graphics
local sysFont = gfx.getSystemFont(gfx.font.kVariantNormal)

local Paper = {}

-- Helper to draw plain text (no outline)
local function drawText(font, text, x, y)
    if not font then return end
    gfx.setColor(gfx.kColorBlack)
    font:drawText(text, x, y)
end

-- Draw a paper background with alternating bars and border, and calculate bar heights from text/objects
-- x, y, w, h: paper rect
-- options: {titleText, lineText, fonts, dither, cornerRadius, borderWidth, borderColor, fillColor}
function Paper.draw(x, y, w, h, options)
    options = options or {}
    local titleText = options.titleText or ""
    local lineText = options.lineText or {}
    local titleFont = options.titleFont
    local lineFont = options.lineFont
    local dither = options.dither or 0.75
    local cornerRadius = options.cornerRadius or 8
    local borderWidth = options.borderWidth or 2
    local barPadding = 2

    -- Draw paper background
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(x, y, w, h, cornerRadius)
    

    -- Draw title background rectangle
    local titleHeight = titleFont and titleFont:getHeight()
    local titleRectY = y + 8
    local titleRectH = titleHeight + 8
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(x , titleRectY, w, titleRectH)
    --gfx.setColor(gfx.kColorBlack)
    --gfx.setLineWidth(1)
    --gfx.drawRect(x + 8, titleRectY, w - 16, titleRectH)

    -- Draw title text (no outline)
    drawText(titleFont, titleText, x + 16, titleRectY + 4)

    -- Start drawing lines below the title rectangle
    local lineY = titleRectY + titleRectH + 4

    -- Draw instruction lines with alternating dithered bars and black lines
    for i, text in ipairs(lineText) do
        local isDithered = (i % 2 == 1)
        local font = lineFont
        local lineHeight = font and font:getHeight() or 16
        -- Draw black line for lined-paper effect
        gfx.setColor(gfx.kColorBlack)
        --gfx.setLineWidth(1)
        --gfx.drawLine(x + 12, lineY, x + w - 12, lineY)
        -- Draw bar (dithered or white)
        if isDithered then
            gfx.setDitherPattern(dither, gfx.image.kDitherTypeBayer8x8)
            gfx.fillRect(x, lineY + 1, w, lineHeight + barPadding)
            gfx.setDitherPattern(0.0, gfx.image.kDitherTypeBayer8x8)
        else
            gfx.setColor(gfx.kColorWhite)
            gfx.fillRect(x + 8, lineY + 1, w - 16, lineHeight + barPadding)
        end
        -- Draw instruction text (no outline)
        drawText(font, text, x + 20, lineY + 2)
        lineY = lineY + lineHeight + barPadding
    end

    -- Draw border
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(borderWidth)
    gfx.drawRoundRect(x, y, w, h, cornerRadius)
end

return Paper
