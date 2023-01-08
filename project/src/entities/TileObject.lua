local timer         = requireLibrary("hump.timer")
local const         = require("src.const")
local vector        = requireLibrary("hump.vector")
local Item          = require("src.entities.Item")
local FireParticles = require("src.entities.FireParticles")


local TileObject = function(game, i, j, img, config)
    local tileObject = {
        i = i,
        j = j,
        x = i * const.tilewidth,
        y = j * const.tileheight,
        -- distance for z
        distance = const.tileheight * 0.85,
        r = 0,
        img = img or Image.tree,
        scaleY = 1,
        color = { 1, 1, 1 },
        time = 0,
        update = function(self, dt)
            self.time = self.time + dt
            if self.afterUpdate then self:afterUpdate(dt) end
        end,
        mouseOver = function(self)
            local lx, ly = game.cam:mousePosition()
            if lx > self.x and lx < self.x + const.tilewidth and ly > self.y and ly < self.y + const.tileheight
                and
                vector.new(self.x + const.tilewidth / 2, self.y + const.tileheight / 2):dist(vector.new(game.player.x,
                    game.player.y))
                < 30 then
                return true
            end
        end,
        afterDestroy = function(self) end,
        harvest = function(self)
            if self.config.harvestSfx then self.config.harvestSfx:play() end
            timer.tween(0.1, self, { scaleY = 1.2 }, "quad", function()
                timer.tween(0.4, self, { scaleY = 1 }, "bounce", function()
                end)
            end)
            self.color = { 0, 0, 1 }
            timer.after(0.1, function()
                self.color = { 1, 1, 1 }
            end)
            self.r = math.random() * 0.1
            timer.tween(0.5, self, { r = 0 }, "bounce")

            local amount = 1
            local item = game.player.inventory[game.inventory.selected]
            if item and item.harvestBoost then
                amount = item.harvestBoost
                item.duration = item.duration - 1
                if item.duration <= 0 then
                    Sfx.breaks:play()
                    item.amount = item.amount - 1
                    if item.amount == 0 then
                        del(game.player.inventory, item)
                    else
                        item.duration = item.maxduration
                    end
                end
            end
            self.config.hp = self.config.hp - amount

            if self.config.hp <= 0 then
                Sfx.done:play()
                del(game.objects, self)
                game.map:set(i, j, 1, nil)
                if self.config.drops then
                    add(game.objects,
                        self.config.drops(game, self.x + const.tilewidth / 2, self.y + const.tileheight / 2 -
                            math.random()))
                    if math.random() < 0.1 then
                        add(game.objects,
                            self.config.drops(game, self.x + const.tilewidth / 2,
                                self.y + const.tileheight / 2 - math.random()))
                    end
                end
                self:afterDestroy()
            end
        end,
        mousepressed = function(self, x, y, btn)
            if btn == 1 and self:mouseOver() then
                if self.config.harvestable then
                    self:harvest()
                else
                    if self.interact then self:interact() end
                end
            end
        end,
        draw = function(self)
            if self:mouseOver() then
                love.graphics.draw(Image.selector, self.x, self.y + 9 + math.sin(self.time * 10))
                if self.config.hp then
                    love.graphics.setColor(0, 0, 0)
                    love.graphics.rectangle("fill", self.x + const.tilewidth / 2 - 8, self.y + const.tileheight + 12, 16
                        , 5)
                    love.graphics.setColor(1, 0, 0)
                    love.graphics.rectangle("fill", self.x + const.tilewidth / 2 - 8, self.y + const.tileheight + 12,
                        16 * self.config.hp / self.config.maxhp, 4)
                    love.graphics.setColor(1, 1, 1)
                end
            end
            --love.graphics.rectangle("line", self.x, self.y, const.tilewidth, const.tilewidth)
            love.graphics.setColor(self.color)
            love.graphics.draw(self.img, self.x + const.tilewidth / 2, self.y + const.tileheight,
                self.r,
                1, self.scaleY,
                const.tilewidth / 2,
                const.tileheight)
            if self.afterDraw then self:afterDraw() end
        end
    }
    tileObject.config = {}
    for k, v in pairs(config) do
        tileObject.config[k] = v
    end
    return tileObject
end


return {
    Rock = function(game, i, j) return TileObject(game, i, j, Image.rock,
            { harvestable = true, name = "Rock", maxhp = 30, hp = 30, drops = Item.Stone, harvestSfx = Sfx.stone,
                minlevel = 1 })
    end,
    GoldOre = function(game, i, j) return TileObject(game, i, j, Image.goldore,
            { harvestable = true, name = "GoldOre", maxhp = 50, hp = 50, drops = Item.Gold, harvestSfx = Sfx.stone,
                minlevel = 1 })
    end,
    IronOre = function(game, i, j) return TileObject(game, i, j, Image.ironore,
            { harvestable = true, name = "IronOre", maxhp = 400, hp = 400, drops = Item.Iron, harvestSfx = Sfx.stone,
                minlevel = 2 })
    end,
    Tree = function(game, i, j) return TileObject(game, i, j, Image.tree,
            { harvestable = true, name = "Tree", maxhp = 20, hp = 20, drops = Item.Wood, harvestSfx = Sfx.wood,
                minlevel = 1 })
    end,

    Expander = function(game, i, j)
        local object = TileObject(game, i, j, Image.expander,
            { name = "Expander", maxhp = 2, hp = 2, level = 1, minlevel = 1 })
        object.afterDestroy = function(self)
            Sfx.expand:play()
            game.map:extend(i, j, self.config.level)
        end
        object.interact = function(self)
            local coin
            for item in all(game.player.inventory) do
                if item.name == "Coin" then coin = item end
            end
            if not coin then return end
            Sfx.load:play()
            coin.amount = coin.amount - 1
            if coin.amount <= 0 then
                del(game.player.inventory, coin)
            end
            self.config.hp = self.config.hp - 1
            if self.config.hp <= 0 then
                del(game.objects, self)
                self:afterDestroy()
            end
        end
        return object
    end,
    -- stuff that didnt make it into the compo:
    Smelter = function(game, i, j)
        local object = TileObject(game, i, j, Image.smelter,
            { harvestable = false, name = "Smelter" })

        object.interact = function(self)
            if self.item then return end
            local item = game.player.inventory[game.inventory.selected]
            if not item or item.name ~= "Gold" then
                return
            end
            if self.item then
                add(game.player.inventory, self.item)
                self.item = nil
            end
            if item.amount == 1 then
                self.item = item
                del(game.player.inventory, item)
            else
                self.item = Item[item.name](game, 1, 1)
                item.amount = item.amount - 1
            end
        end
        object.afterUpdate = function(self, dt)
            if self.item and not self.active then
                -- check if an active furnace is are near to the smelter
                local furnaces = {}
                for object in all(game.objects) do
                    if object.config and object.config.name == "Furnace" then
                        add(furnaces, object)
                    end
                end

                local near
                for furnace in all(furnaces) do
                    if vector.new(furnace.x, furnace.y):dist(vector.new(self.x, self.y)) < 128 then
                        near = furnace
                    end
                end

                if not near or not near.item then return end
                self.active = true
                FireParticles(game, self, self.x + const.tilewidth / 2, self.y + const.tilewidth / 2 + 6)
                timer.after(10, function()
                    self.item = nil
                    self.active = false
                    add(game.objects, Item.GoldIngot(game, self.x, self.y + 32))
                end)

            end
        end
        object.afterDraw = function(self)
            if self.item then
                love.graphics.draw(self.item.img, self.x + 8 + const.tilewidth / 2, self.y + const.tileheight + 10,
                    self.r,
                    1, self.scaleY,
                    const.tilewidth / 2,
                    const.tileheight)
                love.graphics.print(item.amount, self.x, self.y)
            end
        end
        return object
    end,
    Furnace = function(game, i, j)
        local object = TileObject(game, i, j, Image.furnace,
            { harvestable = false, name = "Furnace" })

        object.interact = function(self)
            local item = game.player.inventory[game.inventory.selected]
            if not item or item.name ~= "Wood" then
                return
            end
            if self.item and self.item.name ~= item.name then
                add(game.player.inventory, self.item)
                self.item = nil
            end
            if not self.item then
                self.item = Item[item.name](game, 1, 1)
            elseif self.item and self.item.name == item.name then
                self.item.amount = self.item.amount + 1
            end
            item.amount = item.amount - 1
            if item.amount <= 0 then
                del(game.player.inventory, item)
            end
            local burnItem
            burnItem = function()
                timer.after(5, function()
                    self.item.amount = self.item.amount - 1
                    if self.item.amount <= 0 then
                        self.item = nil
                    else
                        burnItem()
                    end
                end)
            end
            burnItem()

            FireParticles(game, self, self.x + const.tilewidth / 2, self.y + const.tilewidth / 2 + 6)
        end
        object.afterDraw = function(self)
            if self.item then
                love.graphics.draw(self.item.img, self.x + 8 + const.tilewidth / 2, self.y + const.tileheight + 16,
                    self.r,
                    1, self.scaleY,
                    const.tilewidth / 2,
                    const.tileheight)
            end
        end
        return object
    end,
    GridSlot = function(game, i, j)
        local object = TileObject(game, i, j, Image.gridslot, { name = "Gridslot" })
        object.distance = 0
        object.interact = function(self)
            local item = game.player.inventory[game.inventory.selected]
            if not item then
                return
            end
            if self.item then
                add(game.player.inventory, self.item)
                self.item = nil
            end
            self.item = item
            del(game.player.inventory, item)
        end
        object.afterDraw = function(self)
            if self.item then
                love.graphics.draw(self.item.img, self.x + const.tilewidth / 2, self.y + const.tileheight,
                    self.r,
                    1, self.scaleY,
                    const.tilewidth / 2,
                    const.tileheight)
            end
        end
        return object
    end
}
