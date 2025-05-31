-- Source/scenes/instructions_scene.lua
local gfx <const> = playdate.graphics
local scene_manager = _G.scene_manager
local slide_transition_scene = _G.slide_transition_scene

local instructions = {
    "Use the D-pad to move the tractor beam.",
    "Turn the crank to adjust the beam's radius.",
    "Press A to activate the tractor beam and collect space junk.",
    "Catch space junk by matching the beam's radius to the object's size.",
    "Smaller objects and better size matches give higher scores.",
    "Avoid missing objects—missed junk will crack your screen!",
    "The game ends when the timer runs out.",
    "Try to get the highest score possible!"
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
    gfx.drawTextAligned("Instructions", (_G.SCREEN_WIDTH // 2) + xOffset, 10, kTextAlignment.center)
    local y = 40 - scrollY
    for i, line in ipairs(instructions) do
        gfx.drawTextAligned("• " .. line, 20 + xOffset, y + (i-1)*lineHeight, kTextAlignment.left)
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
