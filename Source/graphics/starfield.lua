--- Starfield module for rendering a parallax starfield and background images.
-- @classmod Starfield

local gfx <const> = playdate.graphics
local loadDeepspaceImage = import("graphics/load_deepspace_image.lua")

local Starfield = {}
Starfield.__index = Starfield

local NUM_STARS = 150
local GRID_SIZE = 3

--- Load background images from the specified directory.
-- @return Table of loaded images.
local function loadBackgroundImages()
    local imgDir = "sprites/space_images"
    local files = playdate.file.listFiles(imgDir)
    local images = {}
    -- Prefer .pdi files (runtime), fallback to .png in dev
    for _, filename in ipairs(files) do
        if filename:match("%.pdi$") or filename:match("%.png$") then
            local fullPath = imgDir .. (imgDir:sub(-1) == "/" and "" or "/") .. filename
            local ok, img = pcall(function() return gfx.image.new(fullPath) end)
            if ok and img then
                table.insert(images, img)
            end
        end
    end
    return images
end

--- Create a new Starfield instance.
-- @return A new Starfield object.
function Starfield.new()
    local self = setmetatable({}, Starfield)
    self.width = (_G.SCREEN_WIDTH) * GRID_SIZE
    self.height = (_G.SCREEN_HEIGHT) * GRID_SIZE
    self.numStars = NUM_STARS
    self.stars = {}
    self.parallaxX = 0
    self.parallaxY = 0
    math.randomseed(playdate.getSecondsSinceEpoch())
    for i = 1, self.numStars do
        table.insert(self.stars, {
            x = math.random(0, self.width),
            y = math.random(0, self.height),
            size = math.random(1, 2)
        })
    end
    self.bgImages = loadBackgroundImages()
    if #self.bgImages > 0 then
        self.bgImage = self.bgImages[math.random(1, #self.bgImages)]
    else
        self.bgImage = nil
    end
    self.deepSpaceImage = loadDeepspaceImage()
    return self
end

--- Set the parallax offset for the starfield.
-- @param px Parallax X offset.
-- @param py Parallax Y offset.
function Starfield:setParallaxOffset(px, py)
    self.parallaxX = px or 0
    self.parallaxY = py or 0
end

--- Scroll the starfield vertically by a given amount.
-- @param dy Delta Y to scroll.
-- @param screenHeight Height of the screen.
function Starfield:scrollParallaxY(dy, screenHeight)
    local maxY = ((self.height or ((screenHeight or 240) * 3)) - (screenHeight or 240)) / 2
    local newY = (self.parallaxY or 0) + dy
    if maxY > 0 then
        newY = math.max(-maxY, math.min(newY, maxY))
    else
        newY = 0
    end
    self:setParallaxOffset(self.parallaxX or 0, newY)
end

--- Draw the starfield, background image, and space image.
-- @param centerX Center X position.
-- @param centerY Center Y position.
-- @param screenWidth Width of the screen.
-- @param screenHeight Height of the screen.
-- @param parallaxX Parallax X offset.
-- @param parallaxY Parallax Y offset.
function Starfield:draw(centerX, centerY, screenWidth, screenHeight, parallaxX, parallaxY)
    -- Only draw the background image if the current scene does NOT use sprites
    if not (_G.scene_manager and _G.scene_manager.usesSprites and _G.scene_manager.usesSprites()) then
        if self.bgImage then
            local sw = screenWidth or _G.SCREEN_WIDTH or 400
            local sh = screenHeight or _G.SCREEN_HEIGHT or 240
            local imgW, imgH = self.bgImage:getSize()
            -- Parallax for bgImage: max 1px in each direction, but invert direction to match stars
            local bg_dx = math.max(-1, math.min(1, -(parallaxX or self.parallaxX or 0) * 0.2))
            local bg_dy = math.max(-1, math.min(1, -(parallaxY or self.parallaxY or 0) * 0.2))
            local drawX = math.floor(sw/2 - imgW/2- imgW + bg_dx)
            local drawY = math.floor(sh/2 - imgH/2 + bg_dy)
            self.bgImage:draw(drawX, drawY)
        else
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRect(0, 0, screenWidth or _G.SCREEN_WIDTH or 400, screenHeight or _G.SCREEN_HEIGHT or 240)
        end
    end
    -- Always draw the JWST Advanced Deep Extragalactic Survey image 
    if self.deepSpaceImage then
        local sw = screenWidth or _G.SCREEN_WIDTH or 400
        local sh = screenHeight or _G.SCREEN_HEIGHT or 240
        local imgW, imgH = self.deepSpaceImage:getSize()
        local drawX = math.floor(sw/2 - imgW/2- imgW)
        local drawY = math.floor(sh/2 - imgH/2)
        self.deepSpaceImage:draw(drawX, drawY)
    end
    gfx.setColor(gfx.kColorWhite)
    local maxOffset = 3
    local dx, dy = 0, 0
    if centerX and centerY and screenWidth and screenHeight then
        dx = math.max(-maxOffset, math.min(maxOffset, (centerX - screenWidth/2) * 0.01))
        dy = math.max(-maxOffset, math.min(maxOffset, (centerY - screenHeight/2) * 0.01))
    end
    dx = dx + (parallaxX or self.parallaxX or 0)
    dy = dy + (parallaxY or self.parallaxY or 0)
    for i = 1, #self.stars do
        local px = self.stars[i].x - dx * self.stars[i].size
        local py = self.stars[i].y - dy * (self.stars[i].size == 1 and 1 or 1.5)
        if self.stars[i].size == 1 then
            gfx.drawPixel(px, py)
        else
            gfx.setLineWidth(1)
            gfx.drawLine(px - 2, py, px + 2, py)
            gfx.drawLine(px, py - 2, px, py + 2)
        end
    end
end

return Starfield
