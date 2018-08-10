--TILES.LUA
--tiles. you're gonna see the word "tile" a lot
local class = require("lib.middleclass")
require("functions")
require("classes")

-- FOREGROUND --
tileSandstone = class("tileSandstone", Tile)
function tileSandstone:initialize(x, y) --bg?   -  -  iX iY w  h  
	Tile.initialize(self, "tileSandstone", false, x, y)
	self:setGraphics(0, 1, 1, 1)
end
tileSandstone() --create and release one to populate the Tile Table™ and load the spritesheet(?)

tileDirtBlock = class("tileDirtBlock", Tile)
function tileDirtBlock:initialize(x, y)
	Tile.initialize(self, "tileDirtBlock", false, x, y)
	self:setGraphics(1, 2, 1, 1)
end
tileDirtBlock()

tileBrick = class("tileBrick", Tile)
function tileBrick:initialize(x, y)
	Tile.initialize(self, "tileBrick", false, x, y)
	self:setGraphics(0, 2, 1, 1)
end
tileBrick()

tileCaveBrick = class("tileCaveBrick", Tile)
function tileCaveBrick:initialize(x, y)
	Tile.initialize(self, "tileCaveBrick", false, x, y)
	self:setGraphics(0, 3, 1, 1)
end
tileCaveBrick()

tileDirtSurface = class("tileDirtSurface", Tile)
function tileDirtSurface:initialize(x, y)
	Tile.initialize(self, "tileDirtSurface", false, x, y)
	self:setGraphics(1, 1, 1, 1)
end
tileDirtSurface()

tileGrass = class("tileGrass", Tile)
function tileGrass:initialize(x, y)
	Tile.initialize(self, "tileGrass", false, x, y)
	self.solid = false
	self:setGraphics(1, 0, 1, 1)
end
tileGrass()

-- BACKGROUND --
tileCloudA = class("tileCloudA", Tile)
function tileCloudA:initialize(x, y)
	Tile.initialize(self, "tileCloudA", true, x, y)
	self:setGraphics(0, 0, 2, 1)
end
tileCloudA()

tileCloudB = class("tileCloudB", Tile)
function tileCloudB:initialize(x, y)
	Tile.initialize(self, "tileCloudB", true, x, y)
	self:setGraphics(2, 0, 2, 1)
end
tileCloudB()