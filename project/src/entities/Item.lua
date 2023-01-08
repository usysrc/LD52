local const = require "src.const"
local vector = requireLibrary("hump.vector")

local Item = function(game, x, y, img, config)
    local item = {
        duration = 1,
        x = x,
        y = y,
        amount = 1,
        img = img,
        distance = 0,
        update = function(self, dt)
            if vector.new(self.x, self.y):dist(vector.new(game.player.x, game.player.y)) < 16 then
                del(game.objects, self)
                Sfx.pickup:play()
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
            value = 1,
        })
    end,
    Gold = function(game, x, y)
        return Item(game, x, y, Image.gold, {
            name = "Gold",
            value = 2,
        })
    end,
    GoldIngot = function(game, x, y)
        return Item(game, x, y, Image.goldingot, {
            name = "GoldIngot",
            value = 5,
        })
    end,
    Coin = function(game, x, y)
        return Item(game, x, y, Image.coin, {
            name = "Coin",
            needs = {
                Stone = 1,
                Wood = 1,
                Gold = 1,
            },
        })
    end,
    WoodPick = function(game, x, y)
        return Item(game, x, y, Image.woodpick, {
            name = "WoodPick",
            value = 10,
            harvestBoost = 2,
            maxduration = 100,
            duration = 100,
            needs = {
                Wood = 3,
            },
        })
    end,
    StonePick = function(game, x, y)
        return Item(game, x, y, Image.pick, {
            name = "StonePick",
            value = 10,
            harvestBoost = 3,
            maxduration = 300,
            duration = 300,
            needs = {
                Stone = 6,
                Wood = 2,
            },
        })
    end,
    IronPick = function(game, x, y)
        return Item(game, x, y, Image.ironpick, {
            name = "IronPick",
            value = 10,
            harvestBoost = 4,
            maxduration = 500,
            duration = 500,
            needs = {
                Iron = 6,
                Wood = 2,
            },
        })
    end,
    Wood = function(game, x, y)
        return Item(game, x, y, Image.wood, {
            name = "Wood",
            value = 1
        })
    end,
    Iron = function(game, x, y)
        return Item(game, x, y, Image.iron, {
            name = "Iron",
            value = 1
        })
    end,
    Expander = function(game, x, y)
        local TileObject = require("src.entities.TileObject")

        return Item(game, x, y, Image.expando, {
            name = "Expander",
            needs = {
                Stone = 10,
                Wood = 10,
                Gold = 10,
                Iron = 10,
            },
            placeable = true,
            places = TileObject.Expander(game, 1, 1),
        })
    end,
    Smelter = function(game, x, y)
        local TileObject = require("src.entities.TileObject")

        return Item(game, x, y, Image.smelto, {
            name = "Smelter",
            needs = {
                Stone = 300,
                Wood = 200,
                Gold = 100
            },
            placeable = true,
            places = TileObject.Smelter(game, 1, 1),
        })
    end,
    Furnace = function(game, x, y)
        local TileObject = require("src.entities.TileObject")

        return Item(game, x, y, Image.furno, {
            name = "Furnace",
            needs = {
                Stone = 300,
                Wood = 200,
                Gold = 100,
            },
            placeable = true,
            places = TileObject.Furnace(game, 1, 1),
        })
    end
}
