local HIGHSCORE_FILE = "highscores"
local MAX_SCORES = 5
local highscores = {}

function highscores.load()
    local scores = playdate.datastore.read(HIGHSCORE_FILE) or {}
    while #scores < MAX_SCORES do table.insert(scores, 0) end
    return scores
end

function highscores.save(scores)
    playdate.datastore.write(scores, HIGHSCORE_FILE, true)
end

function highscores.add(newScore)
    local scores = highscores.load()
    table.insert(scores, newScore)
    table.sort(scores, function(a, b) return a > b end)
    while #scores > MAX_SCORES do table.remove(scores) end
    highscores.save(scores)
end

function highscores.isNewHighScore(newScore)
    local scores = highscores.load()
    for _, score in ipairs(scores) do
        if newScore == score then return true end
    end
    return false
end

return highscores
