-- scenes/slide_transition_scene.lua
local gfx <const> = playdate.graphics
local slide_transition_scene = {}

-- Use global menu_scene and highscore_scene for transition
local menu_scene = _G.menu_scene
local highscore_scene = _G.highscore_scene

local DURATION = 0.5 -- seconds
local FPS = 30
local TOTAL_FRAMES = math.floor(DURATION * FPS)

function slide_transition_scene:enter(direction)
    self.frame = 0
    self.direction = direction or 1 -- 1 for right, -1 for left
    self.menu_scene = _G.menu_scene
    self.highscore_scene = _G.highscore_scene
    self.starfield = _G.sharedStarfield
    self.width = _G.SCREEN_WIDTH
    self.height = _G.SCREEN_HEIGHT
end

function slide_transition_scene:update()
    self.frame = self.frame + 1
    if self.frame >= TOTAL_FRAMES then
        if self.direction == 1 then
            if _G.switchToHighScoreScene then _G.switchToHighScoreScene() end
        else
            if _G.switchToMenuScene then _G.switchToMenuScene() end
        end
    end
end

function slide_transition_scene:draw()
    local width = self.width or (_G and _G.SCREEN_WIDTH) or 400
    local height = self.height or (_G and _G.SCREEN_HEIGHT) or 240
    local t = math.min((self.frame or 0) / (TOTAL_FRAMES or 1), 1)
    local slide = t * width
    local menuX, highscoreX, starfieldX
    if self.direction == 1 then
        -- Menu -> Highscore (left to right)
        menuX = -slide
        highscoreX = width - slide
        starfieldX = t * (2 * width)
    else
        -- Highscore -> Menu (right to left)
        menuX = -width + slide
        highscoreX = slide
        starfieldX = (1 - t) * (2 * width)
    end
    if self.starfield and self.starfield.draw then
        self.starfield:draw(width/2 + starfieldX, height/2, 3 * width, height)
    end
    if _G.menu_scene and _G.menu_scene.draw then
        _G.menu_scene:draw(menuX, true)
    end
    if _G.highscore_scene and _G.highscore_scene.draw then
        _G.highscore_scene:draw(highscoreX, true)
    end
end

return slide_transition_scene
