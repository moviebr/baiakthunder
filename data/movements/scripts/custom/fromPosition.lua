function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()

    if not player then
        return false
    end

    player:teleportTo(fromPosition, true)

	return true
end