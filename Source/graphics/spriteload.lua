---
-- Sprite loader module for loading all .png or .pdi sprites from a directory.
-- Returns a table of images indexed by filename (without extension).
-- @module spriteload
-- @usage
--   local spriteload = require("graphics.spriteload")
--   local images = spriteload.tableLoad("sprites/junk")

local gfx <const> = playdate.graphics -- Playdate graphics module
local spriteDir = "sprites/junk" -- Default directory for junk sprites

local sprites = {} -- Table for loaded sprites
-- No static spriteList: always load dynamically from spriteDir

--- Load all .pdi images from the given directory.
-- @param spriteDirPath Optional directory path to load from
-- @return Array of Playdate image objects
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
