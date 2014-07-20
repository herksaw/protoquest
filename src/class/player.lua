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
end