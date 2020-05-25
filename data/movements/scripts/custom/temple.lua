local base = templePosition
local positions = {
	[1] = Position(base.x-1, base.y-1, base.z),
	[2] = Position(base.x, base.y-1, base.z),
	[3] = Position(base.x+1, base.y-1, base.z),
	[4] = Position(base.x+1, base.y, base.z),
	[5] = Position(base.x+1, base.y+1, base.z),
	[6] = Position(base.x, base.y+1, base.z),
	[7] = Position(base.x-1, base.y+1, base.z),
	[8] = Position(base.x-1, base.y, base.z)
}
local lista = {"Movie"}

function onStepIn(creature, item, position, fromPosition)
	local rand = positions[math.random(#positions)]
	local player = creature:getPlayer()
    if not player then
        return false
    end
	
	if isInArray(lista, player:getName()) then
		return true
	end

    player:teleportTo(rand, true)

	return true
end