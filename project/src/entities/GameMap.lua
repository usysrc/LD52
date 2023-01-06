local Map   = require("src.Map")
local const = require("src.const")

return function()
    local map = Map()
    map.width = 10
    map.height = 10
    for i = 1, map.width do
        for j = 1, map.height do
            map:set(i, j, 0, Image.grass)
            if math.random() < 0.2 then
                if math.random() < 0.5 then
                    map:set(i, j, 1, Image.rock)
                else
                    map:set(i, j, 1, Image.tree)
                end
            end
        end
    end

    map.draw = function(self)
        for i = 1, map.width do
            for j = 1, map.height do
                -- background layer
                love.graphics.draw(map:get(i, j, 0), i * const.tilewidth, j * const.tileheight)
                -- object layer
                local tile = map:get(i, j, 1)
                if tile then
                    love.graphics.draw(tile, i * const.tilewidth, j * const.tileheight)
                end
            end
        end
    end
    return map
end
