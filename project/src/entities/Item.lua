local const = require "src.const"
local vector = requireLibrary("hump.vector")

local Item = function(game, x, y, img, config)
    local item = {
        x = x,
        y = y,
        amount = 1,
        img = img,
        distance = 0,
        update = function(self, dt)
            if vector.new(self.x, self.y):dist(vector.new(game.player.x, game.player.y)) < 16 then
                del(game.objects, self)
                local found
                for item in all(game.player.inventory) do
                    if item.name == self.name then
                        item.amount = item.amount + 1
                        found = true
                    end
                end
                if not found then
                    add(game.player.inventory, self)
                end
            end
        end,
        draw = function(self)
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(self.img, self.x, self.y)
        end
    }
    for k, v in pairs(config) do
        item[k] = v
    end
    return item
end

return {
    Stone = function(game, x, y)
        return Item(game, x, y, Image.stone, {
            name = "Stone",
        })
    end,
    Wood = function(game, x, y)
        return Item(game, x, y, Image.wood, {
            name = "Wood"
        })
    end
}
