function onStepIn(creature, item, position, fromPosition)
	base = creature:getPosition()
	local positions = {
		[1] = Position(base.x+1, base.y, base.z),
		[2] = Position(base.x+1, base.y+1, base.z),
		[3] = Position(base.x, base.y+1, base.z),
		[4] = Position(base.x-1, base.y-1, base.z),
		[5] = Position(base.x, base.y-1, base.z),
		[6] = Position(base.x-1, base.y+1, base.z),
		[7] = Position(base.x, base.y+1, base.z),
	}
	local rand = math.random(1,#positions)
	local player = creature:getPlayer()
    if not player then
        return false
    end
	
    player:teleportTo(rand, true)

	return true
end