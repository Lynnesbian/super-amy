--OBJECTS.LUA
--all of the objects. objects are interactible items, such as shells (currency) and trampolines.

local class = require("lib.middleclass.middleclass")
require("functions")
require("classes")

objVictoryBlock = class("objVictoryBlock", Object)
function objVictoryBlock:initialize(x, y)
	self.hitboxes = {getHitbox(0,0,0,0)}
	Object.initialize(self, "objVictoryBlock", x, y, hitboxes)
	self:setGraphics(0, 0, 1, 1)
end
objVictoryBlock()