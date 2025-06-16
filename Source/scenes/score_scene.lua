---
-- Score scene module for displaying stats and handling high score entry.
-- Draws a single rounded rectangle for stats and manages initials input.
-- @module score_scene
-- @usage
--   local score_scene = require("scenes.score_scene")
--   score_scene:enter(finalScore, isHighScore)

local gfx <const> = playdate.graphics -- Playdate graphics module
local score_scene = {} -- Table for score scene methods and state

-- General display/screen
local DISPLAY_SCREEN_HEIGHT = _G.SCREEN_HEIGHT or 240

-- Title and instruction layout
local TITLE_TEXT_Y = 80 -- Y position for title
local INITIALS_INSTRUCTION_Y = 200 -- Y position for instructions
local INSTRUCTION_TEXT_EXTRA_Y = 25 -- Move 'Enter Initials' text 25px lower

-- Initials input and banner layout
local INITIALS_INPUT_CENTER_X = 200 -- X center for initials input
local INITIALS_INPUT_Y_OFFSET = 26 -- Y offset for initials
local INITIALS_INPUT_EXTRA_Y = -5 -- Move initials entry 12px lower
local INITIALS_CHAR_SPACING_X = 40 -- Spacing between initials
local INITIALS_INPUT_BANNER_HEIGHT = 120 -- Height for initials input banner
local INITIALS_BANNER_BOTTOM_MARGIN = 27 -- Distance from bottom for initials banner
local INITIALS_BANNER_PADDING = 4 -- Padding for initials banner
local INITIALS_SCREEN_Y_SHIFT = -40 -- Y offset for initials input when entering

-- Initials/underline appearance
local INITIALS_COUNT = 3 -- Number of initials
local INITIALS_START = {'A', ' ', ' '} -- Default initials
local INITIALS_UNDERLINE_Y_OFFSET = 24 -- Y offset for lines
local INITIALS_UNDERLINE_HALF_WIDTH = 12 -- Half width for lines
local INITIALS_UNDERLINE_THICKNESS = 3 -- Thickness for lines

-- Stats box layout
local STATS_BOX_CENTER_Y = 140 -- Y position for stats box
local STATS_BOX_RECT_WIDTH = 128 -- Width of the stats box
local STATS_BOX_CORNER_RADIUS = 8 -- Radius for rounded corners
local STATS_BOX_EXTRA_PADDING = 10 -- For spacing below last stat

-- Logic
local CRANK_SENSITIVITY = 2 -- Sensitivity for crank input

function score_scene:enter(finalScore, caught, missed)
    self.starfield = _G.sharedStarfield
    self.finalScore = finalScore or 0
    self.caught = caught or 0
    self.missed = missed or 0
    self.isNewHighScore = false
    self.enteringInitials = false
    self.initialsChars = {' '}
    for i = 65, 90 do table.insert(self.initialsChars, string.char(i)) end -- A-Z
    for i = 48, 57 do table.insert(self.initialsChars, string.char(i)) end -- 0-9
    self.initials = {table.unpack(INITIALS_START)}
    self.initialsIndex = 1
    self.blinkTimer = 0
    if _G.HighScores then
        local entriesBefore = _G.HighScores.load()
        _G.HighScores.add(self.finalScore or 0, "   ")
        local entriesAfter = _G.HighScores.load()
        for i = 1, #entriesAfter do
            if entriesAfter[i].score ~= entriesBefore[i].score then
                self.isNewHighScore = (self.finalScore == entriesAfter[i].score)
                break
            end
        end
    end
    if self.isNewHighScore then
        self.enteringInitials = true
        self.initials = {table.unpack(INITIALS_START)}
        self.initialsIndex = 1
        self.blinkTimer = 0
    end
    if _G.SoundManager and _G.SoundManager.playScoreTune then
        _G.SoundManager:playScoreTune(self.isNewHighScore)
    elseif self.soundManager and self.soundManager.playScoreTune then
        self.soundManager:playScoreTune(self.isNewHighScore)
    end
end

function score_scene:update()
    if self.isNewHighScore then
        self.blinkTimer = (self.blinkTimer or 0) + 1
    end
    if self.enteringInitials then
        local crankChange = playdate.getCrankChange()
        local up = playdate.buttonJustPressed(playdate.kButtonUp)
        local down = playdate.buttonJustPressed(playdate.kButtonDown)
        local chars = self.initialsChars
        local idx = self.initialsIndex
        local crankStep = 0
        if math.abs(crankChange) >= CRANK_SENSITIVITY then
            crankStep = (crankChange > 0) and 1 or -1
        end
        if (crankStep ~= 0 or up or down) and idx >= 1 and idx <= INITIALS_COUNT then
            local curChar = self.initials[idx]
            local curPos = 1
            for i, c in ipairs(chars) do if c == curChar then curPos = i break end end
            local delta = 0
            if crankStep ~= 0 then delta = crankStep end
            if up then delta = delta + 1 end
            if down then delta = delta - 1 end
            if delta ~= 0 then
                curPos = ((curPos - 1 + delta) % #chars) + 1
                self.initials[idx] = chars[curPos]
            end
        end
    end
end

-- Helper: Draw the stats box (score/caught/missed)
local function drawStatsBox(centerX, y, font, score, caught, missed)
    local statsSpacing = font:getHeight() + 2
    local boxHeight = font:getHeight() * 3 + STATS_BOX_EXTRA_PADDING
    local boxX = centerX - STATS_BOX_RECT_WIDTH/2
    local boxY = y - font:getHeight() / 2
    local textOffset = 4
    gfx.setColor(gfx.kColorBlack)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    gfx.fillRoundRect(boxX, boxY, STATS_BOX_RECT_WIDTH, boxHeight, STATS_BOX_CORNER_RADIUS)
    gfx.setColor(gfx.kColorWhite)
    gfx.setLineWidth(1)
    gfx.drawRoundRect(boxX, boxY, STATS_BOX_RECT_WIDTH, boxHeight, STATS_BOX_CORNER_RADIUS)
    gfx.setLineWidth(1)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setFont(font)
    gfx.drawTextAligned(score, centerX, y-textOffset, kTextAlignment.center)
    gfx.drawTextAligned(caught, centerX, y-textOffset + statsSpacing, kTextAlignment.center)
    gfx.drawTextAligned(missed, centerX, y-textOffset + statsSpacing * 2, kTextAlignment.center)
end

-- Helper: Draw the initials input UI
local function drawInitialsInput(centerX, instrY, font, initials, initialsIndex, blink)
    local initialsY = instrY + INITIALS_INPUT_Y_OFFSET
    local bannerWidth = (INITIALS_COUNT - 1) * INITIALS_CHAR_SPACING_X + 48
    local bannerHeight = INITIALS_INPUT_BANNER_HEIGHT
    _G.drawBanner.draw("", centerX, initialsY + bannerHeight/2, nil, bannerWidth/2, 1)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setFont(font)
    for i = 1, INITIALS_COUNT do
        local x = centerX + (i-2)*INITIALS_CHAR_SPACING_X
        local char = initials[i]
        gfx.drawTextAligned((char ~= '' and char or '_'), x, initialsY, kTextAlignment.center)
    end
    for i = 1, INITIALS_COUNT do
        local x = centerX + (i-2)*INITIALS_CHAR_SPACING_X
        local lineY = initialsY + INITIALS_UNDERLINE_Y_OFFSET
        if i == initialsIndex and blink then
            gfx.setColor(gfx.kColorWhite)
        else
            gfx.setColor(gfx.kColorWhite)
            gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        end
        gfx.setLineWidth(INITIALS_UNDERLINE_THICKNESS)
        gfx.drawLine(x - INITIALS_UNDERLINE_HALF_WIDTH, lineY, x + INITIALS_UNDERLINE_HALF_WIDTH, lineY)
        gfx.setLineWidth(1)
        gfx.setColor(gfx.kColorWhite)
        gfx.setDitherPattern(1.0, gfx.image.kDitherTypeBayer8x8)
    end
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
end

-- Helper: Draw the initials banner at the bottom
local function drawInitialsBanner(centerX, screenHeight, initialsStr, scoreIdx, font)
    local displayStr = initialsStr
    if scoreIdx then
        displayStr = string.format("#%d %s", scoreIdx, initialsStr)
    end
    local bottomY = screenHeight - INITIALS_BANNER_BOTTOM_MARGIN
    _G.drawBanner.draw(displayStr, centerX, bottomY, font, INITIALS_BANNER_PADDING, 1)
end

function score_scene:draw()
    -- Move everything up if entering initials
    local yOffset = (self.enteringInitials and self.isNewHighScore) and INITIALS_SCREEN_Y_SHIFT or 0
    -- Title background and text (match menu)
    local titleY = TITLE_TEXT_Y + yOffset
    _G.drawBanner.draw("GAME OVER", INITIALS_INPUT_CENTER_X, titleY, _G.ui.titleText_font, _G.TITLE_BANNER_PAD, 3)
    if self.isNewHighScore then
        gfx.setFont(_G.ui.altText_font)
        local blink = (math.floor((self.blinkTimer or 0)/20) % 2) == 0
        local nhsText = "New High Score!"
        if blink then
            _G.drawBanner.draw(nhsText, INITIALS_INPUT_CENTER_X, titleY + 40, _G.ui.altText_font, _G.SUBTITLE_BANNER_PAD,1)
        end
        -- Show initials at the bottom of the screen if initials have been entered
        if not self.enteringInitials then
            local initialsStr = table.concat(self.initials)
            local entries = _G.HighScores and _G.HighScores.load() or {}
            local scoreIdx = nil
            for i, entry in ipairs(entries) do
                if entry.score == self.finalScore and entry.initials == initialsStr then
                    scoreIdx = i
                    break
                end
            end
            drawInitialsBanner(INITIALS_INPUT_CENTER_X, DISPLAY_SCREEN_HEIGHT, initialsStr, scoreIdx, _G.ui.titleText_font)
        end
    end
    -- Score/Stats background and text (single black rounded box)
    local statsFont = _G.ui.altText_font
    local statsY = STATS_BOX_CENTER_Y + yOffset + 10 -- Move box and text 10 pixels lower
    local scoreStr = string.format("SCORE: %d", self.finalScore)
    local caughtStr = string.format("CAUGHT: %d", self.caught)
    local missedStr = string.format("MISSED: %d", self.missed)
    drawStatsBox(INITIALS_INPUT_CENTER_X, statsY, statsFont, scoreStr, caughtStr, missedStr)
    if self.enteringInitials then
        -- Enter initials UI
        local instr = "Enter Initials"
        local instrY = INITIALS_INSTRUCTION_Y + yOffset + INSTRUCTION_TEXT_EXTRA_Y
        _G.drawBanner.draw(instr, INITIALS_INPUT_CENTER_X, instrY, _G.ui.altText_font, _G.SUBTITLE_BANNER_PAD, 1)
        drawInitialsInput(INITIALS_INPUT_CENTER_X, instrY + INITIALS_INPUT_EXTRA_Y, _G.ui.titleText_font, self.initials, self.initialsIndex, (math.floor((self.blinkTimer or 0)/20) % 2) == 0)
    else
        -- Instructions background and text, left/right aligned at bottom
        if _G.drawBanner and _G.drawBanner.drawAligned then
            _G.drawBanner.drawAligned("B: Main Menu", _G.INSTR_LEFT_X, _G.INSTR_Y, kTextAlignment.left, _G.ui.altText_font, _G.INSTR_BANNER_PAD,1)
            _G.drawBanner.drawAligned("A: Play Again", _G.INSTR_RIGHT_X, _G.INSTR_Y, kTextAlignment.right, _G.ui.altText_font, _G.INSTR_BANNER_PAD,1)
        end
    end
end

-- Add basic error handling for HighScores
function score_scene:AButtonDown()
    if self.enteringInitials then
        if self.initialsIndex < INITIALS_COUNT then
            self.initialsIndex = self.initialsIndex + 1
            self.initials[self.initialsIndex] = self.initials[self.initialsIndex - 1]
        else
            if _G.HighScores then
                local initialsStr = table.concat(self.initials)
                local ok, entries = pcall(_G.HighScores.load)
                if ok and entries then
                    local found = false
                    for i, entry in ipairs(entries) do
                        if entry.score == self.finalScore and entry.initials == "   " then
                            entry.initials = initialsStr
                            found = true
                            break
                        end
                    end
                    if found then
                        local saveOk, err = pcall(_G.HighScores.save, entries)
                        if not saveOk then
                            print("[HighScores] Error saving: " .. tostring(err))
                        end
                    else
                        print("[HighScores] Could not find placeholder entry to update initials.")
                    end
                else
                    print("[HighScores] Error loading entries: " .. tostring(entries))
                end
            end
            self.enteringInitials = false
        end
    else
        if _G.switchToGameScene then
            _G.switchToGameScene()
        end
    end
end

function score_scene:BButtonDown()
    if self.enteringInitials then
        if self.initialsIndex > 1 then
            self.initials[self.initialsIndex] = ' '
            self.initialsIndex = self.initialsIndex - 1
        end
    else
        _G.sharedStarfield = nil
        if _G.switchToMenuScene then
            _G.switchToMenuScene()
        end
    end
end

return score_scene
