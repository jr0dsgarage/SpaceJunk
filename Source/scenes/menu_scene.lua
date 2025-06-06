local gfx <const> = playdate.graphics
local menu_scene = {}

-- Constants for starfield and layout
local STARFIELD_CENTER_Y = 120

-- Constants for layout and spacing
local TITLE_Y = 80
local TITLE_X = 200
local START_SUBTITLE_Y = 140
local A_CHAR_INDEX = 9 -- position of 'A' in the string (1-based)

function menu_scene:enter()
    -- Use the globally initialized starfield
    self.starfield = _G.sharedStarfield
    -- Center the starfield vertically at STARFIELD_CENTER_Y offset if not already set
    if self.starfield and self.starfield.height then
        local centerY = STARFIELD_CENTER_Y
        if not self.starfield._parallaxYInitialized then
            self.starfield.parallaxY = centerY
            self.starfield._parallaxYInitialized = true
        end
    end
end

-- Add support for drawing at an x offset for transition animations
function menu_scene:draw(xOffset, hideInstructions)
    xOffset = xOffset or 0
    local width = _G.SCREEN_WIDTH or 400
    local height = _G.SCREEN_HEIGHT or 240
    local titleX = TITLE_X or 200
    local titleY = TITLE_Y or 80
    local startSubtitleY = START_SUBTITLE_Y or 140
    local aCharIndex = A_CHAR_INDEX or 9
    local statsFont = ui and ui.altText_font or gfx.getFont()
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
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
        _G.drawBanner.drawAligned("< Instructions", _G.INSTR_LEFT_X + xOffset, _G.INSTR_Y, kTextAlignment.left, statsFont)
        _G.drawBanner.drawAligned("High Scores >", _G.INSTR_RIGHT_X + xOffset, _G.INSTR_Y, kTextAlignment.right, statsFont)
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
    -- Trigger slide transition to high scores (menu -> highscore, slide right)
    _G.scene_manager.setScene(_G.slide_transition_scene, 1)
end

function menu_scene:leftButtonDown()
    -- Trigger slide transition to instructions (menu -> instructions, slide left)
    _G.scene_manager.setScene(_G.slide_transition_scene, -2)
end

function menu_scene:BButtonDown()
    -- Switch to test scene when B is pressed on the main menu
    if _G.test_scene then
        _G.scene_manager.setScene(_G.test_scene)
    end
end

return menu_scene
