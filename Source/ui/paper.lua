-- Source/ui/paper.lua
local gfx <const> = playdate.graphics

local Paper = {}

-- Draw a paper background with alternating bars and border, and calculate bar heights from text/objects
-- x, y, w, h: paper rect
-- options: {lines, fonts, barPadding, dither, cornerRadius, borderWidth, borderColor, fillColor}
function Paper.draw(x, y, w, h, options)
    options = options or {}
    local lines = options.lines or {}
    local fonts = options.fonts or {}
    local barPadding = options.barPadding or 0
    local dither = options.dither or 0.9
    local cornerRadius = options.cornerRadius or 8
    local borderWidth = options.borderWidth or 2
    local borderColor = options.borderColor or gfx.kColorBlack
    local fillColor = options.fillColor or gfx.kColorWhite

    -- Fill paper background
    gfx.setColor(fillColor)
    gfx.fillRoundRect(x, y, w, h, cornerRadius)

    -- Calculate bar heights and positions from text/objects
    local barYs = {}
    local barHeights = {}
    local barY = y + 10
    for i, line in ipairs(lines) do
        local font = type(fonts) == "table" and fonts[i] or fonts
        if font then gfx.setFont(font) end
        local _, th = gfx.getTextSize(line)
        table.insert(barYs, barY - barPadding)
        table.insert(barHeights, th + 2 * barPadding)
        barY = barY + th
    end

    -- Draw alternating bars (dithered for even lines)
    for i = 1, #barYs do
        if (i % 2) == 0 then
            gfx.setDitherPattern(dither, gfx.image.kDitherTypeBayer8x8)
            gfx.fillRect(x, barYs[i], w, barHeights[i])
            gfx.setDitherPattern(0)
        end
    end

    -- Draw border
    gfx.setColor(borderColor)
    gfx.setLineWidth(borderWidth)
    gfx.drawRoundRect(x, y, w, h, cornerRadius)
end

return Paper
