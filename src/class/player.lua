--package.path = package.path .. ";../../?.lua"

local class = require("libs.middleclass.middleclass")

-- Player class
Player = class("Player")

function Player:initialize()
	self.image = nil
	self.grid = nil
	self.walkUpAnim = nil
	self.walkDownAnim = nil
	self.walkLeftAnim = nil
	self.walkRightAnim = nil
	self.anim = nil

	self.isIdle = true
	self.x = 0
	self.y = 0
	self.width = 24
	self.height = 32
	self.moveSpeed = 50
end