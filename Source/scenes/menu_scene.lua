local gfx <const> = playdate.graphics
local menu_scene = {}

-- Constants for layout and spacing
local TITLE_Y = 80
local TITLE_X = 200
local START_SUBTITLE_Y = 140 -- Y position for the "PRESS A TO START" subtitle
local A_CHAR_INDEX = 9 -- position of 'A' in the string (1-based)
local TITLE_BANNER_PAD = 8
local SUBTITLE_BANNER_PAD = 6

function menu_scene:enter()
    -- Use the globally initialized starfield
    self.starfield = _G.sharedStarfield
end

-- Add support for drawing at an x offset for transition animations
function menu_scene:draw(xOffset, hideInstructions)
    xOffset = xOffset or 0
    local titleX = TITLE_X
    local titleY = TITLE_Y
    local startSubtitleY = START_SUBTITLE_Y
    local aCharIndex = A_CHAR_INDEX
    local statsFont = _G.ui and _G.ui.altText_font or gfx.getFont()

    if _G.drawBanner and _G.drawBanner.draw then
        _G.drawBanner.draw("SPACE JUNK", titleX + xOffset, titleY, ui and ui.titleText_font or nil, _G.TITLE_BANNER_PAD)
    end
    local startSubtitle = "PRESS   A   TO START"
    if _G.drawBanner and _G.drawBanner.draw then
        _G.drawBanner.draw(startSubtitle, titleX + xOffset, startSubtitleY, statsFont, _G.SUBTITLE_BANNER_PAD)
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
        _G.drawBanner.drawAligned("< Instructions", _G.INSTR_LEFT_X + xOffset, _G.INSTR_Y, kTextAlignment.left, statsFont, _G.INSTR_BANNER_PAD)
        _G.drawBanner.drawAligned("High Scores >", _G.INSTR_RIGHT_X + xOffset, _G.INSTR_Y, kTextAlignment.right, statsFont, _G.INSTR_BANNER_PAD)
    end
end

function menu_scene:AButtonDown()
    -- Switch to game scene
    if _G.switchToGameScene then
        _G.switchToGameScene()
    end
end

function menu_scene:rightButtonDown()
    -- Trigger slide transition to high scores (menu -> highscore, slide right)
    _G.scene_manager.setScene(_G.slide_transition_scene, 1)
end

function menu_scene:leftButtonDown()
    -- Trigger slide transition to instructions (menu -> instructions, slide left)
    _G.scene_manager.setScene(_G.slide_transition_scene, -2)
end

return menu_scene
