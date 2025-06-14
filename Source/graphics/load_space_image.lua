-- Helper to load a specific image from the space_images directory
local gfx <const> = playdate.graphics
local function loadSpaceImage()
    local imgPath = "sprites/space_images/JWST Advanced Deep Extragalactic Survey_transparent.png"
    print(string.format("Loading space image from: %s\n", imgPath))
    local ok, img = pcall(function() return gfx.image.new(imgPath) end)
    if ok and img then
        return img
    end
    return nil
end
return loadSpaceImage
