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
    -- Only create a new starfield if one does not already exist
    if not _G.sharedStarfield then
        _G.sharedStarfield = _G.Starfield.new((_G.SCREEN_WIDTH or 400) * 3, _G.SCREEN_HEIGHT or 240, 150)
    end
    self.starfield = _G.sharedStarfield
    self.scores = _G.HighScores and _G.HighScores.load() or {}
    self.scrollOffset = 0
    self.maxVisible = 5
    self.scoreHeight = 30
    self.listY0 = 80
    self.listX = 200
    self.listH = self.maxVisible * self.scoreHeight
    self.maxScroll = math.max(0, (#self.scores - self.maxVisible))
    -- Do NOT set starfield vertical parallax here; let update() handle it for smoothness
end

-- Add support for drawing at an x offset for transition animations
function highscore_scene:draw(xOffset, hideInstructions)
    xOffset = xOffset or 0
    -- Defensive: ensure all required fields are set
    local width = _G.SCREEN_WIDTH or 400
    local height = _G.SCREEN_HEIGHT or 240
    local listW = LIST_W or 180
    local listH = (self.maxVisible and self.scoreHeight) and (self.maxVisible * self.scoreHeight - 2) or 148
    local listX = LIST_X or 200
    local listY0 = LIST_Y0 or 80
    local listRectYOffset = LIST_RECT_Y_OFFSET or -4
    local titleX = TITLE_X or 200
    local titleY = TITLE_Y or 40
    local instrLeftX = INSTR_LEFT_X or 0
    local instrRightX = INSTR_RIGHT_X or 400
    local instrY = INSTR_Y or 220
    local statsFont = ui and ui.altText_font or gfx.getFont()
    local scores = self.scores or {}
    local maxVisible = self.maxVisible or 5
    local scoreHeight = self.scoreHeight or 30
    local scrollOffset = self.scrollOffset or 0
    local maxScroll = self.maxScroll or 0
    local hideThresholdY = titleY + 22
    local yOffset = -(scrollOffset % 1) * scoreHeight
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    -- Remove any full-screen black fill or color set at the start
    -- Only draw black rectangles for UI elements (like the high score list background), not the whole screen
    gfx.setFont(statsFont)
    local listRectX = listX - listW/2 + xOffset
    local listRectY = listY0 + listRectYOffset
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(listRectX, listRectY, listW, listH)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setColor(gfx.kColorWhite)
    local firstIdx = math.floor(scrollOffset) + 1
    for i = 0, maxVisible - 1 do
        local scoreIdx = firstIdx + i
        local entry = scores[scoreIdx]
        if entry and entry.score and entry.initials then
            local y = listY0 + i * scoreHeight + yOffset
            if y > hideThresholdY then
                local initials = entry.initials or "   "
                local score = entry.score or 0
                gfx.drawTextAligned(string.format("%s  %d", initials, score), listX + xOffset, y, kTextAlignment.center)
            end
        end
    end
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    -- Draw the HIGH SCORES banner
    if _G.drawBanner and _G.drawBanner.draw then
        _G.drawBanner.draw("HIGH SCORES", (TITLE_X or 200) + xOffset, (TITLE_Y or 40), ui and ui.titleText_font or nil)
    end
    if not hideInstructions and _G.drawBanner and _G.drawBanner.drawAligned then
        _G.drawBanner.drawAligned("< Back to Menu", instrLeftX + xOffset, instrY, kTextAlignment.left, statsFont)
        _G.drawBanner.drawAligned("Crank: Show more scores!", instrRightX + xOffset, instrY, kTextAlignment.right, statsFont)
    end
    if self.confirmingReset and type(drawResetConfirmation) == "function" then
        drawResetConfirmation()
    elseif self.showResetMsg and self.showResetMsg > 0 and type(drawResetMessage) == "function" then
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
    --[[
    if self.starfield and self.starfield.setParallaxOffset then
        local parallaxY = 0
        if self.maxScroll > 0 then
            parallaxY = (self.scrollOffset / self.maxScroll - 0.5) * 32
        end
        self.starfield:setParallaxOffset(0, parallaxY)
    end
    ]]
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
    -- Trigger slide transition back to menu (right-to-left)
    if _G.scene_manager and _G.slide_transition_scene then
        _G.scene_manager.setScene(_G.slide_transition_scene, -1)
    else
        if _G.switchToMenuScene then _G.switchToMenuScene() end
    end
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
