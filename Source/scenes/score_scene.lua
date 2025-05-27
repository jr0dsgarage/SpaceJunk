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
    self.isNewHighScore = false
    self.enteringInitials = false
    self.initialsChars = {' '} -- Start with space as blank entry
    for i = 65, 90 do table.insert(self.initialsChars, string.char(i)) end -- A-Z
    for i = 48, 57 do table.insert(self.initialsChars, string.char(i)) end -- 0-9
    self.initials = {' ', ' ', ' '}
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
        self.initials = {' ', ' ', ' '}
        self.initialsIndex = 1
        self.blinkTimer = 0
    end
end

function score_scene:leave()
    self.starfield = nil
end

function score_scene:update()
    if self.enteringInitials then
        self.blinkTimer = (self.blinkTimer or 0) + 1
        local crankChange = playdate.getCrankChange()
        local up = playdate.buttonJustPressed(playdate.kButtonUp)
        local down = playdate.buttonJustPressed(playdate.kButtonDown)
        local chars = self.initialsChars
        local idx = self.initialsIndex
        -- Make crank less sensitive
        local crankStep = 0
        if math.abs(crankChange) >= 2 then
            crankStep = (crankChange > 0) and 1 or -1
        end
        if (crankStep ~= 0 or up or down) and idx >= 1 and idx <= 3 then
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

function score_scene:AButtonDown()
    if self.enteringInitials then
        if self.initialsIndex < 3 then
            self.initialsIndex = self.initialsIndex + 1
            self.initials[self.initialsIndex] = self.initials[self.initialsIndex - 1]
        else
            -- Save initials with score
            if _G.HighScores then
                local initialsStr = table.concat(self.initials)
                -- Remove the placeholder blank-initials entry for this score
                local entries = _G.HighScores.load()
                for i, entry in ipairs(entries) do
                    if entry.score == self.finalScore and entry.initials == "   " then
                        entry.initials = initialsStr
                        break
                    end
                end
                _G.HighScores.save(entries)
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
            self.initials[self.initialsIndex] = 'A'
            self.initialsIndex = self.initialsIndex - 1
        end
    else
        if _G.switchToMenuScene then
            _G.switchToMenuScene()
        end
    end
end

function score_scene:draw()
    -- Fill background and draw starfield
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, 400, 240)
    if self.starfield then
        self.starfield:draw(_G.SCREEN_WIDTH/2, _G.SCREEN_HEIGHT/2, _G.SCREEN_WIDTH, _G.SCREEN_HEIGHT)
    end
    -- Move everything up if entering initials
    local yOffset = (self.enteringInitials and self.isNewHighScore) and -40 or 0
    -- Title background and text (match menu)
    local titleY = 80 + yOffset
    local titleRectW, titleRectH = 240, 38
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(_G.SCREEN_WIDTH/2 - titleRectW/2, titleY - 16, titleRectW, titleRectH)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setColor(gfx.kColorWhite)
    gfx.setFont(ui.titleText_font)
    gfx.drawTextAligned("GAME OVER", 200, titleY, kTextAlignment.center)
    if self.isNewHighScore then
        gfx.setFont(ui.altText_font)
        gfx.drawTextAligned("New High Score!", 200, titleY + 28, kTextAlignment.center)
        -- Show initials below 'New High Score!' if initials have been entered
        if not self.enteringInitials then
            gfx.setFont(ui.altText_font)
            local initialsStr = table.concat(self.initials)
            gfx.drawTextAligned(initialsStr, 200, titleY + 44, kTextAlignment.center)
        end
    end
    -- Score/Stats background and text (match subtitle style)
    local stats = string.format("  SCORE: %d\nCAUGHT: %d\n MISSED: %d", self.finalScore, self.caught, self.missed)
    local statsW, statsH = gfx.getTextSize(stats)
    local statsRectW, statsRectH = statsW + 24, statsH + 8
    local statsY = 140 + yOffset
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(200 - statsRectW/2, statsY - 4, statsRectW, statsRectH)
    gfx.setColor(gfx.kColorWhite)
    gfx.setFont(ui.altText_font)
    gfx.drawTextAligned(stats, 200, statsY, kTextAlignment.center)
    if self.enteringInitials then
        -- Enter initials UI
        local instr = "Enter Initials"
        local instrW, instrH = gfx.getTextSize(instr)
        local instrRectW, instrRectH = instrW + 24, instrH + 8
        local instrY = 200 + yOffset
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(200 - instrRectW/2, instrY - 4, instrRectW, instrRectH)
        gfx.setColor(gfx.kColorWhite)
        gfx.setFont(ui.altText_font)
        gfx.drawTextAligned(instr, 200, instrY, kTextAlignment.center)
        -- Draw initials input
        local initialsY = instrY + 26 -- was +32, now 6 pixels higher
        gfx.setFont(ui.titleText_font)
        local blink = (math.floor((self.blinkTimer or 0)/20) % 2) == 0
        for i = 1, 3 do
            local x = 200 + (i-2)*40
            local char = self.initials[i]
            gfx.drawTextAligned((char ~= '' and char or '_'), x, initialsY, kTextAlignment.center)
        end
        -- Draw lines under each character
        for i = 1, 3 do
            local x = 200 + (i-2)*40
            local lineY = initialsY + 24 -- was +18, now 6 pixels lower
            if i == self.initialsIndex and blink then
                -- Blinking underline
                gfx.setColor(gfx.kColorWhite)
            else
                gfx.setColor(gfx.kColorWhite)
                gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
            end
            gfx.setLineWidth(3)
            gfx.drawLine(x - 12, lineY, x + 12, lineY)
            gfx.setLineWidth(1)
            gfx.setColor(gfx.kColorWhite)
            gfx.setDitherPattern(1.0, gfx.image.kDitherTypeBayer8x8)
        end
    else
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
end

return score_scene
