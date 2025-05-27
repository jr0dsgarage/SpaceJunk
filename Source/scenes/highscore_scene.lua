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

function highscore_scene:update()
    -- Crank-based scrolling
    local crankChange = playdate.getCrankChange()
    if math.abs(crankChange) > 0 then
        self.scrollOffset = self.scrollOffset - crankChange * 0.05 -- adjust sensitivity as needed
        self.scrollOffset = math.max(0, math.min(self.scrollOffset, self.maxScroll))
    end
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
    -- Draw 5 visible scores, smoothly scrolled
    gfx.setColor(gfx.kColorWhite)
    local firstIdx = math.floor(self.scrollOffset) + 1
    local yOffset = -(self.scrollOffset % 1) * self.scoreHeight
    local hideThresholdY = 62 -- Hide scores above this y (just below title)
    for i = 0, self.maxVisible - 1 do
        local scoreIdx = firstIdx + i
        if self.scores[scoreIdx] then
            local y = self.listY0 + i * self.scoreHeight + yOffset
            if y > hideThresholdY then
                gfx.drawTextAligned(string.format("%d. %d", scoreIdx, self.scores[scoreIdx]), self.listX, y, kTextAlignment.center)
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
end

function highscore_scene:BButtonDown()
    if _G.switchToMenuScene then _G.switchToMenuScene() end
end

return highscore_scene
