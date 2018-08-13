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
	ui = {}
}

--temp stuff
mainGP = GamePack:new()
mainGP:loadMainPack("main")
local currentLevel = mainGP:getLevel(1, 1)
currentLevel:prepare()
amy = currentLevel:getAmy()
gameState['mode'] = "ingame"
--end temp stuff
camera = Camera:new()
camera.x, camera.y = -5, 2

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
	love.window.setMode(1024, 768, {resizable = true})
	camera:setSize(1024/32, 768/32)
	if true or not love.filesystem.exists("settings.json") then --remove "true or" when releasing!
		love.filesystem.write("settings.json", love.filesystem.read("default-settings.json"))
	end
	settings = json.decode(love.filesystem.read("settings.json")) --todo: if this fails, copy the default
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
	if gameState['mode'] == 'ingame' then
		camera:chase(amy, 4, 2) --TODO: adapt this to the size of the screen!
	end
	if contains({"ingame", "editor"}, gameState['mode']) then
		drawLevel(currentLevel)
	end

	if gameState['mode'] == 'editor' then
		
	end

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
