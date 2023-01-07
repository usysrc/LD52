local const = require("src.const")
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
        mousepressed = function(self, mx, my, btn)
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
