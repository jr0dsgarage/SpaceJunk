-- Source/scenes/instructions_scene.lua
local gfx <const> = playdate.graphics
local scene_manager = _G.scene_manager
local slide_transition_scene = _G.slide_transition_scene

local instructions = {
    "Use the D-pad to move the beam!",
    "Turn the crank to change beam focal point!",
    "Match focal point size to the junk size!",
    "Smaller junk = more points!",
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
    gfx.clear()
    gfx.setFont(gfx.getFont())
    gfx.setColor(gfx.kColorWhite)
    if _G.drawBanner and _G.drawBanner.draw then
        _G.drawBanner.draw("Instructions", (_G.SCREEN_WIDTH // 2) + xOffset, 10, (_G.ui and _G.ui.titleText_font) or nil)
    end
    -- Set font for instructions list
    if _G.ui and _G.ui.altText_font then
        gfx.setFont(_G.ui.altText_font)
    end
    local y = 40 - scrollY
    for i, line in ipairs(instructions) do
        gfx.drawTextAligned("- " .. line, 20 + xOffset, y + (i-1)*lineHeight, kTextAlignment.left)
    end
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
    if _G.scene_manager then
        _G.scene_manager.setScene(_G.menu_scene)
    end
end

return InstructionsScene
