local pos = Position(940, 1063, 8)
function onStepIn(creature, item, position, fromPosition)
	if not creature:isPlayer() then
		creature:teleportTo(fromPosition, true)
		return false
	end

	creature:teleportTo(pos)
	creature:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

	return true
end