--[[
    GD50
    Super Mario Bros. Remake

    -- WinState Class --
]]

WinState = Class{__includes = BaseState}


function WinState:enter(params)

    self.score = params.score
    self.levelN = params.levelN
    
    self.camX = params.camX
    self.camY = params.camY
    self.level = params.level
    self.tileMap = self.level.tileMap
    self.background = params.background
    self.backgroundX = params.backgroundX

end

function WinState:init()

end

function WinState:update(dt)

    -- remove any nils from pickups, etc.
    self.level:clear()

    -- update player and level
    self.level:update(dt)
    self:updateCamera()

    
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('play', {
            levelN = self.levelN + 1,
            score = self.score
        })
    end

end

function WinState:render()
    love.graphics.push()
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX), 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX),
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256), 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256),
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    
    -- translate the entire view of the scene to emulate a camera
    love.graphics.translate(-math.floor(self.camX), -math.floor(self.camY))
    
    self.level:render()

    love.graphics.pop()
    
    -- render score
    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(tostring(self.score), 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(tostring(self.score), 4, 4)

    -- render level
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("Level: " .. tostring(self.levelN), (VIRTUAL_WIDTH/2 - 20), 5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Level: " .. tostring(self.levelN), (VIRTUAL_WIDTH/2 - 19), 4)

    love.graphics.setFont(gFonts['title'])
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.printf('EPIC WIN', 1, VIRTUAL_HEIGHT / 2 - 30 + 1, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.printf('EPIC WIN', 0, VIRTUAL_HEIGHT / 2 - 30, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.printf('Press Enter for next level', 1, VIRTUAL_HEIGHT / 2 + 41, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.printf('Press Enter for next level', 0, VIRTUAL_HEIGHT / 2 + 40, VIRTUAL_WIDTH, 'center')

end

function WinState:updateCamera()
    -- clamp movement of the camera's X between 0 and the map bounds - virtual width,
    -- setting it half the screen to the left of the player so they are in the center
    self.camX = math.max(0, TILE_SIZE * self.tileMap.width - VIRTUAL_WIDTH)

    -- adjust background X to move a third the rate of the camera for parallax
    self.backgroundX = (self.camX / 3) % 256
end
