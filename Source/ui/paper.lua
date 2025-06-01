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
    barPadding = barPadding or 0
    local textX = x
    local textY = y + 10
    local barX = x
    local barW = w
    -- Draw alternating bars and text in a single loop for perfect alignment
    for i, line in ipairs(lines) do
        local isTitle = (i == 1)
        local thisFont = type(fonts) == "table" and fonts[i] or fonts
        if thisFont then gfx.setFont(thisFont) end
        local thisHeight = isTitle and titleHeight or lineHeight
        -- Draw dithered bar for every other instruction line (not title)
        if not isTitle and ((i-1) % 2 == 1) then
            gfx.setDitherPattern(dither, gfx.image.kDitherTypeBayer8x8)
            gfx.fillRect(barX, textY - barPadding, barW, thisHeight + 2 * barPadding)
            gfx.setDitherPattern(0)
        end
        -- Draw text
        if isTitle then
            gfx.drawTextAligned(line, textX + w // 2, textY, kTextAlignment.center)
        else
            gfx.drawTextAligned("- " .. line, textX + 16, textY, kTextAlignment.left)
        end
        textY = textY + thisHeight
    end
    -- Draw border
    gfx.setColor(borderColor)
    gfx.setLineWidth(borderWidth)
    gfx.drawRoundRect(x, y, w, h, cornerRadius)
end

return Paper
