--CREATURES.LUA
--the creatures (amy, enemies, etc)
local class = require("lib.middleclass")
require("functions")
require("classes")

Amy = class("Amy", Creature)
function Amy:initialize(x, y)
	local hb = getHitbox(12, 9, 15, 55)
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
function Amy:calculateState()
	if self.xVelocity ~= 0 then
		self.stateCluster = "run"
	else
		self.stateCluster = nil
	end
end

Slime = class("Slime", Creature)
function Slime:initialize(x, y)
	local hb = getHitbox(0, 14, 32, 18)
	Creature.initialize(self, x, y, hb)
	stateSet = {
		default = {0},
		bob = {1},
	}
	stateClusterSet = {
		idle = {
			{"default", 0.5},
			{"bob", 0.5}
		}
	}
	self.name = "Slime"
	self:initialiseStates(stateSet, stateClusterSet)
	self:setGraphics(0, 2, 1, 1)
	self.hp = 2
	self.powers = {}
end
function Slime:calculateState()
	if self.xVelocity == 0 then
		self.stateCluster = "idle"
	else
		self.stateCluster = nil
	end
end