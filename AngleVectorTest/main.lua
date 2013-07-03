STRICT = true
DEBUG = true

require "zoetrope"
require "VectorFunctions"

--[[The following are objects to test the vector functions I have written.]]

TestBox = Fill:extend 
{
	width = 64,
	height = 64,
	fill = { 0, 0, 255, 255 },
	refAngle = 0, --a general reference angle.
	distPointer = 0, --distance from this sprite to the pointer.
	charge = 0, --this value builds up to a maximum while the left mouse button is held.
	chargeRate = 120, --the rate, per second, at which to charge.
	chargeMax = 640, --the maximum value to charge up.
	diff_x = 0, diff_y = 0, --these are in place to check the vector math.
	check_x = 0, check_y = 0, --these are calculated from raw position data as a reference.
	
	--[[
	onStartFrame = function ( self, elapsed )
		self.acceleration = { x = 0, y = 0 }
	end, --]]
	
	onUpdate = function ( self, elapsed )
		--Get angle to mouse pointer and update refAngle value.
		if the.pointer then
			self.refAngle = getAngle ( self, the.pointer )
			self.distPointer = getMagnitude ( self.x-the.pointer.x, self.y-the.pointer.y )
			self.diff_x = decompVectorX ( self.refAngle, self.distPointer )
			self.diff_y = decompVectorY ( self.refAngle, self.distPointer )
			self.check_x = ( self.x + self.width/2 ) - ( the.pointer.x + the.pointer.width/2 )
			self.check_y = ( self.y + self.height/2 ) - ( the.pointer.y + the.pointer.height/2 )
		else
			self.refAngle = self.refAngle
			self.distPointer = self.distPointer
		end
		
		--When left mouse button released, move according to refAngle and charge.
		--This must resolve *before* checking the state of the mouse button.
		if the.mouse:justReleased ( 'l' ) then
			impelAlong ( self, self.refAngle, self.charge )
			self.charge = 0
		end

		--Get mouse control state
		--Charge while left mouse button is held.
		if the.mouse:pressed ( 'l' ) then
			if self.charge < self.chargeMax then
				self.charge = self.charge + elapsed*self.chargeRate
			elseif self.charge >= self.chargeMax then
				self.charge = self.chargeMax
			end
		else
			self.charge = 0
		end
		
		--Accelerate toward pointer while right mouse button is held.
		if the.mouse:pressed ( 'r' ) then
			set_accelAlong ( self, self.refAngle, self.distPointer )
		else
			self.acceleration = { x = 0, y = 0 }
		end
		
	end
}

Pointer = Fill:extend
{ --[[A simple little mouse cursor box. Yay!]]
	width = 32,
	height = 32,
	fill = {0, 0, 0, 0},
	border = { 255, 0, 0, 255 },
	
	onUpdate = function(self, elapsed) --[[Weirdness resolved.
	Subtract the.view.translate.x,.y from the relevant parameters to track
	the mouse position relative to the current room.]]
		self.x = (the.mouse.x - (self.width/2)) -- the.view.translate.x
		self.y = (the.mouse.y - (self.height/2)) -- the.view.translate.y
	end
}

the.app = App:new
{
	onRun = function ( self, elapsed )
		the.pointer = Pointer:new()
		the.box = TestBox:new{ x = the.app.width/2, y = the.app.height/2 }
		self:add(the.pointer)
		self:add(the.box)
	end
}
