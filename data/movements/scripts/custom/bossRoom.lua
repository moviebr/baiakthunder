function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
    if not player then
        return false
    end

    local bossVariavel = BossRoom.monstros[item.actionid]
		if not bossVariavel then
			player:teleportTo(fromPosition, true)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
    	return true
    end

		local spectators = Game.getSpectators(bossVariavel.center, false, false, 0, bossVariavel.x, 0, bossVariavel.y)

		if #spectators >= 1 then
			player:teleportTo(fromPosition, true)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, BossRoom.msg.notAvailable)
			return true
		end

		if not player:removeItem(BossRoom.itemID, bossVariavel.countItem) then
			player:teleportTo(fromPosition, true)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, BossRoom.msg.notItem:format(bossVariavel.countItem, ItemType(BossRoom.itemID):getName()))
			return true
		end

		addEvent(function()
			local monster = Game.createMonster(bossVariavel.bossName, bossVariavel.center)
			monster:setEmblem(GUILDEMBLEM_ENEMY)
			BossRoom.monstros[item.actionid].bossId = monster:getId()
		end, 3 * 1000)
		local playerGUID = player:getGuid()
		local toTime = os.time() + bossVariavel.killTime * 60
		db.query("UPDATE `boss_room` SET `guid_player` = ".. playerGUID ..", `time` = ".. os.time() ..", `to_time` = ".. toTime .." WHERE room_id = ".. item.actionid)
		player:teleportTo(bossVariavel.center)
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, BossRoom.msg.enterRoom:format(3, bossVariavel.killTime))
		local playerId = player:getId()
		addEvent(function()
			local player = Player(playerId)
			spectators = Game.getSpectators(bossVariavel.center, false, false, 0, bossVariavel.x, 0, bossVariavel.y)
			if #spectators >= 1 then
				BossRoom:removeMonster(BossRoom.monstros[item.actionid].bossId)
				if player then
					player:teleportTo(player:getTown():getTemplePosition())
					player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, BossRoom.msg.timeOver)
				end
			end
			BossRoom:setFreeRoom(item.actionid)
		end, bossVariavel.killTime * 60 * 1000)

	return true
end
