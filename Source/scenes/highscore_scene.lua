---
-- Highscore scene module for displaying and managing high scores.
-- Draws a rounded rectangle for the score list and handles scrolling.
-- @module highscore_scene
-- @usage
--   local highscore_scene = require("scenes.highscore_scene")
--   highscore_scene:enter()

local gfx <const> = playdate.graphics -- Playdate graphics module
local highscore_scene = {} -- Table for highscore scene methods and state

-- Constants for layout and spacing
local TITLE_Y = 40 -- Y position for the title
local TITLE_X = 200 -- X position for the title
local LIST_W = 90 -- Width of the score list
local LIST_X = 200 -- X position for the score list
local LIST_Y0 = 80 -- Y position for the score list
local LIST_RECT_Y_OFFSET = -12-- Y offset for the list rectangle
local MAX_SCORES_SHOWN = 5 -- Maximum number of scores to show
local SCORE_HEIGHT = 25 -- Height of each score entry
local RESET_CONFIRM_Y = 136 -- Y position for reset confirmation
local RESET_CONFIRM2_Y = 166 -- Y position for second reset confirmation
local RESET_MSG_Y = 136 -- Y position for reset message
local SCORE_LIST_PAD = 8 -- Padding around the score list

--- Enter the highscore scene and load scores.
-- Initializes or resets the scene state and loads high scores from storage.
function highscore_scene:enter()
    -- Initialize/reset scene state
    self.scores = _G.HighScores and _G.HighScores.load() or {}
    self.scrollOffset = 0
    self.maxScroll = math.max(0, (#self.scores - MAX_SCORES_SHOWN))

end

-- Add support for drawing at an x offset for transition animations
--- Draw the highscore scene, with optional x offset for transitions.
-- @param xOffset X offset for transition animation
-- @param hideInstructions Boolean to hide instructions
function highscore_scene:draw(xOffset, hideInstructions)
    xOffset = xOffset or 0
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    gfx.setFont(ui.altText_font)
    local listRectX = LIST_X - LIST_W/2 - SCORE_LIST_PAD + xOffset
    local listRectY = LIST_Y0 + LIST_RECT_Y_OFFSET
    local listWidth = LIST_W + SCORE_LIST_PAD * 2
    local listHeight = MAX_SCORES_SHOWN * SCORE_HEIGHT - 2
    gfx.setColor(gfx.kColorBlack)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    if _G.drawBanner and _G.drawBanner.draw then
        _G.drawBanner.draw("", listRectX + listWidth/2, listRectY + listHeight/2, nil, listWidth/2, 2)
    end
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setColor(gfx.kColorWhite)
    self:drawScoreList(xOffset)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    -- Draw the HIGH SCORES banner
    if _G.drawBanner and _G.drawBanner.draw then
        _G.drawBanner.draw("HIGH SCORES", TITLE_X + xOffset, TITLE_Y, ui.titleText_font, _G.TITLE_BANNER_PAD,3)
    end
    if not hideInstructions and _G.drawBanner and _G.drawBanner.drawAligned then
        _G.drawBanner.drawAligned("<< Main Menu", _G.INSTR_LEFT_X + xOffset, _G.INSTR_Y, kTextAlignment.left, ui.altText_font, _G.INSTR_BANNER_PAD,1)
        _G.drawBanner.drawAligned("Crank for more scores!", _G.INSTR_RIGHT_X + xOffset, _G.INSTR_Y, kTextAlignment.right, ui.altText_font, _G.INSTR_BANNER_PAD,1)
    end
    if self.confirmingReset then
        -- Inline reset confirmation
        _G.drawBanner.draw("Really reset high scores?", TITLE_X, RESET_CONFIRM_Y, ui.altText_font, _G.SUBTITLE_BANNER_PAD,1)
        _G.drawBanner.draw("B: No     A: Yes", TITLE_X, RESET_CONFIRM2_Y, ui.altText_font, _G.SUBTITLE_BANNER_PAD,1)
    elseif self.showResetMsg and self.showResetMsg > 0 then
        -- Inline reset message
        _G.drawBanner.draw("High Scores Reset!", TITLE_X, RESET_MSG_Y, ui.altText_font, _G.SUBTITLE_BANNER_PAD,1)
    end
end

---
-- Draw the list of high scores, handling scrolling and column layout.
-- @param xOffset X offset for transition animation
function highscore_scene:drawScoreList(xOffset)
    local firstIdx = math.floor(self.scrollOffset or 0) + 1
    local scores = self.scores or {}
    -- Column layout
    local leftX = LIST_X - LIST_W/2 + SCORE_LIST_PAD + (xOffset or 0)
    local colNumW = SCORE_LIST_PAD - 5 -- width for scoreIdx column
    local colInitW = 38 -- width for initials column
    local colScoreW = 40 -- width for score column
    local listTop = LIST_Y0 + LIST_RECT_Y_OFFSET
    local listBottom = listTop + MAX_SCORES_SHOWN * SCORE_HEIGHT - 2
    local disappearOffset = 7 -- Make the first item disappear 5px sooner
    for i = 0, MAX_SCORES_SHOWN - 1 do
        local scoreIdx = firstIdx + i
        local entry = scores[scoreIdx]
        if entry and entry.score and entry.initials then
            local y = LIST_Y0 + i * SCORE_HEIGHT - (self.scrollOffset % 1) * SCORE_HEIGHT
            -- Only draw if within the visible bounds of the rounded rectangle, but disappear 5px sooner at the top
            if y >= (listTop + disappearOffset) and y < listBottom then
                local initials = entry.initials or "AAA"
                local score = entry.score or 0
                -- Draw columns: scoreIdx (right), initials (center), score (left)
                gfx.drawTextAligned(tostring(scoreIdx), leftX + colNumW, y, kTextAlignment.right)
                gfx.drawTextAligned(initials, leftX + colNumW + colInitW/2, y, kTextAlignment.center)
                gfx.drawTextAligned(tostring(score), leftX + colNumW + colInitW, y, kTextAlignment.left)
            end
        end
    end
end

---
-- Update the highscore scene, handling crank-based scrolling and reset logic.
function highscore_scene:update()
    -- Crank-based scrolling for the score list
    local crankChange = playdate.getCrankChange()
    if math.abs(crankChange) > 0 then
        self.scrollOffset = self.scrollOffset - crankChange * 0.009
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

---
-- Handle A button press. Confirms and performs high score reset if in confirmation state.
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

---
-- Handle left button press. Cancels reset confirmation or transitions to menu scene.
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

---
-- Handle B button press. Cancels reset confirmation or clears reset message.
function highscore_scene:BButtonDown()
    if self.confirmingReset then
        self.confirmingReset = false
        self.resetTimer = 0
        self.showResetMsg = 0 -- Clear any reset message
        return
    end
end

return highscore_scene
