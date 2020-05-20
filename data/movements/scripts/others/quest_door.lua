function onStepIn(creature, item, position, fromPosition)
	if not creature:isPlayer() then
		return false
	end

	if creature:getStorageValue(item.actionid) == -1 then
		creature:sendTextMessage(MESSAGE_INFO_DESCR, "A porta parece estar selada contra invasores indesejados.")
		creature:teleportTo(fromPosition, true)
		return false
	end
	return true
end
