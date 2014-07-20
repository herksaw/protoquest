function testing()
	--testing
	love.graphics.print(pq.tilemapScaleWidth.." "..pq.tilemapScaleHeight, 0, 0)
	love.graphics.print(love.window.getWidth().." "..love.window.getHeight(), 0, 10)
	love.graphics.print(pq.tilemapScaleWidth * pq.tilemapWidth.." "..pq.tilemapScaleHeight * pq.tilemapHeight, 0, 20)
	love.graphics.print(pq.map.tilesets["village"].tileProperties[720].path, 0, 30)
	
	local x, y = pq.cam:pos()
	love.graphics.print(x .. " " .. y, 0, 40)
	love.graphics.print(pq.player.x .. " " .. pq.player.y, 0, 70)
	--testing
end