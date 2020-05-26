function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
    if not player then
        return false
    end
	
	local templo = player:getTown()
	local temploPos = templo:getTemplePosition()
	local guild = player:getGuild()
	
    if not guild then
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:teleportTo(temploPos)
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "".. CASTLE.castleNome .." ".. CASTLE.mensagemPrecisaGuild .."")
        return false
    end
	
	local guildId = guild:getId()
	local guildName = guild:getName()

	if guildId == Game.getStorageValue(STORAGEVALUE_CASTLE_DOMINADO) or guildId == getGuildIdFromCastle() then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "".. CASTLE.castleNome .." ".. CASTLE.mensagemGuildDominante .."")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:teleportTo(fromPosition, true)
	else
		Game.setStorageValue(STORAGEVALUE_CASTLE_DOMINADO, guildId)
		Game.broadcastMessage("".. CASTLE.castleNome .." O castelo foi dominado pelo player ".. player:getName() .." da guild ".. guildName ..".", MESSAGE_STATUS_WARNING)
		player:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
		db.query(('UPDATE `castle` SET `name` = "%s", `guild_id` = %d'):format(guildName, guildId)) -- Por Lyu
		return true
	end
end