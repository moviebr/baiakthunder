function onPrepareDeath(player, killer)
	if player:getStorageValue(STORAGEVALUE_EVENTS) >= 1 and killer:getStorageValue(STORAGEVALUE_EVENTS) >= 1 then
		player:setStorageValue(STORAGEVALUE_EVENTS, 0)
		player:setStorageValue(BATTLEFIELD.storageTeam, 0)
		return true
	end
	return true
end