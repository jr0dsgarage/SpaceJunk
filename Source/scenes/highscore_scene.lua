local gfx <const> = playdate.graphics
local highscore_scene = {}

function highscore_scene:enter()
    if _G.sharedStarfield then
        self.starfield = _G.sharedStarfield
    else
        self.starfield = _G.Starfield.new(_G.SCREEN_WIDTH, _G.SCREEN_HEIGHT, 50)
        _G.sharedStarfield = self.starfield
    end
    self.scores = _G.HighScores and _G.HighScores.load() or {}
end

function highscore_scene:draw()
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, _G.SCREEN_WIDTH, _G.SCREEN_HEIGHT)
    if self.starfield then
        self.starfield:draw(_G.SCREEN_WIDTH/2, _G.SCREEN_HEIGHT/2, _G.SCREEN_WIDTH, _G.SCREEN_HEIGHT)
    end
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setColor(gfx.kColorWhite)
    gfx.setFont(ui.titleText_font)
    gfx.drawTextAligned("HIGH SCORES", 200, 40, kTextAlignment.center)
    gfx.setFont(ui.altText_font)
    for i, score in ipairs(self.scores) do
        local text = string.format("%d. %d", i, score)
        gfx.drawTextAligned(text, 200, 80 + (i-1)*30, kTextAlignment.center)
    end
    gfx.setFont(ui.altText_font)
    gfx.drawTextAligned("B: Back to Menu", 200, 220, kTextAlignment.center)
end

function highscore_scene:BButtonDown()
    if _G.switchToMenuScene then _G.switchToMenuScene() end
end

return highscore_scene
