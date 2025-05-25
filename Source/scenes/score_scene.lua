-- scenes/score_scene.lua
local gfx <const> = playdate.graphics
local score_scene = {}

function score_scene:enter(finalScore, caught, missed)
    self.finalScore = finalScore or 0
    self.caught = caught or 0
    self.missed = missed or 0
    -- Create a full-screen sprite for drawing
    if self.bgSprite then self.bgSprite:remove() end
    local gfx <const> = playdate.graphics
    self.bgSprite = gfx.sprite.new()
    self.bgSprite:setCenter(0, 0)
    self.bgSprite:moveTo(0, 0)
    self.bgSprite:setZIndex(-100)
    self.bgSprite:setSize(400, 240)
    self.bgSprite.draw = function(_)
        score_scene:draw()
    end
    self.bgSprite:add()
end

function score_scene:leave()
    if self.bgSprite then self.bgSprite:remove() end
end

function score_scene:update()
    -- Nothing to update for static score screen
end

function score_scene:draw()
    local gfx <const> = playdate.graphics
    gfx.clear(gfx.kColorBlack)
    if not ui or not ui.titleText_font or not ui.altText_font then
        gfx.drawText("ERROR: UI/FONTS NOT LOADED", 20, 120)
        return
    end
    gfx.setFont(ui.titleText_font)
    gfx.setColor(gfx.kColorWhite)
    gfx.drawTextAligned("GAME OVER", 200, 60, kTextAlignment.center)
    gfx.setFont(ui.altText_font)
    gfx.drawTextAligned("SCORE: " .. tostring(self.finalScore), 200, 120, kTextAlignment.center)
    gfx.drawTextAligned("CAUGHT: " .. tostring(self.caught), 200, 150, kTextAlignment.center)
    gfx.drawTextAligned("MISSED: " .. tostring(self.missed), 200, 170, kTextAlignment.center)
    gfx.drawTextAligned("A: Play Again    B: Main Menu", 200, 210, kTextAlignment.center)
end

function score_scene:AButtonDown()
    if _G.switchToGameScene then
        _G.switchToGameScene()
    end
end

function score_scene:BButtonDown()
    if _G.switchToMenuScene then
        _G.switchToMenuScene()
    end
end

return score_scene
