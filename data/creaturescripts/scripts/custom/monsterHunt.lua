function onKill(player, target)

	if Game.getStorageValue(MONSTER_HUNT.storages.monster) == nil then
		return true
	end

	if not player or not target then
		return true
	end

	if player:getStorageValue(MONSTER_HUNT.storages.player) == -1 then
		player:setStorageValue(MONSTER_HUNT.storages.player, 0)
	end

	if target:isMonster() and target:getName():lower() == (MONSTER_HUNT.list[Game.getStorageValue(MONSTER_HUNT.storages.monster)]):lower() then
		player:setStorageValue(MONSTER_HUNT.storages.player, player:getStorageValue(MONSTER_HUNT.storages.player) + 1)
		player:sendTextMessage(MESSAGE_STATUS_BLUE_LIGHT, MONSTER_HUNT.messages.prefix .. MONSTER_HUNT.messages.kill:format(player:getStorageValue(MONSTER_HUNT.storages.player), target:getName()))
		table.insert(MONSTER_HUNT.players, {player:getId(), player:getStorageValue(MONSTER_HUNT.storages.player)})
	end

	return true
end