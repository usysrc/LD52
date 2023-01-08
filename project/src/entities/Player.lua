local const = require("src.const")
local Item  = require("src.entities.Item")

return function(game)
    local player = {
        x = 5 * const.tilewidth,
        y = 5 * const.tileheight,
        distance = 0,
        vel = 50,
        dir = 1,
        color = { 1, 1, 1 }
    }
    -- animation frames
    player.quads = {
        love.graphics.newQuad(0, 0, 32, 32, Image.player:getWidth(), Image.player:getHeight()),
        love.graphics.newQuad(32, 0, 32, 32, Image.player:getWidth(), Image.player:getHeight()),
        love.graphics.newQuad(64, 0, 32, 32, Image.player:getWidth(), Image.player:getHeight()),
        love.graphics.newQuad(96, 0, 32, 32, Image.player:getWidth(), Image.player:getHeight()),
    }

    player.quad = player.quads[1]

    player.frame = 0

    player.animationSpeed = 10

    player.inventory = {}

    player.update = function(self, dt)
        local x, y = 0, 0
        local moved = false
        if love.keyboard.isDown("a") then
            x = -dt * self.vel
            self.dir = -1
            moved = true
        end
        if love.keyboard.isDown("d") then
            x = dt * self.vel
            self.dir = 1
            moved = true
        end
        if love.keyboard.isDown("w") then
            y = -dt * self.vel
            moved = true
        end
        if love.keyboard.isDown("s") then
            y = dt * self.vel
            moved = true
        end
        if moved then
            self.frame = self.frame + dt * self.animationSpeed
            self.quad = self.quads[1 + math.floor(self.frame) % 3]

            -- constrain to game map
            local tx, ty = self.x + x, self.y + y
            local tile = game.map:get(math.floor(tx / const.tilewidth), math.floor(self.y / const.tileheight), 0)
            if tile then
                self.x = self.x + x
            end
            local tile = game.map:get(math.floor(self.x / const.tilewidth), math.floor(ty / const.tileheight), 0)
            if tile then
                self.y = self.y + y
            end
        end

        -- lerp the camera to the postion of player
        -- local lx, ly = game.cam:mousePosition()
        -- local dx, dy = (self.x - game.cam.x) * dt, (self.y - game.cam.y) * dt
        -- game.cam:lookAt(math.floor(game.cam.x + dx), math.floor(game.cam.y + dy))
        game.cam:lookAt(self.x, self.y)
    end

    player.draw = function(self)
        love.graphics.setColor(self.color)
        love.graphics.draw(Image.player, self.quad, self.x, self.y, 0, self.dir, 1, 16, 16)
    end

    player.keypressed = function(self, key)
        -- if key == "f" then
        --     local item = self.inventory[game.inventory.selected]
        --     if not item then return end
        --     if item.name == "Coin" then return end
        --     Sfx.sell:play()
        --     local found
        --     for inventoryItem in all(game.player.inventory) do
        --         if inventoryItem.name == "Coin" then
        --             inventoryItem.amount = inventoryItem.amount + (item.value or 1)
        --             found = true
        --         end
        --     end
        --     if not found then
        --         add(self.inventory, Item.Coin(game, 1, 1))
        --     end
        --     item.amount = item.amount - 1
        --     if item.amount <= 0 then
        --         del(self.inventory, item)
        --     end
        -- end
    end
    add(Game.objects, player)
    return player
end
