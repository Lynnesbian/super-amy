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

---Returns true is `key` is in `tbl`.
--@param key The key to search for
--@param tbl The table to search
--@return boolean
function inArray(key, tbl)
	for k,v in pairs(tbl) do
		if (v == key) then return true end
	end
	return false
end

---Deeply clones a table.
--@param tbl The table to clone
--@param seen Used when the function calls itself. Don't pass this argument when calling the function yourself.
--@return table
function cloneTable(tbl, seen) --thanks to https://stackoverflow.com/a/26367080/4480824
  if type(tbl) ~= 'table' then return tbl end
  if seen and seen[tbl] then return seen[tbl] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(tbl))
  s[tbl] = res
  for k, v in pairs(tbl) do res[cloneTable(k, s)] = cloneTable(v, s) end
  return res
end

--- Whether or not two variables are within `threshold` of each other.
--@param varA The first variable for comparison
--@param varB The second
--@param threshold The distance to look for
--@return boolean
function withinXOf(varA, varB, threshold)
	return math.abs(varA - varB) <= threshold
end

--- Move `value` at most `stepSize` steps towards `value`. As Lua does not allow for modifying parameters, instead of changing `value` in place, this function returns a new value to use for `value`.
--@param value The number value to pull
--@param target The target to pull `value` towards
--@param stepsize How big a step the function makes
--@return number
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

---Inline if statement. If `condition`, then return `x`, else `y`. Similar to the ternary operator, although both `x` and `y` are always evaluated.
--@param condition The condition to test
--@param x Return this if `condition` is true
--@param y Return this if `condition` is false
--@return boolean
function iif(condition, x, y) --NOTE: both x and y are always evaluated!
	if condition then return x else return y end
end

---Rounds a number to the nearest `multiple`.
--@param x The number to round
--@param multiple The multiple to round `x` to
--@return number
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

function keyFromValue(tbl, value)
  for k,v in pairs(tbl) do
    if v == value then
      return k
    end
  end
  return nil
end

--GAME-SPECIFIC STUFF

function handleCommand(cmd, dt)
  if cmd == "restart" then
    love.event.quit("restart")
  elseif cmd == "toggle-mode" and gameState['key-repeat-timer'] == 0 then
    if gameState['mode'] == 'editor' then
      gameState['mode'] = 'ingame'
    else
      gameState['mode'] = 'editor'
    end
  end
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
  if gameState['key-repeat-timer'] == 0 then
    gameState['key-repeat-timer'] = settings['game']['key-repeat-time']
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

  love.graphics.setColor(unpack(currentLevel:getBackgroundColour()))
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  love.graphics.setColor(1, 1, 1)

  for key, catName in pairs({'bg', 'fg'}) do
    if catName == "fg" then
      --draw objects and entities before fg but after bg
      for k, category in pairs({"Objects", "Entities"}) do
        for key, thing in pairs(currentLevel["get"..category](currentLevel)) do
          if thing:isOnScreen(camera) then
            love.graphics.draw(thing:drawArgs(camera, (settings['graphics']['scale'] * 32) * (thing:getPos()['x'] - 1),
            (settings['graphics']['scale'] * 32) * (thing:getPos()['y'] - 1), settings['graphics']['scale']))
          end
        end
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

end