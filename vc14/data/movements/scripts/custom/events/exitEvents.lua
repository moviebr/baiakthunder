function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end
	-- Battlefield
	local getTeamRed = Game.getStorageValue(BATTLEFIELD.storageTeamRed)
	local getTeamBlue = Game.getStorageValue(BATTLEFIELD.storageTeamBlue)
	if player:getStorageValue(BATTLEFIELD.storageTeam) == 1 then
		Game.setStorageValue(BATTLEFIELD.storageTeamBlue, (getTeamBlue - 1))
	elseif player:getStorageValue(BATTLEFIELD.storageTeam) == 2 then
		Game.setStorageValue(BATTLEFIELD.storageTeamRed, (getTeamRed - 1))
	end
	player:setStorageValue(BATTLEFIELD.storageTeam, 0)
	-- SafeZone
	player:setStorageValue(SAFEZONE.storage, 0)
	-- SnowBall
	for pos, players in ipairs(CACHE_GAMEPLAYERS) do
		if player:getId() == players then
			table.remove(CACHE_GAMEPLAYERS, pos)
			return true
		end
	end

	-- Geral
	player:sendTextMessage(MESSAGE_INFO_DESCR, "Você saiu do evento.")
	player:setStorageValue(STORAGEVALUE_EVENTS, 0)
	player:teleportTo(player:getTown():getTemplePosition())
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
end