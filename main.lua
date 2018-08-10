--MAIN.LUA
--the basic stuff, load, draw, etc.
--Super Amy - Copyright 2018 Lynnear Software!
local class = require("lib.middleclass")
local moonshine = require('lib.moonshine')

--SUPER IMPORTANT INITIAL STUFF THAT *MUST* GO FIRST
love.graphics.setDefaultFilter("nearest", "nearest", 1)
scale = 2
metadata = {}
for k,cat in pairs({"tileNames"}) do
	metadata[cat] = {}
end
cache = {}
for k,cat in pairs({"img", "sprites", "hitboxes"}) do
	cache[cat] = {}
end
metatables = {}

metatables["img"] = {}
metatables['img'].__index = function(table, key)
	if key == nil then
		error("Tried to access cache['img'] using a nil key!")
	end
	table[key] = love.graphics.newImage("res/img/" .. key)
	return table[key]
end
setmetatable(cache["img"], metatables['img'])

metatables["hitboxes"] = {}
metatables['hitboxes'].__index = function(tbl, key)
	if key == nil then
		error("Tried to access cache['hitboxes'] using a nil key!")
	end
	args = {}
	for d in string.gmatch(key, "%d+") do
		table.insert(args, d)
	end
	tbl[key] = Hitbox:new(unpack(args))
	return tbl[key]
end
setmetatable(cache["hitboxes"], metatables['hitboxes'])

--REQUIRES
require("functions")
require("classes")
require("tiles")
require("creatures")
require("controls")

mainGP = GamePack:new()
mainGP:loadMainPack("main")
local currentLevel = mainGP:getLevel(1, 1)
currentLevel:prepare()
amy = currentLevel:getAmy()

function love.update(dt)
	for k,v in pairs(controls) do
		if love.keyboard.isDown(k) then
			handleCommand(v)
		end
	end
	for key, creature in pairs(getAllInstancesOf(Creature, currentLevel:getObjects())) do
		creature:processPhysics(dt, currentLevel)
		-- creature:updateCollision(currentLevel)
		creature:calculateState()
		creature:animate(dt)
	end
end

function love.load()
	-- print(ss:getQuad():getViewport())
	for k, v in pairs(metadata['tileNames']) do
		-- print(k, v)
	end
	love.window.setMode(1024, 768, {resizable = true})
	shaders = moonshine(moonshine.effects.chromasep).chain(moonshine.effects.crt)
	shaders.parameters = {
		chromasep = {
			radius = 3
		},
		crt = {
			distortionFactor = {1.025, 1.025}
		},
	}
end

function love.draw()
	--draw level
	local map = currentLevel:getMap()
	-- love.graphics.setBackgroundColor(currentLevel:getBackgroundColour())
	-- love.graphics.draw(ss:drawArgs(0, 0))
	shaders(function()
		--actually render the stuff

		love.graphics.setColor(unpack(currentLevel:getBackgroundColour()))
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setColor(1, 1, 1)

		for key, catName in pairs({'bg', 'fg'}) do
			for row, rData in pairs(map[catName]) do
				for column, tile in pairs(rData) do
					if tile ~= 0 then
						love.graphics.draw(tile:drawArgs((scale * 32) * (tile:getPos()['x'] - 1), (scale * 32) * (tile:getPos()['y'] - 1), scale))
					end
				end
			end
		end

		--objects
		for key, obj in pairs(currentLevel:getObjects()) do
			love.graphics.draw(obj:drawArgs((scale * 32) * (obj:getPos()['x'] - 1), (scale * 32) * (obj:getPos()['y'] - 1), scale))
		end

	end)
	love.graphics.setColor(1,0,0)
	love.graphics.print("FPS: "..love.timer.getFPS(), 10, 20)
	love.graphics.print(string.format("Amy: %s, %s, %s (%s)", amy.x, amy.y, amy.stateCluster, amy.state), 10, 30)
	-- love.graphics.print("x", (amy.x - 1) * 32 * scale, (amy.y - 1) * 32 * scale)
	-- love.graphics.setColor(1, 0, 0, 0.5)
	-- love.graphics.rectangle("fill", ((amy.x - 1) * 32 + amy.hitbox.xOffset) * scale, ((amy.y - 1) * 32 + amy.hitbox.yOffset) * scale, amy.hitbox.width * scale, amy.hitbox.height * scale)
	love.graphics.setColor(1,1,1)
end