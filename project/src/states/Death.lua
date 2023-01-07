--
--  Game
--

local Gamestate = requireLibrary("hump.gamestate")
local timer     = requireLibrary("hump.timer")
local GameMap   = require("src.entities.GameMap")
local Player    = require("src.entities.Player")
local Camera    = require("libs.hump.camera")

Death = Gamestate.new()

function Death:enter()
    Death.map = DeathMap()
    Death.cam = Camera(0, 0)
    Death.cam.scale = 3
    Death.player = Player(Death)
end

function Death:update(dt)

end

function Death:draw()
    love.graphics.print(love.timer.getFPS(), 0, 0)
    Death.cam:attach()
    Death.map:draw()
    Death.cam:detach()

end
