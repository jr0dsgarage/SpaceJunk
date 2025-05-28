local gfx <const> = playdate.graphics
local highscore_scene = {}

-- Constants for layout and spacing
local TITLE_Y = 40
local TITLE_X = 200
local LIST_W = 180
local LIST_X = 200
local LIST_Y0 = 80
local LIST_RECT_Y_OFFSET = -4
local INSTR_Y = 220
local INSTR_LEFT_X = 0
local INSTR_RIGHT_X = 400
local RESET_CONFIRM_Y = 136
local RESET_CONFIRM2_Y = 156
local RESET_MSG_Y = 136

function highscore_scene:enter()
    if _G.sharedStarfield then
        self.starfield = _G.sharedStarfield
    else
        self.starfield = _G.Starfield.new(_G.SCREEN_WIDTH, _G.SCREEN_HEIGHT, 50)
        _G.sharedStarfield = self.starfield
    end
    self.scores = _G.HighScores and _G.HighScores.load() or {}
    self.scrollOffset = 0
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
    -- Parallax starfield: move stars vertically based on scrollOffset
    local parallaxY = 0
    if self.scrollOffset and self.maxScroll and self.maxScroll > 0 then
        -- Map scrollOffset (0..maxScroll) to a parallax range, e.g., -16 to +16 px
        parallaxY = (self.scrollOffset / self.maxScroll - 0.5) * 32 -- center at 0
    end
    if self.starfield then
        self.starfield:draw(_G.SCREEN_WIDTH/2, _G.SCREEN_HEIGHT/2 + parallaxY, _G.SCREEN_WIDTH, _G.SCREEN_HEIGHT, parallaxY)
    end
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    -- Draw black rectangle and banner for the HIGH SCORES title using drawBanner
    _G.drawBanner.draw("HIGH SCORES", TITLE_X, TITLE_Y, ui.titleText_font)
    gfx.setFont(ui.altText_font)
    -- Draw one black rectangle behind all high scores (manual, not using drawBanner)
    local listRectW, listRectH = LIST_W, self.maxVisible * self.scoreHeight - 2
    local listRectX = LIST_X - listRectW/2
    local listRectY = LIST_Y0 + LIST_RECT_Y_OFFSET
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(listRectX, listRectY, listRectW, listRectH)
    -- Draw 5 visible scores, smoothly scrolled, initials then score
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite) -- Ensure text is drawn in white
    gfx.setColor(gfx.kColorWhite)
    local firstIdx = math.floor(self.scrollOffset) + 1
    local yOffset = -(self.scrollOffset % 1) * self.scoreHeight
    local hideThresholdY = TITLE_Y + 22 -- Hide scores above this y (just below title)
    for i = 0, self.maxVisible - 1 do
        local scoreIdx = firstIdx + i
        local entry = self.scores[scoreIdx]
        if entry and entry.score and entry.initials then
            local y = LIST_Y0 + i * self.scoreHeight + yOffset
            if y > hideThresholdY then
                local initials = entry.initials or "   "
                local score = entry.score or 0
                gfx.drawTextAligned(string.format("%s  %d", initials, score), LIST_X, y, kTextAlignment.center)
            end
        end
    end
    gfx.setImageDrawMode(gfx.kDrawModeCopy) -- Reset draw mode after text
    -- Draw bottom instructions: left and right aligned, with black rectangles using drawBanner
    _G.drawBanner.drawAligned("< Back to Menu", INSTR_LEFT_X, INSTR_Y, kTextAlignment.left, ui.altText_font)
    _G.drawBanner.drawAligned("Crank: Show more scores!", INSTR_RIGHT_X, INSTR_Y, kTextAlignment.right, ui.altText_font)
    -- Draw reset confirmation or reset message if needed
    if self.confirmingReset then
        drawResetConfirmation()
    elseif self.showResetMsg and self.showResetMsg > 0 then
        drawResetMessage()
    end
end

-- Helper for reset confirmation
function drawResetConfirmation()
    _G.drawBanner.draw("Really reset high scores?", TITLE_X, RESET_CONFIRM_Y, ui.altText_font)
    _G.drawBanner.draw("B: No     A: Yes", TITLE_X, RESET_CONFIRM2_Y, ui.altText_font)
end

-- Helper for reset message
function drawResetMessage()
    _G.drawBanner.draw("High Scores Reset!", TITLE_X, RESET_MSG_Y, ui.altText_font)
end

function highscore_scene:update()
    -- Crank-based scrolling
    local crankChange = playdate.getCrankChange()
    if math.abs(crankChange) > 0 then
        self.scrollOffset = self.scrollOffset - crankChange * 0.04
        self.scrollOffset = math.max(0, math.min(self.scrollOffset, self.maxScroll))
    end
    -- Always update starfield parallax, not just on crank
    if self.starfield and self.starfield.setParallaxOffset then
        local parallaxY = 0
        if self.maxScroll > 0 then
            parallaxY = (self.scrollOffset / self.maxScroll - 0.5) * 32
        end
        self.starfield:setParallaxOffset(0, parallaxY)
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
            local ok, err = pcall(_G.HighScores.reset)
            if not ok then
                print("[HighScores] Error resetting: " .. tostring(err))
            end
            local loadOk, scores = pcall(_G.HighScores.load)
            if loadOk and scores then
                self.scores = scores
            else
                print("[HighScores] Error loading after reset: " .. tostring(scores))
            end
            self.scrollOffset = 0
            self.showResetMsg = 60 -- show message for 2 seconds
        end
        self.confirmingReset = false
        self.resetTimer = 0
    end
end


function highscore_scene:leftButtonDown()
    if self.confirmingReset then
        self.confirmingReset = false
        self.resetTimer = 0
        return
    end
    if _G.switchToMenuScene then _G.switchToMenuScene() end
end

function highscore_scene:BButtonDown()
    if self.confirmingReset then
        self.confirmingReset = false
        self.resetTimer = 0
        self.showResetMsg = 0 -- Clear any reset message
        return
    end
end

return highscore_scene
