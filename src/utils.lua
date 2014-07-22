anim8 = require("libs.anim8.anim8")
atl = require("libs.atl.Loader")
hc = require("libs.hardoncollider")

-- Set the scaling factors
function scaleGame()
	pq.scaleWidth = love.window.getWidth() / pq.tilemapWidth / 2
	pq.scaleHeight = love.window.getHeight() / pq.tilemapHeight / 2
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

-- Load tilemap with maps directory and the map file path
function loadMap(mapPath, filePath)
	atl.path = mapPath
	--atl.path = "maps/"
	pq.map = atl.load(filePath)
	pq.map.layers["collidable"].visible = false

	pq.tilemapWidth = pq.map.width * pq.map.tileWidth
	pq.tilemapHeight = pq.map.height * pq.map.tileHeight
end

function loadCollidableTiles()
	pq.collidableObjects[1] = pq.hc:addRectangle(pq.player.x, pq.player.y, pq.player.width, pq.player.height)
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
end

function updateCollidableTiles()
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
	--[[
	for key, value in pairs(pq.collidableShapes) do
		value:draw("line")
	end

	for key, value in pairs(pq.collidableObjects) do
		value:draw("line")
	end
	]]
	pq.player.anim:draw(pq.player.image, pq.player.x, pq.player.y)
	pq.map.layers["front"].visible = true
	pq.map.layers["foreground"].visible = false
	pq.map.layers["background"].visible = false
	pq.map:draw()
	pq.cam:detach()
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