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
    
    -- Paper dimensions
    local paperX = 4 + xOffset
    local paperY = 4
    local paperW = (_G.SCREEN_WIDTH or 400) - 8
    local paperH = (_G.SCREEN_HEIGHT or 240) - 4 - 20
    -- Draw paper background
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(paperX, paperY, paperW, paperH, 8)
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(2)
    gfx.drawRoundRect(paperX, paperY, paperW, paperH, 8)
    -- Title
    if _G.drawBanner and _G.drawBanner.draw then
        _G.drawBanner.draw("Instructions", (_G.SCREEN_WIDTH // 2) + xOffset, paperY + 10, (_G.ui and _G.ui.titleText_font) or nil)
    end
    -- Set font for instructions list
    if _G.ui and _G.ui.altText_font then
        gfx.setFont(_G.ui.altText_font)
    end
    local y = paperY + 40 - scrollY
    for i, line in ipairs(instructions) do
        gfx.drawTextAligned("- " .. line, paperX + 16, y + (i-1)*lineHeight, kTextAlignment.left)
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
    if _G.scene_manager and _G.slide_transition_scene then
        -- Use direction -3 for instructions -> menu (slide out left, matching menu <- instructions in)
        _G.scene_manager.setScene(_G.slide_transition_scene, -3)
    end
end

return InstructionsScene
