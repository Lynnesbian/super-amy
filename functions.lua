--FUNCTIONS.LUA
--most of the functions used by the game
local class = require("lib.middleclass.middleclass")
--BASIC STUFF

function shuffle(tbl) --https://gist.github.com/Uradamus/10323382
  size = #tbl
  for i = size, 1, -1 do
    local rand = math.random(size)
    tbl[i], tbl[rand] = tbl[rand], tbl[i]
  end
  return tbl
end
 
function reverse(tbl) --https://gist.github.com/balaam/3122129#gistcomment-1680319
  for i=1, math.floor(#tbl / 2) do
    local tmp = tbl[i]
    tbl[i] = tbl[#tbl - i + 1]
    tbl[#tbl - i + 1] = tmp
  end
end

function inArray(key, tbl)
	for k,v in pairs(tbl) do
		if (v == key) then return true end
	end
	return false
end

function cloneTable(obj, seen) --thanks to https://stackoverflow.com/a/26367080/4480824
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[cloneTable(k, s)] = cloneTable(v, s) end
  return res
end

function withinXOf(varA, varB, threshold)
	return math.abs(varA - varB) <= threshold
end

function pullTowards(value, target, stepSize)
  if stepSize == nil then stepSize = 1 end
  if withinXOf(math.abs(value), target, stepSize) then
    return target
  end
  if target > value then
    return value + stepSize
  else
    return value - stepSize
  end
end

function iif(condition, x, y) --NOTE: both x and y are always evaluated!
	if condition then return x else return y end
end

function round(x, multiple) --lua...
  return math.floor((x + multiple / 2) / multiple) * multiple
end

function isBetween(var, lower, upper, inclusive)
	if inclusive then
		return var >= lower and var <= upper
	else
		return var > lower and var < upper
	end
end

function getAllInstancesOf(targetClass, array)
  instances = {}
  for k,obj in pairs(array) do
    if obj.class.name == targetClass.name or obj:isInstanceOf(targetClass) then table.insert(instances, obj) end
  end
  return instances
end

function contains(tbl, value)
  for k, v in pairs(tbl) do
    if v == value then return true end
  end
  return false
end

--GAME-SPECIFIC STUFF

function handleCommand(cmd, dt)
  if cmd == "restart" then
    love.event.quit("restart")
  end
  -- print(key)
  if gameState['mode'] == "ingame" then
    if contains({"up", "down", "left", "right"}, cmd) then
      amy:moveInDirection(cmd, dt)
    elseif cmd == "jump" then
      amy:jump()
    end
  elseif gameState['mode'] == 'editor' then
    if contains({"up", "down", "left", "right"}, cmd) then
      camera:moveInDirection(cmd, dt)
    end
  end
end

function getHitbox(xOffset, yOffset, width, height)
  return cache['hitboxes'][string.format("%d,%d,%d,%d", xOffset, yOffset, width, height)]
end

function playSound(sfx)
  cache['sfx'][sfx]:play()
end

function drawLevel(currentLevel)
  local map = currentLevel:getMap()
  -- love.graphics.setBackgroundColor(currentLevel:getBackgroundColour())
  -- love.graphics.draw(ss:drawArgs(0, 0))
  shaders(function()
    --actually render the stuff

    love.graphics.setColor(unpack(currentLevel:getBackgroundColour()))
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1)

    for key, catName in pairs({'bg', 'fg'}) do
      if catName == "fg" then
        --draw objects and entities before fg but after bg
        for key, obj in pairs(currentLevel:getObjects()) do --todo: these two blocks are almost identical, merge them into one
          love.graphics.draw(obj:drawArgs(camera, (settings['graphics']['scale'] * 32) * (obj:getPos()['x'] - 1),
            (settings['graphics']['scale'] * 32) * (obj:getPos()['y'] - 1), settings['graphics']['scale']))
        end

        for key, ntt in pairs(currentLevel:getEntities()) do
          love.graphics.draw(ntt:drawArgs(camera, (settings['graphics']['scale'] * 32) * (ntt:getPos()['x'] - 1),
            (settings['graphics']['scale'] * 32) * (ntt:getPos()['y'] - 1), settings['graphics']['scale']))
        end
      end
      for row, rData in pairs(map[catName]) do
        for column, tile in pairs(rData) do
          if tile ~= 0 and tile:isOnScreen(camera) then
            love.graphics.draw(tile:drawArgs(camera, (settings['graphics']['scale'] * 32) * (tile:getPos()['x'] - 1), (settings['graphics']['scale'] * 32) * (tile:getPos()['y'] - 1), settings['graphics']['scale']))
          end
        end
      end
    end

  end)
end