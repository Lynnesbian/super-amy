--CREATURES.LUA
--the creatures (amy, enemies, etc)
local class = require("lib.middleclass")
require("functions")
require("classes")

Amy = class("Amy", Creature)
function Amy:initialize(x, y)
	local hb = getHitbox(5, 9, 21, 55)
	Creature.initialize(self, x, y, hb)
	self.name = "Amy"
	stateSet = {
		default = {0},
		runA = {1},
		runB = {2},
		runC = {3},
		runD = {4},
		runE = {5},
		runF = {6},
		runG = {7},
	}
	stateClusterSet = {
		run = {
			{"runA", 0.1},
			{"runB", 0.1},
			{"runC", 0.1},
			{"runD", 0.1},
			{"runE", 0.1},
			{"runF", 0.1},
			{"runG", 0.1},
		}
	}
	self:initialiseStates(stateSet, stateClusterSet)
	self:setGraphics(0, 0, 1, 2)
	self.hp = 10
	self.powers = {}
end

Slime = class("Slime", Creature)
function Slime:initialize(x, y)
	local hb = getHitbox(0, 14, 32, 18)
	Creature.initialize(self, x, y, hb)
	self.name = "Slime"
	self:setGraphics(0, 2, 1, 1)
	self.hp = 2
	self.powers = {}
end