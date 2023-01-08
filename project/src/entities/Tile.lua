local const = require "src.const"
local Tile = function(game, i, j, img, level)
    return {
        i = i,
        j = j,
        level = level or 1,
        draw = function()
            love.graphics.draw(Image.grass, i * const.tilewidth, j * const.tileheight)
        end
    }

end
return {
    Grass = function(game, i, j, level)
        return Tile(game, i, j, Image.grass, level)
    end
}
