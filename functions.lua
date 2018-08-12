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

function handleCommand(cmd)
  -- print(key)
  if contains({"up", "down", "left", "right"}, cmd) then
    amy:moveInDirection(cmd)
  elseif cmd == "jump" then
    amy:jump()
  end
end

function getHitbox(xOffset, yOffset, width, height)
  return cache['hitboxes'][string.format("%d,%d,%d,%d", xOffset, yOffset, width, height)]
end

function playSound(sfx)
  cache['sfx'][sfx]:play()
end