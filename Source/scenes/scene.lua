---
-- Base Scene class providing a consistent lifecycle and helpers.
--
-- Usage (gradual migration example):
--   local Scene = import "scenes/scene"
--   local MenuScene = Scene:extend()
--   function MenuScene.new()
--       local self = Scene.new{ name = "Menu" }
--       return setmetatable(self, MenuScene)
--   end
--   function MenuScene:enter(prev) self:setUsesSprites(true) end
--   function MenuScene:draw() -- your draw code end
--   return MenuScene
--
-- The scene manager can keep calling: enter(prev), leave(next),
-- update(), draw(), usesSprites() and button handlers.

local gfx <const> = playdate.graphics

local Scene = {}
Scene.__index = Scene

--- Create a new Scene instance.
-- @tparam table opts optional fields: name (string), usesSprites (bool)
function Scene.new(opts)
    local self = setmetatable({}, Scene)
    self.name = opts and opts.name or "Scene"
    self._usesSprites = (opts and opts.usesSprites) or false
    self._sprites = {}
    self._timers = {}
    self._debug = false
    return self
end

--- Create a subclass of Scene.
function Scene:extend()
    local subclass = setmetatable({}, { __index = self })
    subclass.__index = subclass
    return subclass
end

-- Lifecycle ---------------------------------------------------------------

--- Called when the scene becomes active.
-- @param prev the previous scene
function Scene:enter(prev)
    -- override in subclass
end

--- Called when the scene is replaced or removed.
-- @param next the next scene
function Scene:leave(next)
    -- Clean up timers & sprites by default
    self:cancelAllTimers()
    self:removeAllSprites()
end

--- Update per-frame logic (non-sprite).
function Scene:update()
    -- override
end

--- Draw per-frame visuals (non-sprite).
function Scene:draw()
    -- override
end

--- Whether the Playdate sprite system should update/draw in this scene.
function Scene:usesSprites()
    return self._usesSprites
end

function Scene:setUsesSprites(b)
    self._usesSprites = not not b
end

-- Input (default no-ops) --------------------------------------------------
function Scene:AButtonDown() end
function Scene:BButtonDown() end
function Scene:leftButtonDown() end
function Scene:rightButtonDown() end
function Scene:cranked(change, acceleratedChange) end

-- Helpers: Sprites ---------------------------------------------------------

--- Register a sprite to be auto-removed on leave().
-- Accepts a gfx.sprite or any object with :add()/:remove()
function Scene:addSprite(s)
    if not s then return end
    table.insert(self._sprites, s)
    if s.add then s:add() end
end

function Scene:removeSprite(s)
    if not s then return end
    for i = #self._sprites, 1, -1 do
        if self._sprites[i] == s then
            if s.remove then s:remove() end
            table.remove(self._sprites, i)
            break
        end
    end
end

function Scene:removeAllSprites()
    for i = #self._sprites, 1, -1 do
        local s = self._sprites[i]
        if s and s.remove then s:remove() end
        self._sprites[i] = nil
    end
end

-- Helpers: Timers ----------------------------------------------------------

--- Track a timer to be cancelled on leave().
function Scene:addTimer(t)
    if not t then return end
    table.insert(self._timers, t)
end

function Scene:cancelAllTimers()
    for i = #self._timers, 1, -1 do
        local t = self._timers[i]
        if t and t.remove then t:remove() end
        self._timers[i] = nil
    end
end

_G.Scene = Scene
return Scene
