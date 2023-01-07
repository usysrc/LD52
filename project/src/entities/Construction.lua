local const = require("src.const")
local Item = require("src.entities.Item")

return function(game)
    return {
        x = -16,
        y = 4 * 12,
        size = 16,
        menu = {
            Item.Expando(game, 1, 1)
        },
        isCraftable = function(self, item)
            local foundables = {}
            local craftable
            for itemName, amount in pairs(item.needs) do
                local found
                for item in all(game.player.inventory) do
                    if item.name == itemName and item.amount >= amount then
                        found = item
                    end
                end
                if not found then
                    craftable = false
                    break
                else
                    add(foundables, found)
                    craftable = true
                end
                return craftable
            end
        end,
        mousepressed = function(self, mx, my, btn)
            local mx, my = mx / const.zoom, my / const.zoom
            local k = 0
            for j = 1, 2 do
                for i = 1, 8 do
                    k = k + 1
                    local x, y = self.x + i * self.size, self.y + j * self.size
                    if mx > x and mx < x + self.size and my > y and my < y + self.size then
                        if btn == 1 then
                            -- TODO: build item
                            if not self.menu[k] then return end
                            if self:isCraftable(self.menu[k]) then
                                for itemName, amount in pairs(self.menu[k].needs) do
                                    for item in all(game.player.inventory) do
                                        if item.name == itemName and item.amount >= amount then
                                            item.amount = item.amount - amount
                                            if item.amount <= 0 then
                                                del(game.player.inventory, item)
                                            end
                                        end
                                    end
                                end
                                add(game.player.inventory, Item[self.menu[k].name](game, 1, 1))
                            end

                        end
                    end
                end
            end
        end,
        draw = function(self)
            love.graphics.setColor(1, 1, 1)
            local k = 0
            for i = 1, 2 do
                for j = 1, 8 do
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
                        love.graphics.rectangle("line", x, y, self.size * const.zoom, self.size * const.zoom)
                    end
                    local item = self.menu[k]
                    if item then
                        if self:isCraftable(item) then
                            love.graphics.setColor(1, 1, 1)
                        else
                            love.graphics.setColor(1, 1, 1, 0.3)
                        end
                        love.graphics.draw(item.img, x, y, 0, const.zoom, const.zoom)
                        love.graphics.setColor(1, 1, 1)
                    end

                end
            end
        end,
    }
end
