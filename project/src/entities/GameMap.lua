local Map        = require("src.Map")
local const      = require("src.const")
local TileObject = require("src.entities.TileObject")
local Tile       = require("src.entities.Tile")

return function(game)
    local map = Map()
    map.width = 5
    map.height = 5

    map.tiles = {}

    map.placeRandomObject = function(self, i, j)
        if math.random() < 0.2 then
            local object
            if math.random() < 0.5 then
                object = TileObject.Rock(game, i, j)
            else
                object = TileObject.Tree(game, i, j)
            end
            if object and not map:get(i, j, 1) then
                map:set(i, j, 1, object)
                add(game.objects, object)
                return object
            end
        end
    end

    for i = 1, map.width do
        for j = 1, map.height do
            local tile = Tile.Grass(game, i, j)
            add(map.tiles, tile)
            map:set(i, j, 0, tile)
            map:placeRandomObject(i, j)
        end
    end

    map.placeObject = function(self, i, j, what)
        local object = map:get(i, j, 1)
        if object then
            del(game.objects, object)
        end
        object = add(game.objects, what(game, i, j))
        map:set(i, j, 1, object)
    end

    local i, j = map.width, math.floor(map.height / 2)
    local object = map:placeObject(i, j, TileObject.Expander)
    if object then
        object.config.level = 1
    end

    -- local i, j = math.floor(map.width / 2) - 1, math.floor(map.height / 2) - 2
    -- map:placeObject(i, j, TileObject.GridSlot)

    local possibleResourceSpawns = {
        TileObject.Rock, TileObject.Tree, TileObject.GoldOre, TileObject.IronOre
    }

    map.update = function(self, dt)
        local treeCount = 0
        local rockCount = 0
        for object in all(game.objects) do
            if object.config and object.config.name == "Rock" then rockCount = rockCount + 1 end
            if object.config and object.config.name == "Tree" then treeCount = treeCount + 1 end
        end
        -- spawn an object
        if math.random() < 0.05 and math.random() < 0.05 then
            local t = self.tiles[math.random(#self.tiles)]
            local o = map:get(t.i, t.j, 1)
            if not o then
                local object = possibleResourceSpawns[math.random(#possibleResourceSpawns)](game, t.i, t.j)
                if t.level >= object.config.minlevel then
                    add(game.objects, object)
                    map:set(t.i, t.j, 1, object)
                end
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

    map.extend = function(self, x, y, level)
        print("level:", level)
        local addGrass = function(i, j)
            local t = map:get(i, j, 0)
            if not t then
                local tile = Tile.Grass(game, i, j, level + 1)
                add(map.tiles, tile)
                map:set(i, j, 0, tile)
            end
        end


        local w, h = 3, 3

        for i = x - w, x + w do
            for j = y - h, y + h do
                addGrass(i, j)
                if i > x - 2 and i < x + 3 and j > y - 2 and j < y + 3 then
                    map:placeRandomObject(i, j)
                end
            end
        end

        -- place the expander
        local locations = {}
        for i = x - w, x + w do
            for j = y - h, y + h do
                if not map:get(i + 1, j, 0) or not map:get(i - 1, j, 0) or
                    not map:get(i, j + 1, 0) or
                    not map:get(i, j - 1, 0) then
                    if not map:get(i, j, 1) then
                        add(locations, { i = i, j = j })
                    end
                end
            end
        end
        for n = 1, 3 do
            local loc = locations[math.random(#locations)]
            if loc then
                local i, j = loc.i, loc.j
                local object = TileObject.Expander(game, i, j)
                object.config.level = (level or 1) + 1
                object.config.maxhp = object.config.maxhp * object.config.level
                object.config.hp = object.config.maxhp
                add(game.objects, object)
                map:set(i, j, 1, object)
            end
        end

        -- cleanup
        for object in all(game.objects) do
            if object.config and object.config.name == "Expander" then
                local i, j = object.i, object.j
                if map:get(i + 1, j, 0) and map:get(i - 1, j, 0) and map:get(i, j + 1, 0) and map:get(i, j - 1, 0) then
                    del(game.objects, object)
                    map:set(i, j, 1, nil)
                end
            end
        end
        table.sort(map.tiles, function(a, b) return a.j < b.j end)
    end

    return map
end
