-- scenes/slide_transition_scene.lua
local gfx <const> = playdate.graphics
local slide_transition_scene = {}

local DURATION = 0.5 -- seconds
local FPS = 30
local TOTAL_FRAMES = math.floor(DURATION * FPS)

function slide_transition_scene:enter(direction)
    self.frame = 0
    self.direction = direction or 1
    self.menu_scene = _G.menu_scene
    self.highscore_scene = _G.highscore_scene
    self.instructions_scene = _G.instructions_scene
    self.starfield = _G.sharedStarfield
    self.width = _G.SCREEN_WIDTH
    self.height = _G.SCREEN_HEIGHT

    -- Map directions to scene pairs for cleaner logic
    local transitions = {
        [-2] = {from = self.menu_scene, to = self.instructions_scene},
        [-3] = {from = self.instructions_scene, to = self.menu_scene},
        [1]  = {from = self.menu_scene, to = self.highscore_scene},
        [-1] = {from = self.highscore_scene, to = self.menu_scene}
    }
    local scene_pair = transitions[self.direction]
    if scene_pair then
        self.fromScene = scene_pair.from
        self.toScene = scene_pair.to
    else
        self.fromScene = self.menu_scene
        self.toScene = self.highscore_scene
    end
end

function slide_transition_scene:update()
    self.frame = self.frame + 1
    if self.frame >= TOTAL_FRAMES then
        local actions = {
            [-2] = function() if _G.scene_manager then _G.scene_manager.setScene(_G.instructions_scene) end end,
            [-3] = function() if _G.scene_manager then _G.scene_manager.setScene(_G.menu_scene) end end,
            [1]  = function() if _G.scene_manager then _G.scene_manager.setScene(_G.highscore_scene) end end,
            [-1] = function() if _G.scene_manager then _G.scene_manager.setScene(_G.menu_scene) end end,
        }
        local action = actions[self.direction]
        if action then action() end
    end
end

function slide_transition_scene:draw()
    local width = self.width or (_G and _G.SCREEN_WIDTH) or 400
    local height = self.height or (_G and _G.SCREEN_HEIGHT) or 240
    local t = math.min((self.frame or 0) / (TOTAL_FRAMES or 1), 1)
    local slide = t * width
    local fromX, toX, starfieldX
    local drawFuncs = {
        [-2] = function()
            -- Menu -> Instructions (instructions slide in from left)
            fromX = 0 + slide
            toX = -width + slide
            starfieldX = -t * (2 * width)
        end,
        [-3] = function()
            -- Instructions -> Menu (instructions slide out left)
            fromX = 0 - slide
            toX = width - slide
            starfieldX = -(2 * width) + t * (2 * width)
        end,
        [1] = function()
            -- Menu -> Highscore (highscore slides in from right)
            fromX = -slide
            toX = width - slide
            starfieldX = t * (2 * width)
        end,
        [-1] = function()
            -- Highscore -> Menu (highscore slides out right, menu slides in from left)
            fromX = 0 + slide
            toX = -width + slide
            starfieldX = (1 - t) * (2 * width)
        end
    }
    local func = drawFuncs[self.direction]
    if func then
        func()
    else
        fromX = 0
        toX = 0
        starfieldX = 0
    end
    -- Only draw the starfield if the scene manager didn't already draw it
    -- (i.e., temporarily clear the background to black, don't double-draw)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, width, height)
    local starfield = _G.sharedStarfield
    if starfield and starfield.draw then
        local starfieldDrawX = (width * 1.5) + starfieldX
        starfield:draw(starfieldDrawX, height/2, 3 * width, height)
    end
    if self.fromScene and self.fromScene.draw then
        self.fromScene:draw(fromX, true)
    end
    if self.toScene and self.toScene.draw then
        self.toScene:draw(toX, true)
    end
end

return slide_transition_scene
