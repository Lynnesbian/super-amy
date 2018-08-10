--CLASSES.LUA
--the various classes
local class = require("lib.middleclass")
local json = require('lib.json')

----- MIXINS -----
states = {
	setState = function(self, state)
		self.state = state
	end,
	setStateCluster = function(self, cluster)
		self.stateCluster = cluster
	end,
	initialiseStates = function(self, stateSet, stateClusterSet)
		self.usesStates = true
		--example stateset
		-- stateSet = {
		-- 	name    offset X, Y
		-- 	runA = {1},
		-- 	runB = {2}
		-- }
		--for example, if you want the state "falling" to use the sprite at self.x + 3, self.y + 2, do this:
		-- stateSet = {
		-- 	falling = {3, 2}
		-- }

		--to do animations, you define a statecluster
		--so if you want the state "Blink" to animate between states BlinkA (hold for 0.4s) and BlinkB (0.6s), do this:
		-- stateClusterSet = {
		-- 	blink = {{"BlinkA", 0.4}, {"BlinkB", 0.6}}
		-- }
		self.states = stateSet
		self.stateClusters = stateClusterSet
	end,
	calculateState = function(self)
		self:setState("default")
		error("this is supposed to be abstract but i don't think lua has that")
	end,

	setGraphics = function(self, imgX, imgY, width, height)
		--/!\ ⚠️ /!\ ACHTUNG /!\ ⚠️ /!\
		--call initialiseStates BEFORE calling this function! or else you will DIE
		if width == nil then width = 1 end
		if height == nil then height = width end
		self.width = width
		self.height = height

		for state, offset in pairs(self.states) do
			if #offset == 1 then table.insert(offset, 0) end
			img = string.format("%s|%s|%s",self.imgFile, self.name, state)
			if state == "default" then self.baseImg = img end
			if cache['sprites'][img] == nil then
				cache['sprites'][img] = love.graphics.newQuad((imgX+offset[1])*32, (imgY+offset[2])*32, width*32, height*32, cache['img'][self.imgFile]:getDimensions())
			end
		end
		self.img = self.baseImg
	end
}
getPosFunction = {
	getPos = function(self)
		pos = {
			['x'] = self.x,
			['y'] = self.y
		}
		return pos
	end
}

----- CLASSES -----
Creature = class("Creature")
Creature:include(states)
Creature:include(getPosFunction)
function Creature:initialize(x, y, hitbox)
	self.name = "Unnamed Creature"
	self.hp = 1
	self.x = x
	self.y = y
	self.grounded = true
	self.usesStates = false
	self.states = {default={0}}
	self.state = "default"
	self.stateClusters = {}
	self.stateCluster = nil
	self.baseImg = nil
	self.imgFile = "creatures.png"
	self.xVelocity = 0
	self.yVelocity = 0
	self.xvCap = 2
	self.yvCap = 2
	self.speed = 0.2
	self.defaultHitbox = hitbox
	self.hitbox = hitbox
end

function Creature:drawArgs(screenX, screenY, scaleX, scaleY)
	if scaleX == nil then scaleX = 1 end
	if scaleY == nil then scaleY = scaleX end
	if cache['img'] == nil then error(":c") end
	return cache['img']["creatures.png"], cache['sprites'][self.img], screenX, screenY, 0, scaleX, scaleY
end
function Creature:movingLeft()
	return (self.xVelocity < 0)
end
function Creature:checkCollision(level)
	for row, rData in pairs(level:getMap()['fg']) do
		for column, tile in pairs(rData) do
			if tile ~= 0 and tile.solid then
				tx = tile.x + tile.hitbox.xOffset / 32
				ty = tile.y + tile.hitbox.yOffset / 32
				sx = self.x + self.hitbox.xOffset / 32
				sy = self.y + self.hitbox.yOffset / 32

				if tx < sx + self.hitbox.width / 32
				and tx + tile.hitbox.width / 32 > sx
				and ty + tile.hitbox.yOffset / 32 < sy + self.hitbox.height / 32
				and ty + tile.hitbox.height / 32 > sy
				then
					-- collided!
					-- print(string.format("%s (%f, %f) collided with %s (%f, %f)", self.name, self.x, self.y, tile.name, tile.x, tile.y))
				end
			end
		end
	end
end
function Creature:processPhysics(dt)
	--TODO: incorporate dt somehow ;)
	if not self.grounded then
		self.yVelocity = self.yVelocity + 3 * dt
	else
		if self.yVelocity < 0 then self.yVelocity = 0 end
	end

	if self.xVelocity > self.xvCap then
		self.xVelocity = pullTowards(self.xVelocity, self.xvCap, 0.5 * dt)
	end
	if self.yVelocity > self.yvCap then
		self.yVelocity = pullTowards(self.yVelocity, self.yvCap, 0.5 * dt)
	end

	self.xVelocity = pullTowards(self.xVelocity, 0, 4 * dt)

	self.x = self.x + self.xVelocity * dt
	self.y = self.y + self.yVelocity * dt

end
function Creature:moveInDirection(direction)
	if direction == "left" then
		if self:movingLeft() then
			self.xVelocity = self.xVelocity - self.speed
		else
			self.xVelocity = self.xVelocity - self.speed * 2
		end
	elseif direction == "right" then
		if self:movingLeft() then
			self.xVelocity = self.xVelocity + self.speed * 2
		else
			self.xVelocity = self.xVelocity + self.speed
		end
	elseif direction == "up" then
		self.y = self.y - 0.1
	elseif direction == "down" then
		self.y = self.y + 0.1
	else
		error("Unknown direction: ", direction)
	end
end

Tile = class("Tile")
Tile:include(states)
Tile:include(getPosFunction)
function Tile:initialize(name, bg, x, y, hitbox)
	self.name = name
	self.solid = true
	self.bg = bg
	self.bouncy = false
	self.slippery = false
	self.x = x
	self.y = y
	self.usesStates = false
	self.states = {default={0}}
	self.state = "default"
	self.stateClusters = {}
	self.stateCluster = nil
	self.baseImg = nil
	self.defaultHitbox = hitbox or Hitbox:new(0, 0, 32, 32)
	self.hitbox = self.defaultHitbox
	table.insert(metadata['tileNames'], self.name)
	self.imgFile = iif(bg, "backgrounds.png", "tiles.png")
end
function Tile:getQuad()
	return cache['sprites'][self.img]
end
function Tile:getImgFile()
	if self.bg then
		return "backgrounds.png"
	else
		return "tiles.png"
	end
end
function Tile:drawArgs(screenX, screenY, scaleX, scaleY) --TODO: mixin?
	if scaleX == nil then scaleX = 1 end
	if scaleY == nil then scaleY = scaleX end
	if cache['img'] == nil then error(":c") end
	return cache['img'][self:getImgFile()], cache['sprites'][self.img], screenX, screenY, 0, scaleX, scaleY
end
function Tile:getPos()
	pos = {
		['x'] = self.x,
		['y'] = self.y
	}
	return pos
end

Hitbox = class("Hitbox")
function Hitbox:initialize(xOffset, yOffset, width, height)
	--these values are in pixels rather than multiples of 32!
	self.xOffset = xOffset
	self.yOffset = yOffset
	self.height = height
	self.width = width
end

GamePack = class("GamePack")
function GamePack:initialize(name, description, acts)
	self.name = name or "Unnamed GamePack"
	self.description = description or "No description given"
	self.acts = acts or {}
end
function GamePack:getString()

end
function GamePack:save(path)

end
function GamePack:load(path)

end
function GamePack:loadMainPack(gamePackID)
	file = io.open(string.format("lvl/gamepack-%s.json", gamePackID))
	if not file then
		error(string.format("Couldn't find GamePack for %s!", gamePackID))
	end
	data = json.decode(file:read("*a"))
	self.name = data['name']
	self.description = data["description"]
	self.acts = {}
	for k, act in pairs(data['acts']) do
		levels = {}
		for l, level in pairs(act['levels']) do
			table.insert(levels, GameLevel:new(level['name'], level['map'], level['obj'], level['bgColour']))
		end
		table.insert(self.acts, GameAct:new(act['name'], levels))
	end
end
function GamePack:getLevel(act, level)
	return self.acts[act].levels[level]
end

GameAct = class("GameAct")
function GameAct:initialize(name, levels)
	self.name = name
	self.levels = levels
end

GameLevel = class("GameLevel")
function GameLevel:initialize(name, map, obj, bgColour)
	self.name = name
	self.mapPlan = map
	self.map = {}
	self.map['fg'] = {}
	self.map['bg'] = {}
	self.objectsPlan = obj
	self.objects = {}
	self.bgColour = bgColour or {0, 0, 0}
end
function GameLevel:prepare()
	--loads the map as objects rather than strings
	for category, catData in pairs(self.mapPlan) do
		for l, row in pairs(catData) do
			table.insert(self.map[category], {})
			for m, tileName in pairs(row) do
				if tileName ~= "nil" then
					table.insert(self.map[category][l], _G[string.format("tile%s", tileName)]:new(m, l))
				else
					table.insert(self.map[category][l], 0)
				end
			end
		end
	end

	for key, obj in pairs(self.objectsPlan) do
		table.insert(self.objects, _G[obj[1]]:new(obj[2], obj[3]))
	end
end
function GameLevel:getMap()
	return self.map
end
function GameLevel:getObjects()
	return self.objects
end
function GameLevel:getBackgroundColour()
	return self.bgColour
end
function GameLevel:getAmy()
	for k, obj in pairs(self.objects) do
		if obj:isInstanceOf(_G["Amy"]) then return obj end
	end
end