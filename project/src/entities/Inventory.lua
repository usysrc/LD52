local const = require("src.const")
local TileObject = require("src.entities.TileObject")
return function(game)
    return {
        selected = 1,
        x = 16 * 16,
        y = -5 + (16 * 12),
        size = 16,
        wheelmoved = function(self, x, y)
            if y < 0 then
                self.selected = self.selected + 1
            else
                self.selected = self.selected - 1
            end
            if self.selected <= 0 then self.selected = 1 end
        end,

        mousepressedTileObject = function(self, mx, my, btn)
            local item = game.player.inventory[self.selected]
            if not item then return end
            if not item.placeable then return end
            local lx, ly = game.cam:mousePosition()
            local i, j = math.floor(lx / const.tilewidth), math.floor(ly / const.tileheight)
            local x, y = i * const.tilewidth,
                j * const.tileheight

            if btn == 1 and game.map:get(i, j, 0) then
                game.map:placeObject(i, j, TileObject[item.places.config.name])
                del(game.player.inventory, item)
            end
        end,
        mousepressed = function(self, mx, my, btn)
            self:mousepressedTileObject(mx, my, btn)

            local mx, my = mx / const.zoom, my / const.zoom
            local k = 0
            for j = 1, 4 do
                for i = 1, 8 do
                    k = k + 1
                    local x, y = self.x + i * self.size, self.y + j * self.size
                    if mx > x and mx < x + self.size and my > y and my < y + self.size then
                        if btn == 1 then
                            self.selected = k
                        elseif btn == 2 then
                            local item = game.player.inventory[k]
                            if item then
                                item.x = game.player.x - 20 + math.random() * 4
                                item.y = game.player.y + math.random() * 4
                                add(game.objects, item)
                                del(game.player.inventory, item)
                            end
                        end

                    end
                end
            end
        end,
        drawOnMap = function(self)
            local item = game.player.inventory[self.selected]
            if not item then return end
            if not item.placeable then return end
            local lx, ly = game.cam:mousePosition()
            local x, y = math.floor(lx / const.tilewidth) * const.tilewidth,
                math.floor(ly / const.tileheight) * const.tileheight
            love.graphics.setColor(0, 0, 0, 0.3)
            love.graphics.rectangle("fill", x, y, const.tilewidth, const.tileheight)
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(item.places.img, x, y)
        end,
        draw = function(self)
            -- love.graphics.scale(const.zoom, const.zoom)
            love.graphics.setColor(1, 1, 1)
            local k = 0
            for j = 1, 4 do
                for i = 1, 8 do
                    k = k + 1
                    local x, y = self.x + i * self.size, self.y + j * self.size
                    local x, y = x * const.zoom, y * const.zoom
                    love.graphics.draw(Image.frame, x, y, 0, const.zoom, const.zoom)
                    local lmx, lmy = love.mouse.getX(), love.mouse.getY()
                    if lmx > x and lmx < x + self.size * const.zoom and lmy > y and
                        lmy < y + self.size * const.zoom then
                        love.graphics.setColor(1, 1, 1, 0.2)
                        love.graphics.rectangle("fill", x, y, self.size * const.zoom, self.size * const.zoom)
                        love.graphics.setColor(1, 1, 1, 1)
                    end
                    local item = Game.player.inventory[k]
                    if item then
                        love.graphics.draw(item.img, x, y, 0, const.zoom, const.zoom)
                        if item.amount > 1 then
                            love.graphics.print(item.amount, x, y)
                        end
                    end
                    if k == self.selected then
                        love.graphics.setColor(1, 1, 1)
                        love.graphics.rectangle("line", x, y, self.size * const.zoom, self.size * const.zoom)
                    end
                end
            end
        end,
    }
end
