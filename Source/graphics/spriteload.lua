-- Loads all .png sprites from the sprites/ folder and returns a table of images indexed by filename (without extension)
local gfx <const> = playdate.graphics
local spriteDir = "sprites/junk"

local sprites = {}
-- No static spriteList: always load dynamically from spriteDir

local function tableLoad(spriteDirPath)
    local spriteArray = {}
    local dirToUse = spriteDirPath or spriteDir
    local files = playdate.file.listFiles(dirToUse)
    local foundPdi = false
    -- First, try to load .pdi files (Playdate bundle)
    for _, filename in ipairs(files) do
        if filename:match("%.pdi$") then
            foundPdi = true
            local fullPath = dirToUse .. (dirToUse:sub(-1) == "/" and "" or "/") .. filename
            local ok, img = pcall(function() return gfx.image.new(fullPath) end)
            if ok and img then
                table.insert(spriteArray, img)
            end
        end
    end
    return spriteArray
end

return setmetatable({
    tableLoad = tableLoad
}, { __index = sprites })
