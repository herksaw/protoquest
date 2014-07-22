local class = require("libs.middleclass.middleclass")
local anim8 = require("libs.anim8.anim8")
local atl = require("libs.atl.Loader")
local camera = require("libs.hump.camera")
local hardoncollider = require("libs.hardoncollider")
require("libs.libSaveTableToFile")

require("src.global")
require("src.utils")
require("src.tests")

require("src.class.player")

pq.player = Player:new()

function love.load()
	-- Setup basic stuffs
	love.window.setTitle(pq.title.." "..pq.version)
	love.graphics.setBackgroundColor(0, 0, 0, 0)

	pq.cam = camera(pq.player.x + pq.player.width / 2, pq.player.y + pq.player.height / 2, 1, 1)
	pq.hc = hardoncollider(120, onCollide, onCollideStop)

	pq.mapPath = "maps/"
	pq.filePath = "1_Prine_1_Reon_1_Home_1_second_floor.tmx"

	checkMapFilePathChanged()

	setAnim(pq.player, "assets/hero/chara01_a.png")

	pq.player.x = pq.tilemapWidth / 2
	pq.player.y = pq.tilemapHeight / 2
	loadObjects()
end

-- The call stacks procedure is important!
function love.update(dt)
	-- File operation
	checkMapFilePathChanged()

	-- Render operation
	scaleGame()
	updateCamera()

	-- Collide operation
	updateTiles()
	pq.hc:update(dt)
	checkCollideMapBounds()

	-- Input operation
	checkPlayerMove(dt)
	
	-- Misc
	checkMapLoaded()	
end

function love.draw()	
	love.graphics.print(debugText, 200, 10)
	love.graphics.print(pq.collideDirection, 200, 20)
	love.graphics.print(math.floor(pq.player.x), 200, 30)
	love.graphics.print(pq.tilemapWidth / 2, 200, 40)
	love.graphics.print(math.floor(pq.player.y), 200, 50)
	love.graphics.print(pq.tilemapHeight / 2, 200, 60)
	drawCamera()
	testing()
end

-- Check if the game is fullscreen now
function love.keypressed(key)
	if key == "escape" and pq.isFullscreen == false then
		love.window.setMode(0, 0, { fullscreen = true })
		pq.isFullscreen = true
	elseif key == "escape" and pq.isFullscreen == true then
		love.window.setMode(800, 600, { fullscreen = false, resizable = true })
		pq.isFullscreen = false
	end
end

-- Check if player is not moving
function love.keyreleased(key)
	if key == "w" or key == "s" or key == "a" or key == "d" then
		pq.player.isIdle = true
		downTimer = 0
	end
end

function love.keypressed(key)
	if key == "p" then
		--table.save(pq.collidableShapes, "test.txt")
		--table.save(pq.collidableTiles, "test.txt")
		--table.save(pq.collidableObjects, "test.txt")
		--table.save(pq.teleportTiles, "test.txt")
		--pq.hc:setSolid(pq.collidableObjects[1])
	end
end

-- Quick hack to the pressed time
downTimer = 0
-- Check if player is moving
function checkPlayerMove(dt)
	if love.keyboard.isDown("w") then
		downTimer = downTimer + dt		
		if downTimer > 0.15 then
			pq.player.y = pq.player.y - pq.player.moveSpeed * dt
			pq.player.anim = pq.player.walkUpAnim
			pq.player.isIdle = false
		else
			pq.player.anim = pq.player.walkUpAnim
			pq.player.anim:gotoFrame(2)
		end
	elseif love.keyboard.isDown("s") then
		downTimer = downTimer + dt		
		if downTimer > 0.15 then
			pq.player.y = pq.player.y + pq.player.moveSpeed * dt
			pq.player.anim = pq.player.walkDownAnim
			pq.player.isIdle = false
		else
			pq.player.anim = pq.player.walkDownAnim
			pq.player.anim:gotoFrame(2)
		end
	elseif love.keyboard.isDown("a") then
		downTimer = downTimer + dt		
		if downTimer > 0.15 then
			pq.player.x = pq.player.x - pq.player.moveSpeed * dt
			pq.player.anim = pq.player.walkLeftAnim
			pq.player.isIdle = false
		else
			pq.player.anim = pq.player.walkLeftAnim
			pq.player.anim:gotoFrame(2)
		end
	elseif love.keyboard.isDown("d") then
		downTimer = downTimer + dt		
		if downTimer > 0.15 then
			pq.player.x = pq.player.x + pq.player.moveSpeed * dt
			pq.player.anim = pq.player.walkRightAnim
			pq.player.isIdle = false
		else
			pq.player.anim = pq.player.walkRightAnim
			pq.player.anim:gotoFrame(2)
		end
	end

	if not pq.player.isIdle then
		if pq.player.anim.status == "paused" then
			pq.player.anim:resume()
		end
		pq.player.anim:update(dt)
	elseif pq.player.isIdle then
		if pq.player.anim.status == "playing" then
			pq.player.anim:pause()
			pq.player.anim:gotoFrame(2)
		end
	end
end

debugText = "uncollide"
function onCollide(dt, shapeA, shapeB)
	debugText = "collided!"
	local tile = nil

	if shapeA == pq.collidableObjects[1] then		
		for key, value in pairs(pq.collidableShapes) do
			if shapeB == value then
				tile = pq.collidableTiles[key]
				checkObjectCollidable(shapeA, shapeB, tile)
			end
		end
		for key, value in pairs(pq.teleportShapes) do
			if shapeB == value then
				tile = pq.teleportTiles[key]
				checkObjectTeleport(shapeA, shapeB, tile)
			end
		end
	elseif shapeB == pq.collidableObjects[1] then
		for key, value in pairs(pq.collidableShapes) do
			if shapeA == value then
				tile = pq.collidableTiles[key]
				checkObjectCollidable(shapeA, shapeB, tile)
			end
		end
		for key, value in pairs(pq.teleportShapes) do
			if shapeA == value then
				tile = pq.teleportTiles[key]
				checkObjectTeleport(shapeA, shapeB, tile)
			end
		end
	end
end

function onCollideStop(dt, shapeA, shapeB)
	debugText = "uncollided!"
	pq.collideDirection = "none"
end

function checkObjectCollidable(shapeA, shapeB, tile)
	if shapeA == pq.collidableObjects[1] then
		if pq.collideDirection == "none" then
			checkCollideDirection(pq.player, tile)
		end	

		if pq.collideDirection == "top" then			
			pq.player.y = tile.y + 16.1	
		elseif pq.collideDirection == "bottom" then			
			pq.player.y = tile.y - 32.1	
		elseif pq.collideDirection == "left" then
			pq.player.x = tile.x + 16.1
		elseif pq.collideDirection == "right" then			
			pq.player.x = tile.x - 24.1
		end
	elseif shapeB == pq.collidableObjects[1] then		
		if pq.collideDirection == "none" then
			checkCollideDirection(pq.player, tile)
		end

		if pq.collideDirection == "top" then			
			pq.player.y = tile.y + 16.1
		elseif pq.collideDirection == "bottom" then
			pq.player.y = tile.y - 32.1
		elseif pq.collideDirection == "left" then		
			pq.player.x = tile.x + 16.1
		elseif pq.collideDirection == "right" then			
			pq.player.x = tile.x - 24.1
		end
	end
end

function checkObjectTeleport(shapeA, shapeB, tile)
	if shapeA == pq.collidableObjects[1] then
		pq.filePath = tile.filePath
	elseif shapeB == pq.collidableObjects[1] then
		pq.filePath = tile.filePath
	end
end