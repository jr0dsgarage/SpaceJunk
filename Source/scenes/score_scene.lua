-- scenes/score_scene.lua
local gfx <const> = playdate.graphics
local score_scene = {}

-- Constants for layout and spacing
local INITIALS_X_CENTER = 200
local INITIALS_X_SPACING = 40
local INITIALS_Y_OFFSET = 26
local LINE_Y_OFFSET = 24
local TITLE_Y = 80
local STATS_Y = 140

-- Constants for layout and logic
local INITIALS_COUNT = 3
local INITIALS_START = {'A', 'A', 'A'}
local BLINK_OFFSET = 44
local YOFFSET_INITIALS = -40
local LINE_HALF_WIDTH = 12
local LINE_THICKNESS = 3
local CRANK_SENSITIVITY = 2

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
    _G.drawBanner.draw("GAME OVER", INITIALS_X_CENTER, titleY, _G.ui.titleText_font)
    if self.isNewHighScore then
        gfx.setFont(_G.ui.altText_font)
        local blink = (math.floor((self.blinkTimer or 0)/20) % 2) == 0
        local nhsText = "New High Score!"
        if blink then
            _G.drawBanner.draw(nhsText, INITIALS_X_CENTER, titleY + 28, _G.ui.altText_font)
        end
        -- Show initials below 'New High Score!' if initials have been entered
        if not self.enteringInitials then
            local initialsStr = table.concat(self.initials)
            local initialsY = titleY + BLINK_OFFSET
            _G.drawBanner.draw(initialsStr, INITIALS_X_CENTER, initialsY, _G.ui.altText_font)
        end
    end
    -- Score/Stats background and text (match subtitle style)
    local statsFont = _G.ui.altText_font
    local statsY = STATS_Y + yOffset
    local scoreStr = string.format("SCORE: %d", self.finalScore)
    local caughtStr = string.format("CAUGHT: %d", self.caught)
    local missedStr = string.format("MISSED: %d", self.missed)
    local statsSpacing = statsFont:getHeight() + 2
    _G.drawBanner.draw(scoreStr, INITIALS_X_CENTER, statsY, statsFont)
    _G.drawBanner.draw(caughtStr, INITIALS_X_CENTER, statsY + statsSpacing, statsFont)
    _G.drawBanner.draw(missedStr, INITIALS_X_CENTER, statsY + statsSpacing * 2, statsFont)
    if self.enteringInitials then
        -- Enter initials UI
        local instr = "Enter Initials"
        local instrY = INSTR_Y + yOffset
        _G.drawBanner.draw(instr, INITIALS_X_CENTER, instrY, _G.ui.altText_font)
        -- Draw initials input
        local initialsY = instrY + INITIALS_Y_OFFSET
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
            _G.drawBanner.drawAligned("B: Main Menu", _G.INSTR_LEFT_X, _G.INSTR_Y, kTextAlignment.left, _G.ui.altText_font)
            _G.drawBanner.drawAligned("A: Play Again", _G.INSTR_RIGHT_X, _G.INSTR_Y, kTextAlignment.right, _G.ui.altText_font)
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
        -- Create a new starfield when leaving the score scene
        if _G.Starfield then
            _G.sharedStarfield = _G.Starfield.new()
            _G.sharedStarfield.parallaxY = 120
        end
        if _G.switchToMenuScene then
            _G.switchToMenuScene()
        end
    end
end

return score_scene
