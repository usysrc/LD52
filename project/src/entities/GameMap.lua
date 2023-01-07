local Map        = require("src.Map")
local const      = require("src.const")
local TileObject = require("src.entities.TileObject")
local Tile       = require("src.entities.Tile")

return function(game)
    local map = Map()
    map.width = 8
    map.height = 8

    map.tiles = {}

    for i = 1, map.width do
        for j = 1, map.height do
            local tile = Tile.Grass(game, i, j)
            add(map.tiles, tile)
            map:set(i, j, 0, tile)

            if math.random() < 0.05 then
                local object
                if math.random() < 0.5 then
                    object = TileObject.Rock(game, i, j)
                else
                    object = TileObject.Tree(game, i, j)
                end

                if object then
                    map:set(i, j, 1, object)
                    add(game.objects, object)
                end

            end
        end
    end
    add(game.objects, TileObject.Totem(game, map.width, map.height / 2))
    add(game.objects, TileObject.Totem(game, math.floor(map.width / 2), 1))
    add(game.objects, TileObject.Totem(game, math.floor(map.width / 2), map.height))
    add(game.objects, TileObject.Totem(game, 1, map.height / 2))

    local possibleResourceSpawns = {
        TileObject.Rock, TileObject.Tree
    }

    map.update = function(self, dt)
        local treeCount = 0
        local rockCount = 0
        for object in all(game.objects) do
            if object.config and object.config.name == "rock" then rockCount = rockCount + 1 end
            if object.config and object.config.name == "tree" then treeCount = treeCount + 1 end
        end
        -- spawn an object
        if math.random() < 0.01 and math.random() < 0.5 then
            local t = self.tiles[math.random(#self.tiles)]
            local o = map:get(t.i, t.j, 1)
            if not o then
                local object = possibleResourceSpawns[math.random(#possibleResourceSpawns)](game, t.i, t.j)
                add(game.objects, object)
                map:set(t.i, t.j, 1, object)
            end
        end
        if treeCount <= 0 then
            local t = self.tiles[math.random(#self.tiles)]
            local o = map:get(t.i, t.j, 1)
            if not o then
                local object = TileObject.Tree(game, t.i, t.j)
                add(game.objects, object)
                map:set(t.i, t.j, 1, object)
            end
        end
    end

    map.draw = function(self)
        for tile in all(map.tiles) do
            tile:draw()
        end
        table.sort(game.objects, function(a, b) return a.y + a.distance < b.y + b.distance end)
        for obj in all(game.objects) do
            obj:draw()
        end
    end

    map.extend = function(self, x, y)

        local addGrass = function(i, j)
            local t = map:get(i, j, 0)
            if not t then
                local tile = Tile.Grass(game, i, j)
                add(map.tiles, tile)
                map:set(i, j, 0, tile)
            end
        end

        for i = x - 2, x + 2 do
            for j = y - 2, y + 2 do
                addGrass(i, j)

            end
        end

        for i = x - 2, x + 2 do
            for j = y - 2, y + 2 do
                if math.random() < 0.1 then
                    if not map:get(i + 1, j, 0) or not map:get(i - 1, j, 0) or not map:get(i, j + 1, 0) or
                        not map:get(i, j - 1, 0) then
                        local object = TileObject.Totem(game, i, j)
                        add(game.objects, object)
                        map:set(i, j, 1, object)

                    end
                end
            end
        end



        table.sort(map.tiles, function(a, b) return a.j < b.j end)
    end

    return map
end
