local timer = requireLibrary("hump.timer")
local const = require("src.const")
local vector = requireLibrary("hump.vector")

local TileObject = function(game, i, j, img, config)
    local tileObject = {
        i = i,
        j = j,
        x = i * const.tilewidth,
        y = j * const.tileheight,
        -- distance for z
        distance = const.tileheight * 0.85,
        r = 0,
        img = img or Image.tree,
        scaleY = 1,
        color = { 1, 1, 1 },
        time = 0,
        update = function(self, dt)
            self.time = self.time + dt
        end,
        mouseOver = function(self)
            local lx, ly = game.cam:mousePosition()
            if lx > self.x and lx < self.x + const.tilewidth and ly > self.y and ly < self.y + const.tileheight
                and
                vector.new(self.x + const.tilewidth / 2, self.y + const.tileheight / 2):dist(vector.new(game.player.x,
                    game.player.y))
                < 30 then
                return true
            end
        end,
        afterDestroy = function(self) end,
        mousepressed = function(self, x, y, btn)
            if btn == 1 and self:mouseOver() then

                timer.tween(0.1, self, { scaleY = 1.2 }, "quad", function()
                    timer.tween(0.4, self, { scaleY = 1 }, "bounce", function()
                    end)
                end)
                self.color = { 0, 0, 1 }
                timer.after(0.1, function()
                    self.color = { 1, 1, 1 }
                end)
                self.r = math.random() * 0.1
                timer.tween(0.5, self, { r = 0 }, "bounce")

                self.config.hp = self.config.hp - 1

                if self.config.hp <= 0 then
                    del(game.objects, self)
                    game.map:set(i, j, 1, nil)
                    self:afterDestroy()
                end
            end
        end,
        draw = function(self)
            if self:mouseOver() then
                love.graphics.draw(Image.selector, self.x, self.y + 9 + math.sin(self.time * 10))
                love.graphics.setColor(0, 0, 0)
                love.graphics.rectangle("fill", self.x + const.tilewidth / 2 - 8, self.y + const.tileheight + 12, 16, 5)
                love.graphics.setColor(1, 0, 0)
                love.graphics.rectangle("fill", self.x + const.tilewidth / 2 - 8, self.y + const.tileheight + 12,
                    16 * self.config.hp / self.config.maxhp, 4)
                love.graphics.setColor(1, 1, 1)
            end
            --love.graphics.rectangle("line", self.x, self.y, const.tilewidth, const.tilewidth)
            love.graphics.setColor(self.color)
            love.graphics.draw(self.img, self.x + const.tilewidth / 2, self.y + const.tileheight,
                self.r,
                1, self.scaleY,
                const.tilewidth / 2,
                const.tileheight)
        end
    }
    tileObject.config = {}
    for k, v in pairs(config) do
        tileObject.config[k] = v
    end
    return tileObject
end


return {
    Rock = function(game, i, j) return TileObject(game, i, j, Image.rock, { name = "rock", maxhp = 12, hp = 12 }) end,
    Tree = function(game, i, j) return TileObject(game, i, j, Image.tree, { name = "tree", maxhp = 8, hp = 8 }) end,
    Expander = function(game, i, j)
        local tile = TileObject(game, i, j, Image.expander, { name = "expander", maxhp = 8, hp = 8 })
        tile.afterDestroy = function(self)
            game.map:extend(i, j)
        end
        return tile
    end
}
