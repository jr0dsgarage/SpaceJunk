---
-- Helper to load the JWST Advanced Deep Extragalactic Survey image from the space_images directory.
-- @function loadDeepspaceImage
-- @return Playdate image object or nil if loading fails
local gfx <const> = playdate.graphics
local function loadDeepspaceImage()
    local imgPath = "sprites/space_images/deep_space/JWST Advanced Deep Extragalactic Survey_transparent.png"
    local ok, img = pcall(function() return gfx.image.new(imgPath) end)
    if ok and img then
        return img
    end
    return nil
end
return loadDeepspaceImage
