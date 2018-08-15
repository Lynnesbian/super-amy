--TILES.LUA
--tiles. you're gonna see the word "tile" a lot
local class = require("lib.middleclass.middleclass")
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

tileVictoryGateFG = class("tileVictoryGateFG", Tile)
function tileVictoryGateFG:initialize(x, y)
	Tile.initialize(self, "tileVictoryGateFG", false, x, y)
	self.solid = false
	self:setGraphics(4, 2, 1, 1)
end
tileVictoryGateFG()

tileVictoryGateTopFG = class("tileVictoryGateTopFG", Tile)
function tileVictoryGateTopFG:initialize(x, y)
	hb = getHitbox(8, 13, 17, 1)
	hb = getHitbox(8, 7, 17, 8)
	Tile.initialize(self, "tileVictoryGateTopFG", false, x, y, hb) --todo: add hitbox properly
	self:setGraphics(4, 1, 1, 1)
end
tileVictoryGateTopFG()

tileBridgeRailsFG = class("tileBridgeRailsFG", Tile)
function tileBridgeRailsFG:initialize(x, y)
	Tile.initialize(self, "tileBridgeRailsFG", false, x, y)
	self.solid = false
	self:setGraphics(2, 3, 1, 1)
end
tileBridgeRailsFG()

tileBridgeWood = class("tileBridgeWood", Tile)
function tileBridgeWood:initialize(x, y)
	hb = getHitbox(0, 0, 32, 8)
	Tile.initialize(self, "tileBridgeWood", false, x, y, hb)
	self:setGraphics(2, 4, 1, 1)
end
tileBridgeWood()

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

tileCloudC = class("tileCloudC", Tile)
function tileCloudC:initialize(x, y)
	Tile.initialize(self, "tileCloudC", true, x, y)
	self:setGraphics(4, 0, 2, 1)
end
tileCloudC()

tileVictoryGateBG = class("tileVictoryGateBG", Tile)
function tileVictoryGateBG:initialize(x, y)
	Tile.initialize(self, "tileVictoryGateBG", true, x, y)
	self:setGraphics(1, 2, 1, 1)
end
tileVictoryGateBG()

tileVictoryGateTopBG = class("tileVictoryGateTopBG", Tile)
function tileVictoryGateTopBG:initialize(x, y)
	Tile.initialize(self, "tileVictoryGateTopBG", true, x, y)
	self:setGraphics(1, 1, 1, 1)
end
tileVictoryGateTopBG()

tileWoodPanel = class("tileWoodPanel", Tile)
function tileWoodPanel:initialize(x, y)
	Tile.initialize(self, "tileWoodPanel", true, x, y)
	self:setGraphics(0, 1, 1, 1)
end
tileWoodPanel()

tileTreeA = class("tileTreeA", Tile)
function tileTreeA:initialize(x, y)
	Tile.initialize(self, "tileTreeA", true, x, y)
	self:setGraphics(4, 1, 2, 3)
end
tileTreeA()

tileFlowerA = class("tileFlowerA", Tile)
function tileFlowerA:initialize(x, y)
	Tile.initialize(self, "tileFlowerA", true, x, y)
	self:setGraphics(6, 2, 1, 1)
end
tileFlowerA()

tileFlowerB = class("tileFlowerB", Tile)
function tileFlowerB:initialize(x, y)
	Tile.initialize(self, "tileFlowerB", true, x, y)
	self:setGraphics(6, 3, 1, 1)
end
tileFlowerB()

tileFlowerC = class("tileFlowerC", Tile)
function tileFlowerC:initialize(x, y)
	Tile.initialize(self, "tileFlowerC", true, x, y)
	self:setGraphics(6, 3, 1, 1)
end
tileFlowerC()

tileBridgeRailsBG = class("tileBridgeRailsBG", Tile)
function tileBridgeRailsBG:initialize(x, y)
	Tile.initialize(self, "tileBridgeRailsBG", true, x, y)
	self:setGraphics(0, 2, 1, 1)
end
tileBridgeRailsBG()