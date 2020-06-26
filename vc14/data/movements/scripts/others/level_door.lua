function onStepIn(creature, item, position, fromPosition)
	if not creature:isPlayer() then
		return false
	end

	if creature:getLevel() < item.actionid - 1000 then
		creature:sendTextMessage(MESSAGE_INFO_DESCR, "Apenas o digno pode passar.")
		creature:teleportTo(fromPosition, true)
		return false
	end
	return true
end
