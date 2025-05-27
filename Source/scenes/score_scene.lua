-- scenes/score_scene.lua
local gfx <const> = playdate.graphics
local score_scene = {}
local TimerBar = import "ui/timer_bar.lua"
local ScoreboardBar = import "ui/scoreboard_bar.lua"

function score_scene:enter(finalScore, caught, missed)
    self.finalScore = finalScore or 0
    self.caught = caught or 0
    self.missed = missed or 0
    if _G.sharedStarfield then
        self.starfield = _G.sharedStarfield
    else
        self.starfield = _G.Starfield.new(_G.SCREEN_WIDTH, _G.SCREEN_HEIGHT, 50)
        _G.sharedStarfield = self.starfield
    end
end

function score_scene:leave()
    self.starfield = nil
end

function score_scene:update()
    -- Nothing to update for static score screen
end

function score_scene:draw()
    -- Fill background and draw starfield
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, 400, 240)
    if self.starfield then
        self.starfield:draw(_G.SCREEN_WIDTH/2, _G.SCREEN_HEIGHT/2, _G.SCREEN_WIDTH, _G.SCREEN_HEIGHT)
    end

    -- Title background and text (match menu)
    local titleY = 80
    local titleRectW, titleRectH = 240, 38
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(_G.SCREEN_WIDTH/2 - titleRectW/2, titleY - 16, titleRectW, titleRectH)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setColor(gfx.kColorWhite)
    gfx.setFont(ui.titleText_font)
    gfx.drawTextAligned("GAME OVER", 200, titleY, kTextAlignment.center)

    -- Score/Stats background and text (match subtitle style)
    local stats = string.format("  SCORE: %d\nCAUGHT: %d\n MISSED: %d", self.finalScore, self.caught, self.missed)
    local statsW, statsH = gfx.getTextSize(stats)
    local statsRectW, statsRectH = statsW + 24, statsH + 8
    local statsY = 140
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(200 - statsRectW/2, statsY - 4, statsRectW, statsRectH)
    gfx.setColor(gfx.kColorWhite)
    gfx.setFont(ui.altText_font)
    gfx.drawTextAligned(stats, 200, statsY, kTextAlignment.center)

    -- Instructions background and text
    local instr = "B: Main Menu    A: Play Again"
    local instrW, instrH = gfx.getTextSize(instr)
    local instrRectW, instrRectH = instrW + 24, instrH + 8
    local instrY = 200
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(200 - instrRectW/2, instrY - 4, instrRectW, instrRectH)
    gfx.setColor(gfx.kColorWhite)
    gfx.setFont(ui.altText_font)
    gfx.drawTextAligned(instr, 200, instrY, kTextAlignment.center)
end

function score_scene:AButtonDown()
    if _G.switchToGameScene then
        _G.switchToGameScene()
    end
end

function score_scene:BButtonDown()
    if _G.switchToMenuScene then
        _G.switchToMenuScene()
    end
end

return score_scene
