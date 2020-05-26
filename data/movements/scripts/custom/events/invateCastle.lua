function onStepIn(creature, item, position, fromPosition)
    local player = creature:getPlayer()
    if not player then
        return false
    end

    local guild = player:getGuild()
    if not guild then
        player:teleportTo(fromPosition, true)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "".. CASTLE.castleNome .." ".. CASTLE.mensagemPrecisaGuild .."")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    local guildId = guild:getId()
    local guildName = guild:getName()
    local tempo = CASTLE.tempoAvisar
    
    if CASTLE.levelParaDominar == true and player:getLevel() < CASTLE.level then
        player:teleportTo(fromPosition, true)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "".. CASTLE.castleNome .." ".. CASTLE.mensagemLevelMinimo .." (".. CASTLE.level .."+)")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
    end

    if player:getStorageValue(STORAGEVALUE_CASTLE_SPAM) > os.time() and guild then
        return true
    end
	
	if (guild) and (guildId == getGuildIdFromCastle()) then
		if Game.getStorageValue(STORAGEVALUE_CASTLE_DOMINADO) == nil or not Game.getStorageValue(STORAGEVALUE_CASTLE_DOMINADO) then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "".. CASTLE.castleNome .." ".. CASTLE.mensagemBemvindo .."")
			return true
		end
	end

    if guildId ~= Game.getStorageValue(STORAGEVALUE_CASTLE_DOMINADO) or guildId ~= getGuildIdFromCastle() then
        Game.broadcastMessage("".. CASTLE.castleNome .." O castelo está sendo invadido pelo player ".. player:getName() .." da guild ".. guildName ..".", MESSAGE_STATUS_WARNING)
        player:setStorageValue(STORAGEVALUE_CASTLE_SPAM, (os.time() + tempo))
    else
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "".. CASTLE.castleNome .." ".. CASTLE.mensagemBemvindo .."")
    end

    return true
end