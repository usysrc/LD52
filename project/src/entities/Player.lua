return function(game)
    local player = {
        x = 0,
        y = 0,
        vel = 100
    }

    player.update = function(self, dt)
        if love.keyboard.isDown("a") then
            self.x = self.x - dt * self.vel
        end
        if love.keyboard.isDown("d") then
            self.x = self.x + dt * self.vel
        end
        if love.keyboard.isDown("w") then
            self.y = self.y - dt * self.vel
        end
        if love.keyboard.isDown("s") then
            self.y = self.y + dt * self.vel
        end

        -- lerp the camera to the postion of player
        local dx, dy = (self.x - game.cam.x) * dt, (self.y - game.cam.y) * dt
        game.cam:lookAt(game.cam.x + dx, game.cam.y + dy)
    end

    player.draw = function(self)
        love.graphics.draw(Image.player, self.x, self.y)
    end

    player.keypressed = function(self, key)

    end

    return player
end
