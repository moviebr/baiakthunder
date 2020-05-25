function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end
	-- Battlefield
	


	-- Geral
	player:sendTextMessage(MESSAGE_INFO_DESCR, "Você saiu do evento.")
	player:setStorageValue(STORAGEVALUE_EVENTS, 0)
	player:teleportTo(player:getTown():getTemplePosition())
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
end