-- Source/starfield.lua

local gfx <const> = playdate.graphics

local Starfield = {}
Starfield.__index = Starfield

local NUM_STARS = 150
local GRID_SIZE = 3

-- Load background images from the specified directory
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
    return self
end

function Starfield:setParallaxOffset(px, py)
    self.parallaxX = px or 0
    self.parallaxY = py or 0
end

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

function Starfield:draw(centerX, centerY, screenWidth, screenHeight, parallaxX, parallaxY)
    -- Only draw the background image if the current scene does NOT use sprites
    if not (_G.scene_manager and _G.scene_manager.usesSprites and _G.scene_manager.usesSprites()) then
        if self.bgImage then
            local sw = screenWidth or _G.SCREEN_WIDTH or 400
            local sh = screenHeight or _G.SCREEN_HEIGHT or 240
            local imgW, imgH = self.bgImage:getSize()
            -- Draw so that the image center is at the center of the screen (0,0 is top left)
            local drawX = math.floor(0 )
            local drawY = math.floor(sh/2 - imgH/2)
            print("[Starfield] Drawing bgImage at (" .. drawX .. ", " .. drawY .. ") size: " .. imgW .. "x" .. imgH)
            self.bgImage:draw(drawX, drawY)
        else
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRect(0, 0, screenWidth or _G.SCREEN_WIDTH or 400, screenHeight or _G.SCREEN_HEIGHT or 240)
        end
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
