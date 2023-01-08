local timer = requireLibrary("hump.timer")

return function(game, furnace, x, y)
    for _ = 1, 16 do
        local newParticle
        newParticle = function()
            local particle = {
                x = x, y = y,
                update = function() end,
                draw = function(self)
                    love.graphics.setColor(1, 0, 0)
                    love.graphics.rectangle("fill", self.x, self.y, 1, 1)
                end,
                distance = 64,
            }
            add(game.objects, particle)
            timer.tween(1 + math.random(), particle, { y = particle.y - 5, x = particle.x + math.random() * 2 },
                "linear",
                function()
                    del(game.objects, particle)
                    if furnace.item then
                        newParticle()
                    end
                end)
        end
        newParticle()
    end
end
