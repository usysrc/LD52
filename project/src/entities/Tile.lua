local const = require "src.const"
local Tile = function(game, i, j, img)
    return {
        i = i,
        j = j,
        draw = function()
            love.graphics.draw(Image.grass, i * const.tilewidth, j * const.tileheight)
        end
    }

end
return {
    Grass = function(game, i, j)
        return Tile(game, i, j, Image.grass)
    end
}
