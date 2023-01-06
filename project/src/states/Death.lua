--
--  Game
--

local Gamestate = requireLibrary("hump.gamestate")
local timer     = requireLibrary("hump.timer")
local GameMap   = require("src.entities.GameMap")
local Player    = require("src.entities.Player")
local Camera    = require("libs.hump.camera")

Game = Gamestate.new()

function Game:enter()
    Game.map = GameMap()
    Game.cam = Camera(0, 0)
    Game.cam.scale = 3
    Game.player = Player(Game)
end

function Game:update(dt)

end

function Game:draw()
    love.graphics.print(love.timer.getFPS(), 0, 0)
    Game.cam:attach()
    Game.map:draw()
    Game.cam:detach()

end
