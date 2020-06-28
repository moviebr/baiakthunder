function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
    if not player then
        return false
    end
		
    local tempo = SUPERUP.setTime * 60 * 60

		local superUpVariavel = SUPERUP.areas[item.actionid]
		if not superUpVariavel then
			player:teleportTo(fromPosition, true)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
		end

		if player:getStorageValue(STORAGEVALUE_SUPERUP_INDEX) == item.actionid then
			return true
		end

		local value = SUPERUP:getCave(item.actionid)
		if not value then
			return false
		end

		local playerName = db.storeQuery(string.format("SELECT name FROM players WHERE id = %d", value.dono))
		local nome = result.getDataString(playerName, "name")

		if value.dono > 0 and value.tempo > 0 then
			player:sendCancelMessage(string.format(SUPERUP.msg.naoDisponivel, nome, os.date("%c", value.tempo)))
			player:teleportTo(fromPosition, true)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
		elseif player:getStorageValue(STORAGEVALUE_SUPERUP_INDEX) >= 1 then
			player:sendCancelMessage(SUPERUP.msg.possuiCave)
			player:teleportTo(fromPosition, true)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
		else
			if player:removeItem(SUPERUP.itemID, 1) then
				player:sendCancelMessage(string.format(SUPERUP.msg.disponivel, SUPERUP.setTime, SUPERUP.setTime > 1 and "horas" or "hora"))
				player:getPosition():sendMagicEffect(31)
				player:setStorageValue(STORAGEVALUE_SUPERUP_TEMPO, (os.time() + tempo))
				player:setStorageValue(STORAGEVALUE_SUPERUP_INDEX, item.actionid)
				local guid = player:getGuid()
				db.query(string.format("UPDATE exclusive_hunts SET `hunt_id` = %d, `guid_player` = %d, `time` = %s, `to_time` = %s", item.actionid, guid, os.time(), (os.time() + tempo)))
			else
				player:sendCancelMessage(string.format(SUPERUP.msg.naoItem, ItemType(SUPERUP.itemID):getName()))
				player:teleportTo(fromPosition, true)
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
			end
		end
		return true
end
