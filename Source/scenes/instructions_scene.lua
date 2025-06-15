---
-- Instructions scene module for displaying game instructions.
-- Draws instructions text and handles layout.
-- @module InstructionsScene
-- @usage
--   local InstructionsScene = require("scenes.instructions_scene")
--   InstructionsScene:draw()

local gfx <const> = playdate.graphics -- Playdate graphics module
local scene_manager = _G.scene_manager -- Reference to global scene manager
local slide_transition_scene = _G.slide_transition_scene -- Reference to global slide transition scene

local titleText = "Instructions" -- Title text for the instructions scene
local lineText = { -- Array of instruction lines to display
    "Use the D-pad to move the beam focal point!!",
    "Crank to change beam focal point distance!!",
    "Match focal point size to the junk size!!",
    "Catch smaller junk = score more points!",
    "Better size match = more points!",
    "Game ends when timer runs out...",
    "Go for a high score!",
    "Test",
    "Test 2",
    "Test 3",
    "Test 4",
}

local InstructionsScene = {} -- Table for instructions scene methods and state

--- Initialize the instructions scene (no-op).
function InstructionsScene.init() end

--- Update the instructions scene (no-op).
function InstructionsScene.update() end

--- Draw the instructions scene, with optional x offset for transitions.
-- @param xOffset X offset for transition animation
-- @param hideInstructions Boolean to hide instructions
function InstructionsScene:draw(xOffset, hideInstructions)
    xOffset = xOffset or 0
    -- Paper dimensions
    local paperX = 4 + xOffset
    local paperY = 4
    local paperW = (_G.SCREEN_WIDTH or 400) - 8
    local paperH = (_G.SCREEN_HEIGHT or 240) - 4 - 20
    local titleFont = _G.ui and _G.ui.titleText_font or nil
    local lineFont = _G.ui and _G.ui.altText_font or nil
    _G.PaperBG.draw(
        paperX, paperY, paperW, paperH,
        {
            titleText = titleText,
            lineText = lineText,
            titleFont = titleFont,
            lineFont = lineFont,
            dither = 0.93,
            cornerRadius = 8,
            borderWidth = 2,
            visibleLines = 7,
        }
    )
    if not hideInstructions and _G.drawBanner and _G.drawBanner.drawAligned then
        _G.drawBanner.drawAligned("Main Menu >", _G.INSTR_RIGHT_X + xOffset, _G.INSTR_Y, kTextAlignment.right, (_G.ui and _G.ui.altText_font) or nil, _G.INSTR_BANNER_PAD, 1)
    end
end

function InstructionsScene.cranked(change, accelerated) end

function InstructionsScene.upButtonDown() end

function InstructionsScene.downButtonDown() end

function InstructionsScene.rightButtonDown()
    if _G.scene_manager and _G.slide_transition_scene then
        _G.scene_manager.setScene(_G.slide_transition_scene, -3)
    end
end

return InstructionsScene
