--
-- Map Class
--
-- 2016 Heachant, Tilmann Hars <headchant@headchant.com>
--
-- Made for tilemaps

--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

local Gamestate = requireLibrary("hump.gamestate")
local Class     = requireLibrary("hump.class")
local Vector    = requireLibrary("hump.vector")

--------------------------------------------------------------------------------
-- Class Definition
--------------------------------------------------------------------------------

Map = Class {
	init = function(self)
		self.data = {}
		self.width = 0
		self.height = 0
	end,
	set = function(self, i, j, z, what)
		self.data[i .. "," .. j .. "," .. z] = what
	end,
	get = function(self, i, j, z)
		return self.data[i .. "," .. j .. "," .. z]
	end,
	isBlocked = function(self, i, j, z)
		local t = self:get(i, j)
		return t and t.blocked
	end
}

return Map
