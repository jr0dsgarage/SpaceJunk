---
-- Menu scene module for the main menu UI and title screen.
-- Draws title, subtitle, and handles menu entry logic.
-- @module menu_scene
-- @usage
--   local menu_scene = require("scenes.menu_scene")
--   menu_scene:enter()

local gfx <const> = playdate.graphics -- Playdate graphics module
local menu_scene = {} -- Table for menu scene methods and state

-- Constants for layout and spacing
local TITLE_Y = 80 -- Y position for the title text
local TITLE_X = 200 -- X position for the title text
local START_SUBTITLE_Y = 140 -- Y position for the "PRESS A TO START" subtitle
local A_CHAR_INDEX = 9 -- position of 'A' in the string (1-based)

--- Draw the menu scene, with optional x offset for transitions.
-- @param xOffset X offset for transition animation
-- @param hideInstructions Boolean to hide instructions
function menu_scene:draw(xOffset, hideInstructions)
    xOffset = xOffset or 0
    -- Use constants directly, not local copies
    local statsFont = _G.ui and _G.ui.altText_font or gfx.getFont()

    if _G.drawBanner and _G.drawBanner.draw then
        _G.drawBanner.draw("SPACE JUNK", TITLE_X + xOffset, TITLE_Y, ui and ui.titleText_font or nil, _G.TITLE_BANNER_PAD, 5)
    end
    local startSubtitle = "PRESS   A   TO START"
    if _G.drawBanner and _G.drawBanner.draw then
        _G.drawBanner.draw(startSubtitle, TITLE_X + xOffset, START_SUBTITLE_Y, statsFont, _G.SUBTITLE_BANNER_PAD,1)
    end
    local prefix = string.sub(startSubtitle, 1, A_CHAR_INDEX - 1)
    local prefixW, _ = gfx.getTextSize(prefix)
    local aW, _ = gfx.getTextSize("A")
    local startSubtitleW, _ = gfx.getTextSize(startSubtitle)
    local aX = TITLE_X - (startSubtitleW / 2) + prefixW + aW / 2 + xOffset
    local aY = START_SUBTITLE_Y - 1 + (statsFont and statsFont.getHeight and statsFont:getHeight() or 0) / 2
    gfx.setColor(gfx.kColorWhite)
    gfx.setLineWidth(2)
    gfx.drawCircleAtPoint(aX, aY, aW)
    if not hideInstructions and _G.drawBanner and _G.drawBanner.drawAligned then
        _G.drawBanner.drawAligned("<< Instructions", _G.INSTR_LEFT_X + xOffset, _G.INSTR_Y, kTextAlignment.left, statsFont, _G.INSTR_BANNER_PAD, 1)
        _G.drawBanner.drawAligned("High Scores >>", _G.INSTR_RIGHT_X + xOffset, _G.INSTR_Y, kTextAlignment.right, statsFont, _G.INSTR_BANNER_PAD, 1)
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
