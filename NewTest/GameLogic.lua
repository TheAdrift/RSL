require 'test'

function LoadRoom ( gameView, room, where )
	gameView:loadLayers ( room..'.lua' )
	gameView:clampTo (gameView.map)
	if the.player then
		--for _, spr in pairs(gameView.sprites) do
			--if spr:instanceOf(target) then
				--if spr.ID == where then
					--the.player.x = spr.x
					--the.player.y = spr.y
				--else 
					the.player.x = 64
					the.player.y = 64
				--end
			--end
		--end
		--gameView:moveToFront (the.player)
		gameView.focus = the.player
	end
end

Player = Fill:extend
{
	width = 32,
	height = 64,
	fill = {255, 0, 0, 255},
	drag = {x = 1280, y = 640},
	maxVelocity = {x = 640, y = 640},
	minVelocity = {x = -640, y = -640},
	solid = true,
	--falling = true,
	jump = false,
	gravity = 640,
	acceleration = {x = 0, y = 640},
	jumpForce = 500,
	jumpHold = 0,
	maxJump = 1,
	run = 400,
	
	onUpdate = function (self, elapsed)
		--[[ This code was attempting to solve an imaginary problem. Backwards. Set velocity.y to 0 on collision instead.
		if self.falling == true then
			self.acceleration.y = self.gravity
		else
			self.acceleration.y = 0
		end --]]

		--[[ The following code was intended to mimic a decaying jump
		(sustained jump by holding the button). I suspect I had the right
		approach, but probably the wrong formula.
		Didn't feel right, needed something simpler to test.]]

		--[[
		if the.keys:pressed(' ') then
			if self.jumpHold == 0 then
				self.velocity.y = - self.jumpForce
			elseif self.jumpHold > 0 and self.jumpHold < self.maxJump then
				self.velocity.y = self.velocity.y - (self.jumpForce/(self.jumpForce*self.jumpHold+1))
			elseif self.jumpHold <= self.maxJump then
				self.jumpHold = self.maxJump
			end
			--self.jumpHold = self.jumpHold + 1
			self.jumpHold = self.jumpHold + elapsed
		end

		if the.keys:justPressed(' ') then
			self.jumpHold = 0
		end
		--]]

		---[[ This is super simple and broken for testing purposes.
		if the.keys:pressed(' ') and self.jump == false then
			self.velocity.y = - self.jumpForce
			self.jump = true
		end
		
		if self.velocity.y >= 0 then
			self.jump = false
		end
		--]]
		
		
		if the.keys:pressed('a') then
			self.velocity.x = -self.run
			
		elseif the.keys:pressed('d') then
			self.velocity.x = self.run
			
		else
			self.velocity.x = 0
		end
	end,
	---[[
	onCollide = function (self, other)
		if other.solid then
			--[[The following needs to be active in order for falling to
			work correctly. (At present the player falls too quickly, and
			can sometimes fall through solids.)
			However, see note in Game object about what this breaks.]]
			--[[
			if self.velocity.y > 0 then
				self.velocity.y = 0
			end --]]
			other:displace (self)
		end
	end --]]
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
		self.x = (the.mouse.x - (self.width/2)) - the.view.translate.x
		self.y = (the.mouse.y - (self.height/2)) - the.view.translate.y
	end
}

Door = Fill:extend
{
	visible = false,
	onCollide = function (self, other)
		if other:instanceOf(Player) then
			if self.room then
				LoadRoom(the.app.view, self.room, self.target)
			end
		end
	end
}

target = Fill:extend
{
	--[[Theoretically, where the player should end up in the next room
	upon entering the corresponding door. The method I implemented
	in lines #7-#17 does not function.
	We could try replacing each target instance's "ID" property in Tiled
	with a "the_" property, so that zoetrope creates the targets as the.[whatever]
	Then we could access their location with the.[whatever].x , the.[whatever].y
	Maybe.]]
	visible = false,
	solid = false
}


Game = View:extend
{
	onNew = function (self)
		the.player = Player:new()
		the.pointer = Pointer:new()
		LoadRoom (self, 'test', 00)
		self:add (the.player)
		self:add (the.pointer)
	end,

	onUpdate = function (self, elapsed)
		self.collision:collide (the.player) --[[weirdly, this seems
		to stop the player from ever falling.
		As if it is registering a collision with the whole layer,
		not simply individual tiles. I have no idea how to fix at this time.]]
		
		--[[However, while allowing the player to fall as expected,
		the following does not reset y-velocity to zero,
		because a collision is never registered.
		This results in extreme weirdness.]]
		--[[
		self.collision:displace (the.player)
		--]]
		self.objects:collide (the.player)
		self.objects:collide (self.objects)
	end
}
