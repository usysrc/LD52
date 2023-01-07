--
--  Game
--

local Gamestate = requireLibrary("hump.gamestate")
local timer     = requireLibrary("hump.timer")
local GameMap   = require("src.entities.GameMap")
local Player    = require("src.entities.Player")
local Camera    = require("libs.hump.camera")
local const     = require("src.const")
local Inventory = require("src.entities.Inventory")
Game            = Gamestate.new()

function Game:enter()
    Game.objects = {}
    Game.map = GameMap(Game)
    Game.cam = Camera(0, 0)
    Game.cam.scale = const.zoom
    Game.player = Player(Game)
    Game.inventory = Inventory(Game)
    Game.cam:lookAt(Game.player.x, Game.player.y)
end

function Game:update(dt)
    Game.map:update(dt)
    for obj in all(Game.objects) do
        obj:update(dt)
    end
    timer.update(dt)
end

function Game:draw()
    love.graphics.setColor(56 / 255, 89 / 255, 179 / 255)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(love.timer.getFPS(), 0, 0)
    Game.cam:attach()
    Game.map:draw()
    Game.cam:detach()
    Game.inventory:draw()
end

function Game:keypressed(key)
    Game.player:keypressed(key)
end

function Game:mousepressed(x, y, btn)
    if Game.inventory:mousepressed(x, y, btn) then return end
    for object in all(Game.objects) do
        if object.mousepressed then object:mousepressed(x, y, btn) end
    end
end

function Game:wheelmoved(x, y)
    Game.inventory:wheelmoved(x, y)
end
