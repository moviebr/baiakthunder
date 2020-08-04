function onPrepareDeath(player, killer)

	if Game.getStorageValue(BATTLEFIELD.storageEventStatus) >= 1 then
		BATTLEFIELD:removePlayer(player:getId())
	end

	player:setStorageValue(STORAGEVALUE_EVENTS, 0)
	return true
end