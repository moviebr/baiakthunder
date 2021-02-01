function onPrepareDeath(player, killer)

	if Game.getStorageValue(BATTLEFIELD.storageEventStatus) ~= nil and Game.getStorageValue(BATTLEFIELD.storageEventStatus) >= 1 then
		BATTLEFIELD:removePlayer(player:getId())
	end

	player:setStorageValue(STORAGEVALUE_EVENTS, 0)
	return true
end

function onKill(player, target)

	if not player or not target:isPlayer() then
		return true
	end

	if Game.getStorageValue(BATTLEFIELD.storageEventStatus) ~= 0 then
		BATTLEFIELD:checkStatus()
	end

	return true
end