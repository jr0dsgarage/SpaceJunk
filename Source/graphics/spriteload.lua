-- Loads all .png sprites from the sprites/ folder and returns a table of images indexed by filename (without extension)
local gfx <const> = playdate.graphics
local spriteDir = "sprites/junk"

local sprites = {}
-- No static spriteList: always load dynamically from spriteDir

local function tableLoad(spriteDirPath)
    local arr = {}
    local dirToUse = spriteDirPath or spriteDir
    print("[SpriteLoad] tableLoad called with dirToUse:", dirToUse)
    local files = playdate.file.listFiles(dirToUse)
    print("[SpriteLoad] Files found in dir:", dirToUse, files and #files or 0)
    local foundPdi = false
    -- First, try to load .pdi files (Playdate bundle)
    for _, filename in ipairs(files) do
        if filename:match("%.pdi$") then
            foundPdi = true
            local fullPath = dirToUse .. (dirToUse:sub(-1) == "/" and "" or "/") .. filename
            print("[SpriteLoad] Attempting to load image:", fullPath)
            local ok, img = pcall(function() return gfx.image.new(fullPath) end)
            if ok and img then
                table.insert(arr, img)
                print("[SpriteLoad] Loaded image:", fullPath)
            else
                print("[SpriteLoad] Error loading " .. filename .. " from " .. dirToUse)
            end
        end
    end
    -- If no .pdi files found, try .png (for dev mode)
    if not foundPdi then
        for _, filename in ipairs(files) do
            if filename:match("%.png$") then
                local fullPath = dirToUse .. (dirToUse:sub(-1) == "/" and "" or "/") .. filename
                print("[SpriteLoad] Attempting to load image:", fullPath)
                local ok, img = pcall(function() return gfx.image.new(fullPath) end)
                if ok and img then
                    table.insert(arr, img)
                    print("[SpriteLoad] Loaded image:", fullPath)
                else
                    print("[SpriteLoad] Error loading " .. filename .. " from " .. dirToUse)
                end
            end
        end
    end
    if #arr == 0 then
        print("[SpriteLoad] No PDI or PNG images found in directory: " .. tostring(dirToUse))
    end
    return arr
end

return setmetatable({
    tableLoad = tableLoad
}, { __index = sprites })
