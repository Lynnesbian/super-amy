--[[
MAIN.LUA
the basic stuff, load, draw, etc.
░█▀▀░█░█░█▀█░█▀▀░█▀▄░░░█▀█░█▄█░█░█
░▀▀█░█░█░█▀▀░█▀▀░█▀▄░░░█▀█░█░█░░█░
░▀▀▀░▀▀▀░▀░░░▀▀▀░▀░▀░░░▀░▀░▀░▀░░▀░
Copyright 2018 Lynnear Software!
Available under the MPLv2.0 licence. See the file "COPYING" for the text of the licence.
]]

local class = require("lib.middleclass.middleclass")
local moonshine = require('lib.moonshine')
local json = require("lib.json.json")

--SUPER IMPORTANT INITIAL STUFF THAT *MUST* GO FIRST
love.graphics.setDefaultFilter("nearest", "nearest", 1)
settings = {}
metadata = {}
for k,cat in pairs({"tiles", "objects", "entities"}) do
	metadata[cat] = {}
end
cache = {}
for k,cat in pairs({"img", "sprites", "hitboxes", "sfx", "music"}) do
	cache[cat] = {}
end
metatables = {}

metatables["img"] = {}
metatables['img'].__index = function(tbl, key)
	tbl[key] = love.graphics.newImage("res/img/" .. key)
	return tbl[key]
end
setmetatable(cache["img"], metatables['img'])

metatables["hitboxes"] = {}
metatables['hitboxes'].__index = function(tbl, key)
	args = {}
	for d in string.gmatch(key, "%d+") do
		table.insert(args, d)
	end
	tbl[key] = Hitbox:new(unpack(args))
	return tbl[key]
end
setmetatable(cache["hitboxes"], metatables['hitboxes'])

metatables["sfx"] = {}
metatables['sfx'].__index = function(tbl, key)
	tbl[key] = love.audio.newSource(string.format("res/sfx/ogg/%s.ogg", key), "static")
	tbl[key]:setVolume(settings['game']['volume-sound'])
	return tbl[key]
end
setmetatable(cache["sfx"], metatables['sfx'])

metatables["music"] = {}
metatables['music'].__index = function(tbl, key) --this is very similar to the sfx one, is there a way we can combine them in a loop?
	tbl[key] = love.audio.newSource(string.format("res/mus/ogg/%s.ogg", key), "streaming")
	tbl[key]:setVolume(settings['game']['volume-music'])
	return tbl[key]
end
setmetatable(cache["music"], metatables['music'])

--REQUIRES
require("functions")
require("classes")
require("tiles")
require("entities")
require("objects")
require("controls")

gameState = {
	mode = "title", --display the title screen
	['key-repeat-timer'] = 0,
	ui = {
		cursors = {
			default = love.mouse.newCursor("res/img/ui/cursor/default.png", 0, 0)
		}
	}
}

--temp stuff
mainGP = GamePack:new()
mainGP:loadMainPack("main")
local currentLevel = mainGP:getLevel(1, 1)
currentLevel:prepare()
amy = currentLevel:getAmy()
gameState['mode'] = "ingame"
-- love.mouse.setCursor(gameState['ui']['cursors']['default']) --causes a segfault on exit???
--end temp stuff
camera = Camera:new()
camera.x, camera.y = -5, 2

function love.resize(width, height)
	shaders.resize(width, height)
	camera:setSize(width, height)
end

function love.update(dt)
	for k,v in pairs(controls) do
		if love.keyboard.isDown(k) then
			handleCommand(v, dt)
		end
	end
	for key, entity in pairs(getAllInstancesOf(Entity, currentLevel:getEntities())) do
		entity:processPhysics(dt, currentLevel)
		-- entity:updateCollision(currentLevel)
		entity:calculateState()
		entity:animate(dt)
	end
end

function love.load()
	if true or not love.filesystem.exists("settings.json") then --remove "true or" when releasing!
		love.filesystem.write("settings.json", love.filesystem.read("default-settings.json"))
	end
	settings = json.decode(love.filesystem.read("settings.json")) --todo: if this fails, copy the default

	love.window.setMode(settings['graphics']['res'][1], settings['graphics']['res'][2], {resizable = true})
	camera:setSize(unpack(settings['graphics']['res']))
	shaders = moonshine(moonshine.effects.chromasep).chain(moonshine.effects.vignette).chain(moonshine.effects.crt)
	shaders.parameters = {
		chromasep = {
			radius = settings['graphics']['aberration'][2]
		},
		crt = {
			distortionFactor = {settings['graphics']['crt'][2], settings['graphics']['crt'][2]}
		},
		vignette = {
			radius = settings['graphics']['vignette'][2],
			opacity = settings['graphics']['vignette'][3]
		}
	}
end

function love.draw()
	shaders(function()
		if gameState['mode'] == 'ingame' then
			camera:chase(amy, 2, 2) --TODO: is this good enough? am *i* good enough?
		end
		if contains({"ingame", "editor"}, gameState['mode']) then
			drawLevel(currentLevel)
		end
		
		if gameState['mode'] == 'editor' then
			love.graphics.setColor(0, 0, 0)
			size = 32 * settings['graphics']['scale']
			xOffset = (camera.x * size) % size
			yOffset = (camera.y * size) % size
			for x = 1, camera.pWidth + size, size do
				for y = 1, camera.pHeight + size, size do
					love.graphics.rectangle("line", x - xOffset, y - yOffset, size, size)
				end
			end
		end

 	end)

	love.graphics.setColor(1,0,0)
	love.graphics.print("FPS: "..love.timer.getFPS(), 20, 15)
	love.graphics.print(string.format("Amy: %s, %s, %s (%s). Camera: %s, %s",
		round(amy.x, 0.1), round(amy.y, 0.1), amy.stateCluster, amy.state, camera.x, camera.y), 20, 30)
	love.graphics.print("Gamemode: "..gameState['mode'], 20, 45)
	-- love.graphics.print("x", (amy.x - 1) * 32 * settings['graphics']['scale'], (amy.y - 1) * 32 * settings['graphics']['scale'])
	-- love.graphics.setColor(1, 0, 0, 0.5)
	-- love.graphics.rectangle("fill", ((amy.x - 1) * 32 + amy.hitbox.xOffset) * settings['graphics']['scale'], ((amy.y - 1) * 32 + amy.hitbox.yOffset) * settings['graphics']['scale'], amy.hitbox.width * settings['graphics']['scale'], amy.hitbox.height * settings['graphics']['scale'])
	love.graphics.setColor(1,1,1)
end
