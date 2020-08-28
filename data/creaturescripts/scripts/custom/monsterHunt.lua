function onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if Game.getStorageValue(MONSTER_HUNT.storages.monster) <= 0 then
		return true
	end

	if not mostdamagekiller:isPlayer() then
		return true
	end

	if mostdamagekiller:getStorageValue(MONSTER_HUNT.storages.player) == -1 then
		mostdamagekiller:setStorageValue(MONSTER_HUNT.storages.player, 0)
	end

	if creature:isMonster() and creature:getName():lower() == (MONSTER_HUNT.list[Game.getStorageValue(MONSTER_HUNT.storages.monster)]):lower() then
		mostdamagekiller:setStorageValue(MONSTER_HUNT.storages.player, mostdamagekiller:getStorageValue(MONSTER_HUNT.storages.player) + 1)
		mostdamagekiller:sendCancelMessage(MONSTER_HUNT.messages.prefix .. MONSTER_HUNT.messages.kill:format(creature:getName()))
		MONSTER_HUNT.players[mostdamagekiller:getId()] = mostdamagekiller:getStorageValue(MONSTER_HUNT.storages.player)
	end
	return true
end