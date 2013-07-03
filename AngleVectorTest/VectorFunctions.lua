function getAngle ( from, to )
--[[Returns the angle of a line calculated between two sprites.
from: This object originates the line whose angle is calculated. Must be a sprite.
to: This object terminates the line whose angle is calculated. Must be a sprite.]]

	local angle = 0
	if from:instanceOf ( Sprite ) and to:instanceOf ( Sprite ) then
		local diff_x = ( to.x + to.width/2 ) - ( from.x + from.width/2 )
		local diff_y = ( to.y + to.height/2 ) - ( from.y + from.height/2 )
		if diff_x == 0 and diff_y == 0 then
		--do some error handling stuff here. For now:
			angle = 0
		else
		--find the angle (by inverse tangent function) in radians.
			angle = math.atan2( diff_y, diff_x )
		end
		return angle
	end

end

function getMagnitude ( dx, dy )
--[[Returns the magnitude (Pythagorean hypotenuse) of a vector with components (dx, dy).]]
	local magnitude = 0
	if dx == 0 and dy == 0 then magnitude = 0
	else
		magnitude = math.sqrt((dx^2)+(dy^2))
	end
	return magnitude
end

function decompVectorX ( angle, magnitude )
--[[Returns the x component of a vector with angle 'angle' and magnitide 'magnitude'.]]
	local dx = math.cos( angle ) * magnitude
	return dx
end

function decompVectorY ( angle, magnitude )
--[[Returns the y component of a vector with angle 'angle' and magnitide 'magnitude'.]]
	local dy = math.sin( angle ) * magnitude
	return dy
end

--[[The following are physics functions which act on sprites.]]

accelerateAlong = function ( sprite, angle, magnitude )
--[[it occurs to me that this will rack up way too fast if called every frame.
Not sure how best to resolve that; one workaround might be
to set the sprite's acceleration to 0 at the beginning of each frame.

NB: Upon experimentation, setting sprite.acceleration to 0 at beginning
of each frame effectively cancels all acceleration, so no movement is produced.
Another solution needs to be found. See comments at bottom for a rough sketch.]]

--[[Accelerates a sprite by a vector of 'magnitude' along 'angle'.
sprite: Object to be accelerated. Must be a sprite.
angle: Given in radians.
magnitude: Self-explanatory. Given in pixels.]]
	local dx = decompVectorX ( angle, magnitude )
	local dy = decompVectorY ( angle, magnitude )

	assert( sprite:instanceOf ( Sprite ) , 'First argument of accelerateAlong must be a sprite.' )
	sprite.acceleration.x = sprite.acceleration.x + dx
	sprite.acceleration.y = sprite.acceleration.y + dy

end

set_accelAlong = function ( sprite, angle, magnitude )

--[[Accelerates a sprite by a vector of 'magnitude' along 'angle'.
sprite: Object to be accelerated. Must be a sprite.
angle: Given in radians.
magnitude: Self-explanatory. Given in pixels.]]
	local dx = decompVectorX ( angle, magnitude )
	local dy = decompVectorY ( angle, magnitude )

	assert( sprite:instanceOf ( Sprite ) , 'First argument of set_accelAlong must be a sprite.' )
	sprite.acceleration.x = dx
	sprite.acceleration.y = dy

end

impelAlong = function ( sprite, angle, magnitude )
--Designed to be called once. If called repeatedly, this is equivalent to an acceleration.
--[[Simulates an impulse on a sprite of 'magnitude' along 'angle'.
sprite: Object to be pushed. Must be a sprite.
angle: Given in radians.
magnitude: Self-explanatory. Given in pixels.]]
	local dx = decompVectorX ( angle, magnitude )
	local dy = decompVectorY ( angle, magnitude )

	assert( sprite:instanceOf ( Sprite ) , 'First argument of impelAlong must be a sprite.' )
	sprite.velocity.x = sprite.velocity.x + dx
	sprite.velocity.y = sprite.velocity.y + dy

end

--[[Here's how we might go about resolving the acceleration addition problem:
To avoid accelerating infinitely, acceleration needs to be set to zero
every frame and then added appropriately. Yet, the acceleration property
*cannot* be zero at the end or beginning of every frame, or no movement will occur.
The following seems roundabout, but bear with me.

We might, for a given sprite, set up private variables sum_dx, sum_dy
Initialize these vars to 0.

When we want to apply a force (an acceleration, not an impulse),

	add sum_dx += decompVectorX ( angle, magnitude )
	add sum_dy += decompVectorY ( andly, magnitude )
	...

Do this for each force applied, rather than setting sprite.acceleration.

At the end of each frame (after all updates have fired and, so, after
all forces applied),

	set sprite.acceleration = { x = sum_dx, y = sum_dy }
	set sum_dx = 0 , sum_dy = 0

This is equivalent to summing all the vectors acting on the sprite during
that frame.
]]
