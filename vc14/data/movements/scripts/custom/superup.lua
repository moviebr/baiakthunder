function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
    if not player then
        return false
    end
    local tempo = SUPERUP.setTime * 60 * 60
    for i = 1, #SUPERUP.areas do
    	local uid = 20000 + i
    	if uid == item.actionid then
    		local valores = SUPERUP:getCave(i)
            if not valores then
                return false
            end
            if player:getStorageValue(STORAGEVALUE_SUPERUP_INDEX) == i then
                return true
            end
            local playerName = db.storeQuery(string.format("SELECT name FROM players WHERE id = %d", valores.dono))
            local nome = result.getDataString(playerName, "name")
    		if valores.dono > 0 and valores.tempo > 0 then
    			player:sendCancelMessage(string.format(SUPERUP.msg.naoDisponivel, nome, os.date("%c", valores.tempo)))
    			player:getPosition():sendMagicEffect(CONST_ME_POFF)
                player:teleportTo(fromPosition, true)
    		elseif player:getStorageValue(STORAGEVALUE_SUPERUP_INDEX) >= 1 then
    			player:sendCancelMessage(SUPERUP.msg.possuiCave)
    			player:getPosition():sendMagicEffect(CONST_ME_POFF)
                player:teleportTo(fromPosition, true)
    		else
    			if player:removeItem(SUPERUP.itemID, 1) then
    				player:sendCancelMessage(string.format(SUPERUP.msg.disponivel, SUPERUP.setTime, SUPERUP.setTime > 1 and "horas" or "hora"))
    				player:getPosition():sendMagicEffect(31)
    				player:setStorageValue(STORAGEVALUE_SUPERUP_INDEX, i)
    				player:setStorageValue(STORAGEVALUE_SUPERUP_TEMPO, (os.time() + tempo))
    				local guid = player:getGuid()
    				db.query(string.format("UPDATE exclusive_hunts SET `hunt_id` = %d, `guid_player` = %d, `time` = %s, `to_time` = %s", i, guid, os.time(), (os.time() + tempo)))
                else
    				player:sendCancelMessage(string.format(SUPERUP.msg.naoItem, ItemType(SUPERUP.itemID):getName()))
    				player:getPosition():sendMagicEffect(CONST_ME_POFF)
    				player:teleportTo(fromPosition, true)
    			end
    		end
    	end
    end
	
	return true
end