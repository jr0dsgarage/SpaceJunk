local gfx <const> = playdate.graphics
local menu_scene = {}

-- Constants for layout and spacing
local TITLE_Y = 80
local TITLE_X = 200
local START_SUBTITLE_Y = 140
local INSTR_RIGHT_X = 400
local INSTR_Y = 220
local A_CHAR_INDEX = 9 -- position of 'A' in the string (1-based)

function menu_scene:enter()
    -- Use the globally initialized starfield
    self.starfield = _G.sharedStarfield
    -- Center the starfield vertically at 120px offset if not already set
    if self.starfield and self.starfield.height then
        local centerY = 120
        if not self.starfield._parallaxYInitialized then
            self.starfield.parallaxY = centerY
            self.starfield._parallaxYInitialized = true
        end
    end
end

function menu_scene:leave()
end

function menu_scene:update()
    -- No per-scene parallax logic needed; handled globally
end

-- Add support for drawing at an x offset for transition animations
function menu_scene:draw(xOffset, hideInstructions)
    xOffset = xOffset or 0
    local width = _G.SCREEN_WIDTH or 400
    local height = _G.SCREEN_HEIGHT or 240
    local titleX = TITLE_X or 200
    local titleY = TITLE_Y or 80
    local startSubtitleY = START_SUBTITLE_Y or 140
    local instrRightX = INSTR_RIGHT_X or 400
    local instrY = INSTR_Y or 220
    local aCharIndex = A_CHAR_INDEX or 9
    local statsFont = ui and ui.altText_font or gfx.getFont()
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    gfx.setColor(gfx.kColorBlack)
    if _G.drawBanner and _G.drawBanner.draw then
        _G.drawBanner.draw("SPACE JUNK", titleX + xOffset, titleY, ui and ui.titleText_font or nil)
    end
    local startSubtitle = "PRESS   A   TO START"
    if _G.drawBanner and _G.drawBanner.draw then
        _G.drawBanner.draw(startSubtitle, titleX + xOffset, startSubtitleY, statsFont)
    end
    local prefix = string.sub(startSubtitle, 1, aCharIndex - 1)
    local prefixW, _ = gfx.getTextSize(prefix)
    local aW, _ = gfx.getTextSize("A")
    local startSubtitleW, _ = gfx.getTextSize(startSubtitle)
    local aX = titleX - (startSubtitleW / 2) + prefixW + aW / 2 + xOffset
    local aY = startSubtitleY + (statsFont and statsFont.getHeight and statsFont:getHeight() or 0) / 2
    gfx.setColor(gfx.kColorWhite)
    gfx.setLineWidth(2)
    gfx.drawCircleAtPoint(aX, aY, aW)
    if not hideInstructions and _G.drawBanner and _G.drawBanner.drawAligned then
        _G.drawBanner.drawAligned("High Scores >", instrRightX + xOffset, instrY,  kTextAlignment.right, statsFont)
    end
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
end

function menu_scene:AButtonDown()
    -- Switch to game scene
    if _G.switchToGameScene then
        _G.switchToGameScene()
    end
end

function menu_scene:rightButtonDown()
    -- Trigger slide transition instead of switching directly
    _G.scene_manager.setScene(_G.slide_transition_scene, 1)
end

return menu_scene
