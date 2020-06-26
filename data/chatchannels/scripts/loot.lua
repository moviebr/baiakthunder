function onSpeak(player, type, message)
	return false
end

function onJoin(player)
	player:setStorageValue(STORAGEVALUE_LOOT, 1)
	return true
end

function onLeave(player)
	player:setStorageValue(STORAGEVALUE_LOOT, 0)
	return true
end
