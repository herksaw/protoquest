local anim8 = require("libs.anim8.anim8")
local atl = require("libs.atl.Loader")
local hc = require("libs.hardoncollider")

-- Set the scaling factors
function scaleGame()
	pq.scaleWidth = love.window.getWidth() / pq.tilemapWidth
	pq.scaleHeight = love.window.getHeight() / pq.tilemapHeight
	pq.scaledTilemapWidth = pq.tilemapWidth * pq.scaleWidth
	pq.scaledTilemapHeight = pq.tilemapHeight * pq.scaleHeight
	--[[
	if pq.oldTilemapScaleWidth ~= pq.scaleWidth then
		for key, value in pairs(pq.collidableShapes) do
			value:scale(pq.scaleWidth)
		end

		for key, value in pairs(pq.collidableObjects) do
			value:scale(pq.scaleWidth)
		end
		pq.oldTilemapScaleWidth = pq.scaleWidth
	end]]
end

-- Set the animation of characters
function setAnim(char, filePath)
	char.image = love.graphics.newImage(filePath)
	char.grid = anim8.newGrid(24, 32, char.image:getWidth(), char.image:getHeight(), 0, 0, 0.15)
	char.walkUpAnim = anim8.newAnimation(char.grid("1-3", 1), 0.15)
	char.walkDownAnim = anim8.newAnimation(char.grid("1-3", 3), 0.15)
	char.walkLeftAnim = anim8.newAnimation(char.grid("1-3", 4), 0.15)
	char.walkRightAnim = anim8.newAnimation(char.grid("1-3", 2), 0.15)
	char.anim = char.walkDownAnim
end

function checkMapFilePathChanged()
	if pq.oldFilePath ~= pq.filePath then
		pq.oldFilePath = pq.filePath

		clearTables()
		loadMapFile()
		loadTiles()
		pq.mapLoaded = true
	end
end

-- Load tilemap with maps directory and the map file path
function loadMapFile()
	atl.path = pq.mapPath
	--atl.path = "maps/"
	pq.map = atl.load(pq.filePath)
	pq.map.layers["collidable"].visible = false

	pq.tilemapWidth = pq.map.width * pq.map.tileWidth
	pq.tilemapHeight = pq.map.height * pq.map.tileHeight
end

function checkMapLoaded()
	if pq.mapLoaded == true then
		pq.mapLoaded = false
		pq.player.x = pq.tilemapWidth / 2
		pq.player.y = pq.tilemapHeight / 2
	end
end

function loadObjects()
	pq.collidableObjects[1] = pq.hc:addRectangle(pq.player.x, pq.player.y, pq.player.width, pq.player.height)
end

function loadTiles()	
	for x, y, tile in pq.map.layers["collidable"]:iterate() do
		for key, value in pairs(tile.properties) do
			if key == "type" and value == "collide_all" then
				pq.collidableTiles[#pq.collidableTiles + 1] = { x = x * tile.width, y = y * tile.height, width = 16, height = 16 }
				pq.collidableShapes[#pq.collidableShapes + 1] = pq.hc:addRectangle(x * tile.width, y * tile.height, tile.width, tile.height)
				pq.hc:setPassive(pq.collidableShapes[#pq.collidableShapes + 1])
			end
		end
	end

	for key, value in pairs(pq.collidableShapes) do
		pq.hc:addToGroup("immovable", value)
	end

	for x, y, tile in pq.map.layers["foreground"]:iterate() do
		local tileFilePath = ""
		local tileX = 0
		local tileY = 0
		local tileWidth = 16
		local tileHeight = 16
		local index = 0
		local isFound = false

		for key, value in pairs(tile.properties) do
			if key == "type" and value == "teleport" then
			    tileX = x * tile.width
				tileY = y * tile.height
				isFound = true
				--[[
				pq.teleportTiles[#pq.teleportTiles + 1] = { x = x * tile.width, y = y * tile.height, width = 16, height = 16 }
				pq.teleportShapes[#pq.teleportShapes + 1] = pq.hc:addRectangle(x * tile.width, y * tile.height, tile.width, tile.height)
				pq.hc:setPassive(pq.teleportShapes[#pq.teleportShapes + 1])
				]]
			elseif key == "filePath" then
				tileFilePath = value
			end
		end

		if isFound == true then
			pq.teleportTiles[#pq.teleportTiles + 1] = { x = tileX, y = tileY, width = tileWidth, height = tileHeight, filePath = tileFilePath }
			pq.teleportShapes[#pq.teleportShapes + 1] = pq.hc:addRectangle(tileX, tileY, tileWidth, tileHeight)
			pq.hc:setPassive(pq.teleportShapes[#pq.teleportShapes + 1])
		end
	end

	for key, value in pairs(pq.teleportShapes) do
		pq.hc:addToGroup("immovable", value)
	end
end

function updateTiles()
	pq.collidableObjects[1]:moveTo(pq.cam:pos())
	--[[
	for key, value in pairs(pq.collidableTiles) do
		pq.collidableShapes[key]:moveTo(pq.cam:cameraCoords(value.x, value.y))
	end]]
end

function adjustCameraCoords(x, y, width, height)

end	

-- Let the camera follow player and scale all the objects as well
function updateCamera()
	pq.cam:lookAt(pq.player.x + pq.player.width / 2, pq.player.y + pq.player.height / 2)
	pq.cam:zoomTo(pq.scaleWidth, pq.scaleHeight)
end

-- Render the scene to player
function drawCamera()
	pq.cam:attach()
	pq.map.layers["front"].visible = false
	pq.map.layers["foreground"].visible = true
	pq.map.layers["background"].visible = true
	pq.map:draw()
	
	pq.player.anim:draw(pq.player.image, pq.player.x, pq.player.y)
	pq.map.layers["front"].visible = true
	pq.map.layers["foreground"].visible = false
	pq.map.layers["background"].visible = false
	pq.map:draw()
	
	drawBBox()

	pq.cam:detach()
end

function drawBBox()
	for key, value in pairs(pq.collidableShapes) do
		value:draw("line")
	end

	for key, value in pairs(pq.teleportShapes) do
		value:draw("line")
	end

	for key, value in pairs(pq.collidableObjects) do
		value:draw("line")
	end
end

-- The collide direction is player-centric
function checkCollideDirection(obj, target)
	local objBottom = obj.y + obj.height
	local objRight = obj.x + obj.width
	local targetBottom = target.y + target.height
	local targetRight = target.x + target.width

	local bCollision = math.abs(objBottom - target.y)
	local tCollision = math.abs(obj.y - targetBottom)
	local lCollision = math.abs(obj.x - targetRight)
	local rCollision = math.abs(objRight - target.x)

	if tCollision < bCollision and tCollision < lCollision and tCollision < rCollision then
		pq.collideDirection = "top"
	elseif bCollision < tCollision and bCollision < lCollision and bCollision < rCollision then
		pq.collideDirection = "bottom"
	elseif lCollision < rCollision and lCollision < tCollision and lCollision < bCollision then
		pq.collideDirection = "left"
	elseif rCollision < lCollision and rCollision < tCollision and rCollision < bCollision then
		pq.collideDirection = "right"
	end

	-- Taken from http://stackoverflow.com/questions/5062833/detecting-the-direction-of-a-collision
	--[[
	local objBottom = obj.y + obj.height
	local objRight = obj.x + obj.width
	local targetBottom = target.y + 16
	local targetRight = target.x + 16

	local bCollision = targetBottom - obj.y
	local tCollision = objBottom - target.y
	local lCollision = objRight - target.x
	local rCollision = targetRight - obj.x

	if tCollision < bCollision and tCollision < lCollision and tCollision < rCollision then
		pq.collideDirection = "top"
	elseif bCollision < tCollision and bCollision < lCollision and bCollision < rCollision then
		pq.collideDirection = "bottom"
	elseif lCollision < rCollision and lCollision < tCollision and lCollision < bCollision then
		pq.collideDirection = "left"
	elseif rCollision < lCollision and rCollision < tCollision and rCollision < bCollision then
		pq.collideDirection = "right"
	end]]
end

function checkCollideMapBounds()
	if pq.player.x <= 0 then
		pq.player.x = 0
	elseif pq.player.x >= pq.tilemapWidth - pq.player.width then
		pq.player.x = pq.tilemapWidth - pq.player.width
	elseif pq.player.y <= 0 then
		pq.player.y = 0
	elseif pq.player.y >= pq.tilemapHeight - pq.player.height then
		pq.player.y = pq.tilemapHeight - pq.player.height
	end
end

function clearTables()
	pq.collidableShapes = {}
	pq.collidableTiles = {}
	pq.teleportShapes = {}
	pq.teleportTiles = {}
end