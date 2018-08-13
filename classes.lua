--CLASSES.LUA
--the various classes
local class = require("lib.middleclass.middleclass")
local json = require('lib.json.json')
require("functions")

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
	end,

	setGraphics = function(self, imgX, imgY, width, height)
		--/!\ ⚠️ /!\ ACHTUNG /!\ ⚠️ /!\
		--if you want to use states, call initialiseStates BEFORE calling this function! or else you will DIE
		if width == nil then width = 1 end
		if height == nil then height = width end
		self.width = width
		self.height = height

		for state, offset in pairs(self.states) do
			if #offset == 1 then table.insert(offset, 0) end
			img = string.format("%s|%s|%s",self.imgFile, self.class.name, state)
			if state == "default" then self.baseImg = img end
			if cache['sprites'][img] == nil then
				cache['sprites'][img] = love.graphics.newQuad((imgX+offset[1])*32, (imgY+offset[2])*32, width*32, height*32, cache['img'][self.imgFile]:getDimensions())
			end
		end
		self.img = self.baseImg
	end,

	getImg = function(self)
		return string.format("%s|%s|%s",self.imgFile, self.class.name, self.state)
	end,

	animate = function(self, dt)
		if self.stateCluster == nil then
			-- self.state = "default"
			return
		end
		local validState = false
		local nextState = false
		for key, stateInfo in pairs(self.stateClusters[self.stateCluster]) do
			if nextState then
				self.state = stateInfo[1]
				nextState = false
				break
			end
			if self.state == stateInfo[1] then
				--our current state is in the list of states present in this cluster
				validState = true
				self.animationTimer = self.animationTimer + dt
				if self.animationTimer > stateInfo[2] then
					nextState = true
					self.animationTimer = 0
				end
			end
		end 

		if (not validState) or nextState then
			--either:
			-- a. our current state is invalid
			-- b. we're supposed to move to the next state, but we've reached the end of the list
			--in either case, we should set our state to the first state in this cluster
			for key, stateInfo in pairs(self.stateClusters[self.stateCluster]) do --HACK: don't use a for loop, that's icky
				self.state = stateInfo[1]
				break
			end
		end
	end,
	drawArgs = function(self, cam, screenX, screenY, scaleX, scaleY, noFlip)
		if scaleX == nil then scaleX = 1 end
		if scaleY == nil then scaleY = scaleX end
		drawX = screenX - (cam.x * 32 * settings['graphics']['scale']) + cam.width / 2
		if cache['img'] == nil then error(":c") end
		if not noFlip and self:isInstanceOf(Entity) and self:isMovingLeft() then
			scaleX = scaleX * -1
			drawX = drawX + (self.width * settings['graphics']['scale'] * 32)
		end
		return cache['img'][self:getImgFile()], cache['sprites'][self:getImg()], drawX, screenY - cam.y * 32 * settings['graphics']['scale'], 0, scaleX, scaleY
	end

}
getPosFunctions = {
	getPos = function(self)
		pos = {
			['x'] = self.x,
			['y'] = self.y
		}
		return pos
	end,
	getCentre = function(self)
		return {
			x = self.x + self.width / 2,
			y = self.y + self.height / 2
		}
	end,
	isOnScreen = function(self, cam)
		return true
	end
}

----- CLASSES -----
Entity = class("Entity")
Entity:include(states)
Entity:include(getPosFunctions)
function Entity:initialize(name, x, y, hitboxes)
	self.name, self.x, self.y, self.hitboxes = name, x, y, hitboxes
	self.grounded = true
	self.usesStates = false
	self.states = {default={0}}
	self.state = "default"
	self.stateClusters = {}
	self.stateCluster = nil
	self.animationTimer = 0
	self.baseImg = nil
	self.imgFile = "entities.png"
	self.xVelocity = 0
	self.yVelocity = 0
	self.xvCap = 5
	self.yvCap = 15
	self.speed = 15
	self.movingLeft = false
	-- self.defaultHitboxes = hitboxes
	self.collidingWith = {}
	-- self.lowestHitbox = hitboxes[1]
	local lowest = 0
	for key, hitbox in pairs(hitboxes) do
		lowpoint = hitbox.xOffset + hitbox.height
		if lowpoint > lowest then
			lowest = lowpoint
			self.lowestHitbox = hitbox
		end
	end
	metadata['entities'][self.class.name] = self.class
end

function Entity:isMovingLeft()
	if self.xVelocity ~= 0 then
		self.movingLeft = self.xVelocity < 0
	end
	return self.movingLeft
end

function Entity:checkCollision(level, hitboxes)
	if hitboxes == nil then hitboxes = self.hitboxes end
	local collidingWith = {}
	for key, hitbox in pairs(hitboxes) do
		sx = self.x + hitbox.xOffset / 32
		sy = self.y + hitbox.yOffset / 32
		for row, rData in pairs(level:getMap()['fg']) do
			for column, tile in pairs(rData) do
				if (tile ~= 0) and tile.solid then
					tx = tile.x + tile.hitbox.xOffset / 32
					ty = tile.y + tile.hitbox.yOffset / 32

					if tx < sx + hitbox.width / 32
					and tx + tile.hitbox.width / 32 > sx
					and ty + tile.hitbox.yOffset / 32 < sy + hitbox.height / 32
					and ty + tile.hitbox.height / 32 > sy
					then
						-- collided!
						table.insert(collidingWith, tile)
					end
				end
			end
		end
	end
	return collidingWith
end
-- function Entity:updateCollision(level)
-- 	self.collidingWith = self:checkCollision(level)
-- end
function Entity:groundingCheck(level)
	local feet = getHitbox(self.lowestHitbox.xOffset + 1, self.lowestHitbox.yOffset + self.lowestHitbox.height, self.lowestHitbox.width - 2, 1)
	local feetCollision = self:checkCollision(level, {feet})
	self.grounded = #feetCollision > 0
end
function Entity:processPhysics(dt, level)
	--TODO: clean this up, it's really messy
	self:groundingCheck(level)
	if not self.grounded then
		self.yVelocity = self.yVelocity + 15 * dt
	else
		if self.yVelocity > 0 then self.yVelocity = 0 end --stop falling if you're on the ground
	end

	if math.abs(self.xVelocity) > self.xvCap then
		local dir = 1
		if self.xVelocity < 0 then dir = -1 end
		self.xVelocity = pullTowards(self.xVelocity, dir * self.xvCap, 10 * dt)
	end
	if math.abs(self.yVelocity) > self.yvCap then
		local dir = 1
		if self.yVelocity < 0 then dir = -1 end
		self.yVelocity = pullTowards(self.yVelocity, dir * self.yvCap, 10 * dt)
	end

	self.xVelocity = pullTowards(self.xVelocity, 0, 4 * dt)

	local oldcol = #self:checkCollision(level)
	local oldX = self.x
	self.x = round(self.x + self.xVelocity * dt, 1/32)
	local dir = 1
	if oldX < self.x then dir = -1 end
	while #self:checkCollision(level) ~= oldcol do
		self.xVelocity = 0
		self.x = round(self.x + (1/32) * dir, 1/32)
	end

	local oldY = self.y
	self.y = round(self.y + self.yVelocity * dt, 1/32)
	dir = 1
	if oldY < self.y then dir = -1 end
	while #self:checkCollision(level) ~= oldcol do
		self.yVelocity = 0
		self.y = round(self.y + (1/32) * dir, 1/32)
	end

end
function Entity:moveInDirection(direction, dt)
	if direction == "left" then
		if self:isMovingLeft() then
			self.xVelocity = self.xVelocity - self.speed * dt
		else
			self.xVelocity = self.xVelocity - self.speed * 2 * dt
		end
	elseif direction == "right" then
		if self:isMovingLeft() then
			self.xVelocity = self.xVelocity + self.speed * 2 * dt
		else
			self.xVelocity = self.xVelocity + self.speed * dt
		end
	elseif direction == "up" then
		self.y = self.y - 0.1 --this is debugging stuff
	elseif direction == "down" then
		self.y = self.y + 0.1
	else
		error("Unknown direction: ", direction)
	end
end
function Entity:jump()
	if self.grounded then
		self.yVelocity = -8
		if self.class.name == "nttAmy" then playSound("jump") end
	end
end
function Entity:getImgFile()
	return "entities.png"
end

Tile = class("Tile")
Tile:include(states)
Tile:include(getPosFunctions)
function Tile:initialize(name, bg, x, y, hitbox)
	self.name, self.bg, self.x, self.y = name, bg, x, y
	self.solid = true
	self.bouncy = false
	self.slippery = false
	self.usesStates = false
	self.states = {default={0}}
	self.state = "default"
	self.stateClusters = {}
	self.stateCluster = nil
	self.baseImg = nil
	self.defaultHitbox = hitbox or getHitbox(0, 0, 32, 32)
	self.hitbox = self.defaultHitbox
	metadata['tiles'][self.class.name] = self.class
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

Hitbox = class("Hitbox")
function Hitbox:initialize(xOffset, yOffset, width, height)
	--these values are in pixels rather than (pixels/32)!
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
	--convert gamepack to json
	local output = {
		name = self.name,
		description = self.description,
		author = self.author,
		formatVersion = self.formatVersion,
		compressionTable = {},
		acts = {}
	}

	for k, act in pairs(self.acts) do
		output['acts'][k] = {
			name = act.name,
			levels = {}
		}
		for key, level in pairs(act.levels) do
			output['acts'][k]['levels'][key] = {
				name = level.name,
				bgColour = level.bgColour,
				map = {
					fg = {},
					bg = {}
				},
				obj = {},
				ntt = {}
			}
			for category, tbl in pairs(level.map) do
				for rowNumber, row in pairs(tbl) do
					pendingGroup = {nil, nil} --group multiple tiles together (e.g. [1, 4] instead of 1,1,1,1)
					table.insert(output['acts'][k]['levels'][key]['map'][category], {})
					for column, tile in pairs(row) do
						if tile == 0 then
							tileName = "nil"
						else
							tileName = string.sub(tile.class.name, 5)
						end
						if not contains(output['compressionTable'], tileName) then
							table.insert(output['compressionTable'], tileName)
						end
						local id = keyFromValue(output['compressionTable'], tileName)

						if pendingGroup[1] == id then
							pendingGroup[2] = pendingGroup[2] + 1
						else
							if pendingGroup[2] ~= nil then
								if pendingGroup[2] < 3 then
									for i = 1, pendingGroup[2] do --[1, 1] and [1, 2] are both bigger than 1 and 1, 1
										table.insert(output['acts'][k]['levels'][key]['map'][category][rowNumber], pendingGroup[1])
									end
								else
									table.insert(output['acts'][k]['levels'][key]['map'][category][rowNumber], pendingGroup)
								end
							end
							pendingGroup = {id, 1}
						end
					end

					if pendingGroup[2] < 3 then
						for i = 1, pendingGroup[2] do --[1, 1] and [1, 2] are both bigger than 1 and 1, 1
							table.insert(output['acts'][k]['levels'][key]['map'][category][rowNumber], pendingGroup[1])
						end
					else
						table.insert(output['acts'][k]['levels'][key]['map'][category][rowNumber], pendingGroup)
					end
				end
			end

			for identifier, tbl in pairs({obj = level.objects, ntt = level.entities}) do
				for l, thing in pairs(tbl) do
					local thingName = string.sub(thing.class.name, 4)
					if not contains(output['compressionTable'], thingName) then
						table.insert(output['compressionTable'], thingName)
					end
					
					table.insert(output['acts'][k]['levels'][key][identifier], {keyFromValue(output['compressionTable'], thingName), thing.x, thing.y})
				end
			end
		end
	end

	return json.encode(output)
end
function GamePack:save(path)
	--write json
end
function GamePack:load(path, data)
	--convert json to gamepack
	if path ~= nil then
		--read json file
	end
	self.name, self.description, self.author, self.formatVersion =
		data['name'], data['description'], data['author'], data['formatVersion']
	self.acts = {}
	for k, act in pairs(data['acts']) do
		levels = {}
		for l, level in pairs(act['levels']) do
			table.insert(levels, GameLevel:new(level, data['compressionTable']))
		end
		table.insert(self.acts, GameAct:new(act['name'], levels))
	end
end
function GamePack:loadMainPack(gamePackID)
	file, size = love.filesystem.read("string", string.format("lvl/gamepack-%s.json", gamePackID))
	if not file then
		error(string.format("Couldn't find GamePack for %s! This isn't your fault, blame the developer.", gamePackID))
	end
	data = json.decode(file)
	self:load(nil, data)
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
function GameLevel:initialize(level, compressionTable)
	self.name = level['name']
	self.mapPlan = level['map']
	self.map = {}
	self.objectsPlan = level['obj']
	self.objects = {}
	self.entitiesPlan = level['ntt']
	self.entities = {}
	for category, tbl in pairs(level['map']) do
		for row, rData in pairs(tbl) do
			for column, digit in pairs(rData) do
				if type(digit) == 'number' then
					self.mapPlan[category][row][column] = compressionTable[digit]
				elseif type(digit) == 'string' then
					--do nothing
				else
					--instead of being e.g. 1, this "digit" is e.g. [1, 10], meaning 10 1's in a row
					local tbl = cloneTable(digit)
					table.remove(rData, column)
					for i = 1, tbl[2] do
						table.insert(self.mapPlan[category][row], column + i - 1, compressionTable[tbl[1]])
					end
				end
			end
		end
	end

	for key, tbl in pairs({obj = self.objectsPlan, ntt = self.entitiesPlan}) do
		for k, thingTable in pairs(tbl) do
			thingTable[1] = compressionTable[thingTable[1]]
		end
	end
	self.map['fg'] = {}
	self.map['bg'] = {}
	self.bgColour = level['bgColour'] or {0, 0, 0}
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
		table.insert(self.objects, _G["obj"..obj[1]]:new(obj[2], obj[3]))
	end

	for key, entity in pairs(self.entitiesPlan) do
		table.insert(self.entities, _G["ntt"..entity[1]]:new(entity[2], entity[3]))
	end
end
function GameLevel:getMap()
	return self.map
end
function GameLevel:getObjects()
	return self.objects
end
function GameLevel:getEntities()
	return self.entities
end
function GameLevel:getBackgroundColour()
	return self.bgColour
end
function GameLevel:getAmy()
	for k, ntt in pairs(self.entities) do
		if ntt:isInstanceOf(_G["nttAmy"]) then return ntt end
	end
end

Camera = class("Camera")
Camera:include(getPosFunctions)
function Camera:initialize()
	self.x = 0
	self.y = 0
end
function Camera:setSize(width, height)
	self.width, self.height = width, height
end
function Camera:setPos(x, y)
	self.x, self.y = x, y
end
function Camera:chase(target, xDistance, yDistance, yOffset)
	local centre = target:getCentre()
	centre['y'] = centre['y'] - yOffset * settings['graphics']['scale']
	while not withinXOf(centre['x'], self.x, xDistance) do
		self.x = pullTowards(self.x, centre['x'], 1/32)
	end
	while not withinXOf(centre['y'], self.y, yDistance) do
		self.y = pullTowards(self.y, centre['y'], 1/32)
	end
end
function Camera:moveTowards(x, y, speed)
	error("Not implemented yet")
end
function Camera:moveInDirection(dir, dt)
	if dir == "up" then
		self.y = self.y - 0.1
	elseif dir == "down" then
		self.y = self.y + 0.1
	elseif dir == "left" then
		self.x = self.x - 0.1
	elseif dir == "right" then
		self.x = self.x + 0.1
	end
end

Object = class("Object")
Object:include(getPosFunctions)
Object:include(states)
function Object:initialize(name, x, y, hitboxes, listeners)
	self.name, self.x, self.y, self.hitboxes, self.listeners = name, x, y, hitboxes, listeners
	--LISTENERS:
	--collide - when object is collided with (an entity overlaps with the space it occupies)
	--interact - when the player presses the interact key while overlapping the entity
	self.imgFile = "objects.png"
	self.states = {default={0}}
	self.state = "default"
	metadata['objects'][self.class.name] = self.class
end
function Object:getImgFile()
	return "objects.png"
end

Music = class("Music")
function Music:initialize(track, loopStart, loopEnd)
	self.track, self.loopStart, self.loopEnd = track, loopStart, loopEnd
	self.source = cache['music'][track]
	error("Unimplemented")
end