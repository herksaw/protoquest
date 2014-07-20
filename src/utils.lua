anim8 = require("libs.anim8.anim8")
atl = require("libs.atl.Loader")

-- Set the scaling factors
function scaleScreen()
	pq.tilemapScaleWidth = love.window.getWidth() / pq.tilemapWidth / 2
	pq.tilemapScaleHeight = love.window.getHeight() / pq.tilemapHeight / 2
	pq.scaledTilemapWidth = pq.tilemapWidth * pq.tilemapScaleWidth
	pq.scaledTilemapHeight = pq.tilemapHeight * pq.tilemapScaleHeight
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

function loadMap(mapPath, filePath)
	atl.path = mapPath
	--atl.path = "maps/"
	pq.map = atl.load(filePath)
	pq.map.layers["collidable"].opacity = 0

	pq.tilemapWidth = pq.map.width * pq.map.tileWidth
	pq.tilemapHeight = pq.map.height * pq.map.tileHeight
end

function updateCamera()
	pq.cam:lookAt(pq.player.x + pq.player.width / 2, pq.player.y + pq.player.height / 2)
	pq.cam:zoomTo(pq.tilemapScaleWidth, pq.tilemapScaleHeight)
end

function drawCamera()
	pq.cam:attach()	
	pq.map:draw()
	pq.player.anim:draw(pq.player.image, pq.player.x, pq.player.y)
	pq.cam:detach()
end