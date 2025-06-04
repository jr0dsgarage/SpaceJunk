-- Source/scenes/instructions_scene.lua
local gfx <const> = playdate.graphics
local scene_manager = _G.scene_manager
local slide_transition_scene = _G.slide_transition_scene

local titleText = "Instructions"
local lineText = {
    "Use the D-pad to move the beam focal point!!",
    "Crank to change beam focal point distance!!",
    "Match focal point size to the junk size!!",
    "Catch smaller junk = score more points!",
    "Better size match = more points!",
    "Game ends when timer runs out...",
    "Go for a high score!"
}

local visibleLines = 7

local InstructionsScene = {}

function InstructionsScene.init()
    _G.PaperBG.setScrollParams(#lineText, visibleLines)
    _G.PaperBG.scrollOffset = 0
end

function InstructionsScene.update()
    -- Clamp scrollOffset in PaperBG
    if _G.PaperBG.scrollOffset < 0 then _G.PaperBG.scrollOffset = 0 end
    if _G.PaperBG.scrollOffset > _G.PaperBG.maxScroll then
        _G.PaperBG.scrollOffset = _G.PaperBG.maxScroll
    end
end

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
            scrollOffset = _G.PaperBG.scrollOffset,
            visibleLines = visibleLines,
        }
    )
    if not hideInstructions and _G.drawBanner and _G.drawBanner.drawAligned then
        _G.drawBanner.drawAligned("Main Menu >", _G.INSTR_RIGHT_X + xOffset, _G.INSTR_Y, kTextAlignment.right, (_G.ui and _G.ui.altText_font) or nil)
    end
end

function InstructionsScene.cranked(change, accelerated)
    _G.PaperBG.cranked(change)
end

function InstructionsScene.upButtonDown()
    _G.PaperBG.upButtonDown()
end

function InstructionsScene.downButtonDown()
    _G.PaperBG.downButtonDown()
end

function InstructionsScene.rightButtonDown()
    if _G.scene_manager and _G.slide_transition_scene then
        _G.scene_manager.setScene(_G.slide_transition_scene, -3)
    end
end

return InstructionsScene
