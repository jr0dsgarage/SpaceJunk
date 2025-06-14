---
-- Helper to load a specific image from the space_images directory.
-- Always loads the JWST Advanced Deep Extragalactic Survey image.
-- @function loadSpaceImage
-- @return Playdate image object or nil if loading fails
local gfx <const> = playdate.graphics
local function loadSpaceImage()
    local imgPath = "sprites/space_images/JWST Advanced Deep Extragalactic Survey_transparent.png"
    local ok, img = pcall(function() return gfx.image.new(imgPath) end)
    if ok and img then
        return img
    end
    return nil
end
return loadSpaceImage
