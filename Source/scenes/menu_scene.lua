local gfx <const> = playdate.graphics
local menu_scene = {}
local TimerBar = import "ui/timer_bar.lua"
local ScoreboardBar = import "ui/scoreboard_bar.lua"

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
    local titleY = 80
    local titleRectW, titleRectH = 240, 38
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(_G.SCREEN_WIDTH/2 - titleRectW/2, titleY - 16, titleRectW, titleRectH)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setColor(gfx.kColorWhite)
    gfx.setFont(ui.titleText_font)
    gfx.drawTextAligned("SPACE JUNK", 200, titleY, kTextAlignment.center)

    -- Start subtitle background and text
    local startSubtitle = "PRESS   A   TO START"
    local startSubtitleW, startSubtitleH = gfx.getTextSize(startSubtitle)
    local startSubtitleRectW, startSubtitleRectH = startSubtitleW + 24, startSubtitleH + 8
    local startSubtitleY = 140
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(200 - startSubtitleRectW/2, startSubtitleY - 4, startSubtitleRectW, startSubtitleRectH)
    gfx.setColor(gfx.kColorWhite)
    gfx.setFont(ui.altText_font)
    gfx.drawTextAligned(startSubtitle, 200, startSubtitleY, kTextAlignment.center)

    -- Draw a circle around the 'A' in the start subtitle
    local aIndex = 9 -- position of 'A' in the string (1-based)
    local charWidth = startSubtitleW / #startSubtitle
    local aX = 200 - (startSubtitleW / 2) + (aIndex - 1) * charWidth + charWidth * 1.465
    local aY = startSubtitleY + ui.altText_font:getHeight() / 2
    gfx.setLineWidth(2)
    gfx.drawCircleAtPoint(aX + 2, aY, charWidth * 0.45)
    gfx.setLineWidth(1)

    -- Move high score subtitle to the bottom, remove circle, and update text
    local highscoreSubtitle = "B: High Scores"
    local highscoreSubtitleW, highscoreSubtitleH = gfx.getTextSize(highscoreSubtitle)
    local highscoreSubtitleRectW, highscoreSubtitleRectH = highscoreSubtitleW + 24, highscoreSubtitleH + 8
    local highscoreSubtitleY = 220
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(200 - highscoreSubtitleRectW/2, highscoreSubtitleY - 4, highscoreSubtitleRectW, highscoreSubtitleRectH)
    gfx.setColor(gfx.kColorWhite)
    gfx.setFont(ui.altText_font)
    gfx.drawTextAligned(highscoreSubtitle, 200, highscoreSubtitleY, kTextAlignment.center)
end

function menu_scene:AButtonDown()
    -- Switch to game scene
    if _G.switchToGameScene then
        _G.switchToGameScene()
    end
end

function menu_scene:BButtonDown()
    if _G.switchToHighScoreScene then
        _G.switchToHighScoreScene()
    end
end

return menu_scene
