function onThink(creature, interval)
	local player = creature:getPlayer()
	if not player then
		return false
	end

	local storIndex = player:getStorageValue(STORAGEVALUE_SUPERUP_INDEX)
	local storTime = player:getStorageValue(STORAGEVALUE_SUPERUP_TEMPO)

	for a, b in pairs(SUPERUP.areas) do
		if storIndex == a and isInArea(player:getPosition(), b.from, b.to) then
			if storTime <= os.time() then
				player:teleportTo(player:getTown():getTemplePosition())
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
			end
		end
		if storIndex == a and storTime <= os.time() then
			db.query(string.format("UPDATE exclusive_hunts SET `guid_player` = %d, `time` = %s, `to_time` = %s WHERE `hunt_id` = %d", 0, 0, 0, storIndex))
			player:setStorageValue(STORAGEVALUE_SUPERUP_TEMPO, -1)
			player:setStorageValue(STORAGEVALUE_SUPERUP_INDEX, -1)
			player:sendCancelMessage(SUPERUP.msg.tempoAcabou)
		end
	end

	return true
end
