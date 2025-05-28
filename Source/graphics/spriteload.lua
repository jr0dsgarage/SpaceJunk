-- Loads all .png sprites from the sprites/ folder and returns a table of images indexed by filename (without extension)
local gfx <const> = playdate.graphics
local spriteDir = "sprites/"
local spriteList = {
    "bin.png",
    "bottle.png",
    "dish.png",
    "helmet.png",
    "monitor.png",
    "paper.png"
    -- Add more sprite filenames here as needed
}

local sprites = {}
for _, filename in ipairs(spriteList) do
    local name = filename:match("(.+)%.png$")
    local ok, img = pcall(function() return gfx.image.new(spriteDir .. filename) end)
    if ok and img then
        sprites[name] = img
    else
        print("[SpriteLoad] Error loading " .. filename)
    end
end

local function tableLoad()
    local arr = {}
    for _, filename in ipairs(spriteList) do
        local name = filename:match("(.+)%.png$")
        if sprites[name] then
            table.insert(arr, sprites[name])
        end
    end
    return arr
end

return setmetatable({
    tableLoad = tableLoad
}, { __index = sprites })
