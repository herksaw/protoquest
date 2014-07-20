local class = require("libs.middleclass.middleclass")
local anim8 = require("libs.anim8.anim8")
local atl = require("libs.atl.Loader")
local camera = require("libs.hump.camera")

require("src.global")
require("src.utils")
require("src.tests")

require("src.class.player")

pq.player = Player:new()

function love.load()
	-- Setup basic stuffs
	love.window.setTitle(pq.title.." "..pq.version)
	love.graphics.setBackgroundColor(0, 0, 0, 0)

	loadMap("maps/1_Prine/1_Reon/1_Home/", "1_second_floor.tmx")
	setAnim(pq.player, "assets/hero/chara01_a.png")

	pq.player.x = pq.tilemapWidth / 2
	pq.player.y = pq.tilemapHeight / 2

	pq.cam = camera(pq.player.x + pq.player.width / 2, pq.player.y + pq.player.height / 2)
end

function love.update(dt)
	scaleScreen()
	checkPlayerMove(dt)

	pq.cam:lookAt(pq.player.x + pq.player.width / 2, pq.player.y + pq.player.height / 2)
	pq.cam:zoomTo(pq.tilemapScaleWidth, pq.tilemapScaleHeight)
	--[[
	--pq.cam:setWorld(-100 * pq.tilemapScaleWidth, -100 * pq.tilemapScaleHeight, pq.scaledTilemapWidth + 20, pq.scaledTilemapHeight + 30)
	pq.cam:setWorld(-100, -100, pq.scaledTilemapWidth + 100, pq.scaledTilemapHeight + 100)
	pq.cam:setWindow(0, 0, love.window.getWidth(), love.window.getHeight())
	pq.cam:setPosition(pq.player.x + pq.player.width / 2, pq.player.y + pq.player.height / 2)
	--pq.cam:setScale(pq.tilemapScaleWidth, pq.tilemapScaleHeight)]]
end

function love.draw()
	pq.cam:attach()	
	pq.map:draw()
	pq.player.anim:draw(pq.player.image, pq.player.x, pq.player.y)
	pq.cam:detach()
	--[[
	love.graphics.push()
	love.graphics.scale(pq.tilemapScaleWidth, pq.tilemapScaleHeight)
	pq.map:draw()
	pq.player.anim:draw(pq.player.image, pq.player.x, pq.player.y)
	love.graphics.pop()
	]]
	--[[
	pq.cam:draw(function(l, t, w, h)
		love.graphics.push()
		love.graphics.scale(pq.tilemapScaleWidth, pq.tilemapScaleHeight)
		pq.map:draw()
		pq.player.anim:draw(pq.player.image, pq.player.x, pq.player.y)
		love.graphics.pop()
	end)]]
	--[[
	love.graphics.push()
	love.graphics.scale(pq.tilemapScaleWidth, pq.tilemapScaleHeight)
	love.graphics.translate(95, 80) -- Temporarily workaround with some quick hacks
	pq.map:draw()
	pq.player.anim:draw(pq.player.image, 100, 100)
	love.graphics.pop()]]

	--testing
	love.graphics.print(pq.tilemapScaleWidth.." "..pq.tilemapScaleHeight, 0, 0)
	love.graphics.print(love.window.getWidth().." "..love.window.getHeight(), 0, 10)
	love.graphics.print(pq.tilemapScaleWidth * pq.tilemapWidth.." "..pq.tilemapScaleHeight * pq.tilemapHeight, 0, 20)
	love.graphics.print(pq.map.tilesets["village"].tileProperties[720].path, 0, 30)
	
	local x, y = pq.cam:pos()
	love.graphics.print(x .. " " .. y, 0, 40)
	--[[
	local l, t, w, h = pq.cam:getWorld()
	love.graphics.print(l .. " " .. t .. " " .. w .. " " .. h, 0, 50)
	local l, t, w, h = pq.cam:getWindow()
	love.graphics.print(l .. " " .. t .. " " .. w .. " " .. h, 0, 60)
	]]
	love.graphics.print(pq.player.x .. " " .. pq.player.y, 0, 70)
	--testing
end

-- Check if fullscreen now
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
	end
end

-- Check if player is moving
function checkPlayerMove(dt)
	if love.keyboard.isDown("w") then
		pq.player.y = pq.player.y - pq.player.moveSpeed * dt
		pq.player.anim = pq.player.walkUpAnim
		pq.player.isIdle = false
	elseif love.keyboard.isDown("s") then
		pq.player.y = pq.player.y + pq.player.moveSpeed * dt
		pq.player.anim = pq.player.walkDownAnim
		pq.player.isIdle = false
	elseif love.keyboard.isDown("a") then
		pq.player.x = pq.player.x - pq.player.moveSpeed * dt
		pq.player.anim = pq.player.walkLeftAnim
		pq.player.isIdle = false
	elseif love.keyboard.isDown("d") then
		pq.player.x = pq.player.x + pq.player.moveSpeed * dt
		pq.player.anim = pq.player.walkRightAnim
		pq.player.isIdle = false
	end

	if not pq.player.isIdle then
		if pq.player.anim.status == "paused" then
			pq.player.anim:resume()
		end
		pq.player.anim:update(dt)
	elseif pq.player.isIdle then
		if pq.player.anim.status == "playing" then
			pq.player.anim:pauseAtStart()
		end
	end
end