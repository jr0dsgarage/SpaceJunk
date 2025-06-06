local gfx <const> = playdate.graphics

local test_scene = {}

function test_scene:enter()
    -- Use the globally initialized starfield (behind everything)
    self.starfield = _G.sharedStarfield
    -- Load the background_ship image for manual drawing
    self.bgImage = gfx.image.new("sprites/ui/background_ship.png")
end

function test_scene:leave()
    self.bgImage = nil
    self.starfield = nil
    playdate.graphics.sprite.removeAll()
end

function test_scene:update()
    -- No update logic needed for now
end

function test_scene:draw()
    -- Draw the starfield manually (behind all sprites)
    if self.starfield and self.starfield.draw then
        self.starfield:draw(_G.SCREEN_WIDTH/2, _G.SCREEN_HEIGHT/2, _G.SCREEN_WIDTH*3, _G.SCREEN_HEIGHT, 0, self.starfield.parallaxY)
    end
    -- Draw the background_ship image manually
    if self.bgImage then
        self.bgImage:draw(0, 0)
    end
end

function test_scene:usesSprites()
    return true
end

function test_scene:BButtonDown()
    -- Return to the main menu when B is pressed
    _G.switchToMenuScene()
end

return test_scene
