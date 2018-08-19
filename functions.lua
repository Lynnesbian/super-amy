--FUNCTIONS.LUA
--most of the functions used by the game
local class = require("lib.middleclass.middleclass")
--BASIC STUFF

--- Shuffles a table.
--@param tbl The table to shuffle
--@source https://gist.github.com/Uradamus/10323382
function shuffle(tbl)
  size = #tbl
  for i = size, 1, -1 do
    local rand = math.random(size)
    tbl[i], tbl[rand] = tbl[rand], tbl[i]
  end
  return tbl
end
 
---Reverses a table.
--@param tbl The table to reverse
--@source https://gist.github.com/balaam/3122129#gistcomment-1680319
function reverse(tbl)
  for i=1, math.floor(#tbl / 2) do
    local tmp = tbl[i]
    tbl[i] = tbl[#tbl - i + 1]
    tbl[#tbl - i + 1] = tmp
  end
end

---Returns true if <tt>key</tt> is in <tt>tbl</tt>.
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

--- Whether or not two variables are within <tt>threshold</tt> of each other.
--@param varA The first variable for comparison
--@param varB The second
--@param threshold The distance to look for
--@return boolean
function withinXOf(varA, varB, threshold)
	return math.abs(varA - varB) <= threshold
end

--- Move <tt>value</tt> at most <tt>stepSize</tt> steps towards <tt>value</tt>. As Lua does not allow for modifying parameters, instead of changing <tt>value</tt> in place, this function returns a new value to use for <tt>value</tt>.
--@param value The number value to pull
--@param target The target to pull <tt>value</tt> towards
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

---Inline if statement. If <tt>condition</tt>, then return <tt>x</tt>, else <tt>y</tt>. Similar to the ternary operator, although both <tt>x</tt> and <tt>y</tt> are always evaluated.
--@param condition The condition to test
--@param x Return this if <tt>condition</tt> is true
--@param y Return this if <tt>condition</tt> is false
--@return boolean
function iif(condition, x, y) --NOTE: both x and y are always evaluated!
	if condition then return x else return y end
end

---Rounds a number to the nearest <tt>multiple</tt>.
--@param x The number to round
--@param multiple The multiple to round <tt>x</tt> to
--@return number
function round(x, multiple) --lua...
  return math.floor((x + multiple / 2) / multiple) * multiple
end

---Returns true if <tt>var</tt> is between <tt>lower</tt> and <tt>upper</tt>.
--@param var The variable to check
--@param lower The lower boundry
--@param upper The upper boundry
--@param inclusive If true, comparison will be inclusive
function isBetween(var, lower, upper, inclusive)
	if inclusive then
		return var >= lower and var <= upper
	else
		return var > lower and var < upper
	end
end

---Returns a table of all the instances of <tt>targetClass</tt> within <tt>tbl</tt>.
--@param targetClass The class to look for
--@param tbl The table to search
function getAllInstancesOf(targetClass, tbl)
  instances = {}
  for k,obj in pairs(tbl) do
    if obj.class.name == targetClass.name or obj:isInstanceOf(targetClass) then table.insert(instances, obj) end
  end
  return instances
end

---Returns true if <tt>tbl</tt> contains <tt>value</tt>.
--@param tbl The table to check
--@param value The value to check for
--@return boolean
function contains(tbl, value)
  for k, v in pairs(tbl) do
    if v == value then return true end
  end
  return false
end

---Searches <tt>tbl</tt> for <tt>value</tt> and returns its key.
--@param tbl The table to search
--@param value The value to check for
--@return string
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

---Plays a sound effect. Does not allow for the same sound effect to be played more than once at a time.
--@param sfx The sound effect to play, e.g. "jump.ogg"
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