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
    -- Called when entering the menu scene
    _G.sharedStarfield = _G.Starfield.new(_G.SCREEN_WIDTH, _G.SCREEN_HEIGHT, 50)
    self.starfield = _G.sharedStarfield
end

function menu_scene:leave()
end

function menu_scene:update()
    -- Nothing to update for static menu
end

function menu_scene:draw()
    -- Fill background and draw starfield
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, _G.SCREEN_WIDTH, _G.SCREEN_HEIGHT)
    if self.starfield then
        self.starfield:draw(_G.SCREEN_WIDTH/2, _G.SCREEN_HEIGHT/2, _G.SCREEN_WIDTH, _G.SCREEN_HEIGHT)
    end

    -- Title background and text
    _G.drawBanner.draw("SPACE JUNK", TITLE_X, TITLE_Y, ui.titleText_font)

    -- Start subtitle background and text
    local startSubtitle = "PRESS   A   TO START"
    _G.drawBanner.draw(startSubtitle, TITLE_X, START_SUBTITLE_Y, ui.altText_font)

    -- Draw a circle around the 'A' in the start subtitle (robust to font/spacing)
    local prefix = string.sub(startSubtitle, 1, A_CHAR_INDEX - 1)
    local prefixW, _ = gfx.getTextSize(prefix)
    local aW, _ = gfx.getTextSize("A")
    local startSubtitleW, _ = gfx.getTextSize(startSubtitle)
    local aX = TITLE_X - (startSubtitleW / 2) + prefixW + aW / 2
    local aY = START_SUBTITLE_Y + ui.altText_font:getHeight() / 2
    gfx.setColor(gfx.kColorWhite)
    gfx.setLineWidth(2)
    gfx.drawCircleAtPoint(aX, aY, aW) 

    -- High score subtitle at the bottom
    _G.drawBanner.drawAligned("High Scores >", INSTR_RIGHT_X, INSTR_Y,  kTextAlignment.right, ui.altText_font)
    gfx.setImageDrawMode(gfx.kDrawModeCopy) -- Reset draw mode after all drawing
end

function menu_scene:AButtonDown()
    -- Switch to game scene
    if _G.switchToGameScene then
        _G.switchToGameScene()
    end
end

function menu_scene:rightButtonDown()
    if _G.switchToHighScoreScene then
        _G.switchToHighScoreScene()
    end
end

return menu_scene
