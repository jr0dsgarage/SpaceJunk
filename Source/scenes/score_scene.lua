---
-- Score scene module for displaying stats and handling high score entry.
-- Draws a single rounded rectangle for stats and manages initials input.
-- @module score_scene
-- @usage
--   local score_scene = require("scenes.score_scene")
--   score_scene:enter(finalScore, isHighScore)

local gfx <const> = playdate.graphics -- Playdate graphics module
local score_scene = {} -- Table for score scene methods and state

-- Constants for layout and spacing
local INITIALS_X_CENTER = 200 -- X center for initials input
local INITIALS_X_SPACING = 40 -- Spacing between initials
local INITIALS_Y_OFFSET = 26 -- Y offset for initials
local LINE_Y_OFFSET = 24 -- Y offset for lines
local TITLE_Y = 80 -- Y position for title
local STATS_Y = 140 -- Y position for stats box

-- Constants for layout and logic
local INITIALS_COUNT = 3 -- Number of initials
local INITIALS_START = {'A', ' ', ' '} -- Default initials
local YOFFSET_INITIALS = -40 -- Y offset for initials input
local LINE_HALF_WIDTH = 12 -- Half width for lines
local LINE_THICKNESS = 3 -- Thickness for lines
local CRANK_SENSITIVITY = 2 -- Sensitivity for crank input

local TUNE_BASE_FREQS <const> = {523.25, 587.33, 659.25, 698.46, 783.99} -- C5, D5, E5, F5, G5
local TUNE_DURATION <const> = 0.12 -- Duration of each note in the tune
local TUNE_VOLUME <const> = 0.5 -- Volume of the tune
local TUNE_OCTAVE_RATIO <const> = 2 -- One octave up for high score
local TUNE_BASS_RATIO <const> = 0.25 -- Two octaves down for bass

--- Play the score scene tune, with octave shift for high scores.
-- @param isHighScore Boolean, true if new high score
local function playScoreTune(isHighScore)
    local melodySynth = playdate.sound.synth.new(playdate.sound.kWaveSquare)
    local bassSynth = playdate.sound.synth.new(playdate.sound.kWaveSquare)
    for i, f in ipairs(TUNE_BASE_FREQS) do
        local melodyFreq = isHighScore and (f * TUNE_OCTAVE_RATIO) or f
        local bassFreq = melodyFreq * TUNE_BASS_RATIO
        local duration = (i == #TUNE_BASE_FREQS) and (TUNE_DURATION * 2) or TUNE_DURATION
        playdate.timer.performAfterDelay((i-1)*TUNE_DURATION*1000, function()
            melodySynth:playNote(melodyFreq, duration, TUNE_VOLUME)
            bassSynth:playNote(bassFreq, duration, TUNE_VOLUME)
        end)
    end
end

function score_scene:enter(finalScore, caught, missed)
    
    self.starfield = _G.sharedStarfield
    self.finalScore = finalScore or 0
    self.caught = caught or 0
    self.missed = missed or 0
    
    self.isNewHighScore = false
    self.enteringInitials = false
    self.initialsChars = {' '} -- Start with space as blank entry
    for i = 65, 90 do table.insert(self.initialsChars, string.char(i)) end -- A-Z
    for i = 48, 57 do table.insert(self.initialsChars, string.char(i)) end -- 0-9
    self.initials = {table.unpack(INITIALS_START)}
    self.initialsIndex = 1
    self.blinkTimer = 0
    if _G.HighScores then
        local entriesBefore = _G.HighScores.load()
        _G.HighScores.add(self.finalScore or 0, "   ") -- add with blank initials for now
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
        -- Make crank less sensitive
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

function score_scene:draw()
    -- Move everything up if entering initials
    local yOffset = (self.enteringInitials and self.isNewHighScore) and YOFFSET_INITIALS or 0
    -- Title background and text (match menu)
    local titleY = TITLE_Y + yOffset
    _G.drawBanner.draw("GAME OVER", INITIALS_X_CENTER, titleY, _G.ui.titleText_font, _G.TITLE_BANNER_PAD)
    if self.isNewHighScore then
        gfx.setFont(_G.ui.altText_font)
        local blink = (math.floor((self.blinkTimer or 0)/20) % 2) == 0
        local nhsText = "New High Score!"
        if blink then
            _G.drawBanner.draw(nhsText, INITIALS_X_CENTER, titleY + 28, _G.ui.altText_font, _G.SUBTITLE_BANNER_PAD)
        end
        -- Show initials at the bottom of the screen if initials have been entered
        if not self.enteringInitials then
            local initialsStr = table.concat(self.initials)
            local bottomY = (_G.SCREEN_HEIGHT or 240) - 32
            _G.drawBanner.draw(initialsStr, INITIALS_X_CENTER, bottomY, _G.ui.titleText_font, _G.TITLE_BANNER_PAD)
        end
    end
    -- Score/Stats background and text (single black rounded box)
    local statsFont = _G.ui.altText_font
    local statsY = STATS_Y + yOffset
    local scoreStr = string.format("SCORE: %d", self.finalScore)
    local caughtStr = string.format("CAUGHT: %d", self.caught)
    local missedStr = string.format("MISSED: %d", self.missed)
    local statsSpacing = statsFont:getHeight() + 2
    -- Calculate bounding box for all three lines
    local boxWidth = 128
    local boxHeight = statsSpacing * 3 + 10
    local boxX = INITIALS_X_CENTER - boxWidth/2 
    local boxY = statsY - statsFont:getHeight()/2 
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRoundRect(boxX, boxY, boxWidth, boxHeight, 12)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setFont(statsFont)
    gfx.drawTextAligned(scoreStr, INITIALS_X_CENTER, statsY, kTextAlignment.center)
    gfx.drawTextAligned(caughtStr, INITIALS_X_CENTER, statsY + statsSpacing, kTextAlignment.center)
    gfx.drawTextAligned(missedStr, INITIALS_X_CENTER, statsY + statsSpacing * 2, kTextAlignment.center)
    if self.enteringInitials then
        -- Enter initials UI
        local instr = "Enter Initials"
        local instrY = INSTR_Y + yOffset
        _G.drawBanner.draw(instr, INITIALS_X_CENTER, instrY, _G.ui.altText_font, _G.SUBTITLE_BANNER_PAD)
        -- Draw banner behind initials input using drawBanner
        local initialsY = instrY + INITIALS_Y_OFFSET
        local bannerWidth = (INITIALS_COUNT - 1) * INITIALS_X_SPACING + 48 -- 48 for padding and char width
        local bannerHeight = 120
        local bannerX = INITIALS_X_CENTER
        local bannerY = initialsY 
        _G.drawBanner.draw("", bannerX, bannerY + bannerHeight/2, nil, bannerWidth/2) -- empty string, just for background
        -- Draw initials input
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite) -- Ensure initials are drawn in white
        gfx.setFont(_G.ui.titleText_font)
        local blink = (math.floor((self.blinkTimer or 0)/20) % 2) == 0
        for i = 1, INITIALS_COUNT do
            local x = INITIALS_X_CENTER + (i-2)*INITIALS_X_SPACING
            local char = self.initials[i]
            gfx.drawTextAligned((char ~= '' and char or '_'), x, initialsY, kTextAlignment.center)
        end
        -- Draw lines under each character
        for i = 1, INITIALS_COUNT do
            local x = INITIALS_X_CENTER + (i-2)*INITIALS_X_SPACING
            local lineY = initialsY + LINE_Y_OFFSET
            if i == self.initialsIndex and blink then
                -- Blinking underline
                gfx.setColor(gfx.kColorWhite)
            else
                gfx.setColor(gfx.kColorWhite)
                gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
            end
            gfx.setLineWidth(LINE_THICKNESS)
            gfx.drawLine(x - LINE_HALF_WIDTH, lineY, x + LINE_HALF_WIDTH, lineY)
            gfx.setLineWidth(1)
            gfx.setColor(gfx.kColorWhite)
            gfx.setDitherPattern(1.0, gfx.image.kDitherTypeBayer8x8)
        end
        gfx.setImageDrawMode(gfx.kDrawModeCopy) -- Reset draw mode after initials
    else
        -- Instructions background and text, left/right aligned at bottom
        if _G.drawBanner and _G.drawBanner.drawAligned then
            _G.drawBanner.drawAligned("B: Main Menu", _G.INSTR_LEFT_X, _G.INSTR_Y, kTextAlignment.left, _G.ui.altText_font, _G.INSTR_BANNER_PAD)
            _G.drawBanner.drawAligned("A: Play Again", _G.INSTR_RIGHT_X, _G.INSTR_Y, kTextAlignment.right, _G.ui.altText_font, _G.INSTR_BANNER_PAD)
        end
    end
end

-- Add basic error handling for HighScores
function score_scene:AButtonDown()
    if self.enteringInitials then
        if self.initialsIndex < 3 then
            self.initialsIndex = self.initialsIndex + 1
            -- Pre-fill the next initial with the current one 
            self.initials[self.initialsIndex] = self.initials[self.initialsIndex - 1]
        else
            -- Save initials with score
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
        -- Remove the current starfield instance
        _G.sharedStarfield = nil
        if _G.switchToMenuScene then
            _G.switchToMenuScene()
        end
    end
end

return score_scene
