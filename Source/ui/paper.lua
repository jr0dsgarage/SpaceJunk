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
    local barPadding = options.barPadding 
    local dither = options.dither 
    local cornerRadius = options.cornerRadius 
    local borderWidth = options.borderWidth
    
    local borderColor = gfx.kColorBlack
    local fillColor = gfx.kColorWhite

    -- Debug print incoming options
    print("PaperBG.draw options:")
    for k, v in pairs(options) do
        print("  ", k, v)
    end

    -- Fill paper background
    gfx.setColor(fillColor)
    gfx.fillRoundRect(x, y, w, h, cornerRadius)

    -- Calculate heights
    local titleFont = type(fonts) == "table" and fonts[1] or fonts
    if titleFont then gfx.setFont(titleFont) end
    local titleHeight = titleFont and type(titleFont.getHeight) == "function" and titleFont:getHeight() or 21
    local lineFont = type(fonts) == "table" and fonts[2] or fonts
    if lineFont then gfx.setFont(lineFont) end
    local lineHeight = lineFont and type(lineFont.getHeight) == "function" and lineFont:getHeight() or 15
    local numLines = #lines - 1
    local barPadding = barPadding or 0

    -- Draw alternating bars: skip title, draw every other line after
    local barY = y + titleHeight
    for i = 1, numLines do
        if (i % 2) == 1 then -- draw bar for every other line (first instruction, third, ...)
            print(string.format("Drawing dithered bar %d at y=%.1f, h=%.1f", i, barY - barPadding, lineHeight + 2 * barPadding))
            gfx.setDitherPattern(dither, gfx.image.kDitherTypeBayer8x8)
            gfx.fillRect(x, barY - barPadding, w, lineHeight + barPadding)
            gfx.setDitherPattern(0)
        end
        barY = barY + lineHeight
    end

    -- Draw border
    gfx.setColor(borderColor)
    gfx.setLineWidth(borderWidth)
    gfx.drawRoundRect(x, y, w, h, cornerRadius)
end

return Paper
