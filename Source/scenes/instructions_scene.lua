-- Source/scenes/instructions_scene.lua
local gfx <const> = playdate.graphics
local scene_manager = _G.scene_manager
local slide_transition_scene = _G.slide_transition_scene

local instructions = {
    "Use the D-pad to move the beam focal point!!",
    "Crank to change beam focal point distance!",
    "Match focal point size to the junk size!",
    "Catch smaller junk = score more points!",
    "Better size match = more points!",
    "Game ends when timer runs out...",
    "Go for a high score!"
}

local scrollY = 0
local lineHeight = 18
local visibleLines = 7
local totalHeight = #instructions * lineHeight

local InstructionsScene = {}

function InstructionsScene.init()
    scrollY = 0
end

function InstructionsScene.update()
    -- Clamp scrollY
    if scrollY < 0 then scrollY = 0 end
    if scrollY > totalHeight - visibleLines * lineHeight then
        scrollY = math.max(0, totalHeight - visibleLines * lineHeight)
    end
end

function InstructionsScene:draw(xOffset, hideInstructions)
    xOffset = xOffset or 0
    
    -- Paper dimensions
    local paperX = 4 + xOffset
    local paperY = 4
    local paperW = (_G.SCREEN_WIDTH or 400) - 8
    local paperH = (_G.SCREEN_HEIGHT or 240) - 4 - 20
    
    -- Prepare title and instruction lines for PaperBG
    local titleText = "Instructions"
    local lineText = instructions
    local titleFont = _G.ui and _G.ui.titleText_font or nil
    local lineFont = _G.ui and _G.ui.altText_font or nil
    -- Draw paper background and all text using PaperBG class
    _G.PaperBG.draw(
        paperX, paperY, paperW, paperH,
        {
            titleText = titleText,
            lineText = lineText,
            titleFont = titleFont,
            lineFont = lineFont,
            dither = 0.85,
            cornerRadius = 8,
            borderWidth = 2,
        }
    )
    if not hideInstructions and _G.drawBanner and _G.drawBanner.drawAligned then
        _G.drawBanner.drawAligned("Main Menu >", _G.INSTR_RIGHT_X + xOffset, _G.INSTR_Y, kTextAlignment.right, (_G.ui and _G.ui.altText_font) or nil)
    end
end

function InstructionsScene.cranked(change, accelerated)
    scrollY = scrollY + math.floor(-change / 4)
end

function InstructionsScene.upButtonDown()
    scrollY = scrollY - lineHeight
end

function InstructionsScene.downButtonDown()
    scrollY = scrollY + lineHeight
end

function InstructionsScene.rightButtonDown()
    if _G.scene_manager and _G.slide_transition_scene then
        -- Use direction -3 for instructions -> menu (slide out left, matching menu <- instructions in)
        _G.scene_manager.setScene(_G.slide_transition_scene, -3)
    end
end

return InstructionsScene
