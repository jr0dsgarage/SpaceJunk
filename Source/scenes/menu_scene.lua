-- scenes/menu_scene.lua
local gfx <const> = playdate.graphics
local ui = _G.ui
local menu_scene = {}

function menu_scene:enter()
    -- Called when entering the menu scene
end

function menu_scene:update()
    -- Nothing to update for static menu
end

function menu_scene:draw()
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, 400, 240)
    -- Title
    if not ui.titleText_font then print("WARNING: ui.titleText_font is nil") end
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setColor(gfx.kColorWhite)
    gfx.setFont(ui.titleText_font)
    gfx.drawTextAligned("SPACE JUNK", 200, 80, kTextAlignment.center)
    -- Subtitle
    if not ui.altText_font then print("WARNING: ui.altText_font is nil") end
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setColor(gfx.kColorWhite)
    gfx.setFont(ui.altText_font)
    gfx.drawTextAligned("PRESS A TO START", 200, 140, kTextAlignment.center)
end

function menu_scene:AButtonDown()
    -- Switch to game scene
    if _G.switchToGameScene then
        _G.switchToGameScene()
    end
end

return menu_scene
