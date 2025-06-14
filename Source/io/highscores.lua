---
-- Highscores module for loading, saving, and managing high scores.
-- Handles persistent storage and high score logic.
-- @module highscores
-- @usage
--   local highscores = require("io.highscores")
--   local entries = highscores.load()

local HIGHSCORE_FILE = "highscores"
local MAX_SCORES = 10
local highscores = {}

--- Load high scores from persistent storage.
-- @return Array of high score entries
function highscores.load()
    local entries = playdate.datastore.read(HIGHSCORE_FILE) or {}
    -- Upgrade legacy numeric entries to {initials, score} tables
    for i = 1, #entries do
        if type(entries[i]) == "number" then
            entries[i] = { initials = "   ", score = entries[i] }
        end
    end
    while #entries < MAX_SCORES do table.insert(entries, {initials = "   ", score = 0}) end
    return entries
end

--- Save high scores to persistent storage.
-- @param entries Array of high score entries
function highscores.save(entries)
    playdate.datastore.write(entries, HIGHSCORE_FILE, true)
end

--- Add a new high score entry and sort the list.
-- @param newScore Score value
-- @param initials Player initials
function highscores.add(newScore, initials)
    local entries = highscores.load()
    table.insert(entries, {initials = initials or "   ", score = newScore})
    table.sort(entries, function(a, b) return a.score > b.score end)
    while #entries > MAX_SCORES do table.remove(entries) end
    highscores.save(entries)
end

--- Check if a score is a new high score.
-- @param newScore Score value
-- @return Boolean true if new high score
function highscores.isNewHighScore(newScore)
    local entries = highscores.load()
    for _, entry in ipairs(entries) do
        if newScore == entry.score then return true end
    end
    return false
end

--- Reset all high scores to default values.
function highscores.reset()
    local entries = {}
    for i = 1, MAX_SCORES do
        table.insert(entries, {initials = "AAA", score = 999})
    end
    highscores.save(entries)
end

return highscores
