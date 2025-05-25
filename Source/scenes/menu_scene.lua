-- scenes/menu_scene.lua
-- Use global modules if needed (ui is already _G.ui)
local gfx <const> = playdate.graphics
local menu_scene = {}
local TimerBar = import "ui/timer_bar.lua"
local ScoreboardBar = import "ui/scoreboard_bar.lua"

function menu_scene:enter()
    -- Called when entering the menu scene
    self.screenWidth, self.screenHeight = playdate.display.getWidth(), playdate.display.getHeight()
    self.starfield = _G.Starfield.new(self.screenWidth, self.screenHeight, 50)
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
    gfx.fillRect(0, 0, 400, 240)
    if self.starfield then
        self.starfield:draw(200, 120, 400, 240)
    end

    -- Title background and text
    local titleY = 80
    local titleRectW, titleRectH = 240, 38
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(self.screenWidth/2 - titleRectW/2, titleY - 16, titleRectW, titleRectH)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setColor(gfx.kColorWhite)
    gfx.setFont(ui.titleText_font)
    gfx.drawTextAligned("SPACE JUNK", 200, titleY, kTextAlignment.center)

    -- Subtitle background and text
    local subtitle = "PRESS   A   TO START"
    local subtitleW, subtitleH = gfx.getTextSize(subtitle)
    local subtitleRectW, subtitleRectH = subtitleW + 24, subtitleH + 8
    local subtitleY = 140
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(200 - subtitleRectW/2, subtitleY - 4, subtitleRectW, subtitleRectH)
    gfx.setColor(gfx.kColorWhite)
    gfx.setFont(ui.altText_font)
    gfx.drawTextAligned(subtitle, 200, subtitleY, kTextAlignment.center)

    -- Draw a circle around the 'A' in the subtitle
    local aIndex = 9 -- position of 'A' in the string (1-based)
    local charWidth = subtitleW / #subtitle
    local aX = 200 - (subtitleW / 2) + (aIndex - 1) * charWidth + charWidth * 1.465
    local aY = subtitleY + ui.altText_font:getHeight() / 2
    gfx.setLineWidth(2)
    gfx.drawCircleAtPoint(aX + 2, aY, charWidth * 0.45)
    gfx.setLineWidth(1)
end

function menu_scene:AButtonDown()
    -- Switch to game scene
    if _G.switchToGameScene then
        _G.switchToGameScene()
    end
end

return menu_scene
