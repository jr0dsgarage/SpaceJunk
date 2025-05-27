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
    self.scrollOffset = 0 -- float, 0 = top of list
    self.maxVisible = 5
    self.scoreHeight = 30
    self.listY0 = 80
    self.listX = 200
    self.listH = self.maxVisible * self.scoreHeight
    self.maxScroll = math.max(0, (#self.scores - self.maxVisible))
end

function highscore_scene:draw()
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, _G.SCREEN_WIDTH, _G.SCREEN_HEIGHT)
    if self.starfield then
        self.starfield:draw(_G.SCREEN_WIDTH/2, _G.SCREEN_HEIGHT/2, _G.SCREEN_WIDTH, _G.SCREEN_HEIGHT)
    end
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    -- Draw black rectangle behind the HIGH SCORES title
    local titleRectW, titleRectH = 240, 38
    local titleY = 40
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(_G.SCREEN_WIDTH/2 - titleRectW/2, titleY - 16, titleRectW, titleRectH)
    gfx.setColor(gfx.kColorWhite)
    gfx.setFont(ui.titleText_font)
    gfx.drawTextAligned("HIGH SCORES", 200, 40, kTextAlignment.center)
    gfx.setFont(ui.altText_font)
    -- Draw one black rectangle behind all high scores 
    local listRectW, listRectH = 180, self.maxVisible * self.scoreHeight - 2
    local listRectX = self.listX - listRectW/2
    local listRectY = self.listY0 - 4
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(listRectX, listRectY, listRectW, listRectH)
    -- Draw 5 visible scores, smoothly scrolled, initials then score
    gfx.setColor(gfx.kColorWhite)
    local firstIdx = math.floor(self.scrollOffset) + 1
    local yOffset = -(self.scrollOffset % 1) * self.scoreHeight
    local hideThresholdY = 62 -- Hide scores above this y (just below title)
    for i = 0, self.maxVisible - 1 do
        local scoreIdx = firstIdx + i
        local entry = self.scores[scoreIdx]
        if entry and entry.score and entry.initials then
            local y = self.listY0 + i * self.scoreHeight + yOffset
            if y > hideThresholdY then
                local initials = entry.initials or "   "
                local score = entry.score or 0
                gfx.drawTextAligned(string.format("%s  %d", initials, score), self.listX, y, kTextAlignment.center)
            end
        end
    end
    -- Draw bottom instructions: left and right aligned, with black rectangles
    gfx.setFont(ui.altText_font)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 216, 140, 20)
    gfx.fillRect(260, 216, 140, 20)
    gfx.setColor(gfx.kColorWhite)
    gfx.drawTextAligned("B: Back to Menu", 0, 220, kTextAlignment.left)
    gfx.drawTextAligned("Crank: Show more scores!", 400, 220, kTextAlignment.right)
    -- Draw reset confirmation or reset message if needed
    if self.confirmingReset then
        gfx.setFont(ui.altText_font)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(60, 120, 280, 48)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawTextAligned("Really reset high scores?", 200, 136, kTextAlignment.center)
        gfx.drawTextAligned("B: No     A: Yes", 200, 156, kTextAlignment.center)
    elseif self.showResetMsg and self.showResetMsg > 0 then
        gfx.setFont(ui.altText_font)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(100, 120, 200, 32)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawTextAligned("High Scores Reset!", 200, 136, kTextAlignment.center)
    end
end

function highscore_scene:update()
    -- Crank-based scrolling
    local crankChange = playdate.getCrankChange()
    if math.abs(crankChange) > 0 then
        self.scrollOffset = self.scrollOffset - crankChange * 0.05 -- adjust sensitivity as needed
        self.scrollOffset = math.max(0, math.min(self.scrollOffset, self.maxScroll))
    end
    -- Reset high scores: hold A+B for 2 seconds, then confirm
    self.resetTimer = self.resetTimer or 0
    if not self.confirmingReset then
        if playdate.buttonIsPressed(playdate.kButtonA) and playdate.buttonIsPressed(playdate.kButtonB) then
            self.resetTimer = self.resetTimer + 1
            if self.resetTimer == 60 then -- ~2 seconds at 30fps
                self.confirmingReset = true
            end
        else
            self.resetTimer = 0
        end
    end
    if self.showResetMsg and self.showResetMsg > 0 then
        self.showResetMsg = self.showResetMsg - 1
    end
end

function highscore_scene:AButtonDown()
    if self.confirmingReset then
        if _G.HighScores and _G.HighScores.reset then
            _G.HighScores.reset()
            self.scores = _G.HighScores.load()
            self.scrollOffset = 0
            self.showResetMsg = 60 -- show message for 2 seconds
        end
        self.confirmingReset = false
        self.resetTimer = 0
    end
end

function highscore_scene:BButtonDown()
    if self.confirmingReset then
        self.confirmingReset = false
        self.resetTimer = 0
        return
    end
    if _G.switchToMenuScene then _G.switchToMenuScene() end
end

return highscore_scene
