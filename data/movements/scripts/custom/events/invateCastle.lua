function onStepIn(creature, item, position, fromPosition)
    local player = creature:getPlayer()
    if not player then
        return false
    end

    local guild = player:getGuild()
    if not guild then
        player:teleportTo(fromPosition, true)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "".. CASTLE24H.castleNome .." ".. CASTLE24H.mensagemPrecisaGuild .."")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    local guildId = guild:getId()
    local guildName = guild:getName()
    local tempo = CASTLE24H.tempoAvisar

    if CASTLE24H.levelParaDominar == true and player:getLevel() < CASTLE24H.level then
        player:teleportTo(fromPosition, true)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "".. CASTLE24H.castleNome .." ".. CASTLE24H.mensagemLevelMinimo .." (".. CASTLE24H.level .."+)")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
    end

    if player:getStorageValue(STORAGEVALUE_CASTLE_SPAM) > os.time() and guild then
        return true
    end

	if (guild) and (guildId == CASTLE24H:getGuildIdFromCastle()) then
		if Game.getStorageValue(STORAGEVALUE_CASTLE_DOMINADO) == nil or not Game.getStorageValue(STORAGEVALUE_CASTLE_DOMINADO) then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "".. CASTLE24H.castleNome .." ".. CASTLE24H.mensagemBemvindo .."")
			return true
		end
	end

    if guildId ~= Game.getStorageValue(STORAGEVALUE_CASTLE_DOMINADO) or guildId ~= CASTLE24H:getGuildIdFromCastle() then
        Game.broadcastMessage("".. CASTLE24H.castleNome .." O castelo está sendo invadido pelo player ".. player:getName() .." da guild ".. guildName ..".", MESSAGE_STATUS_WARNING)
        player:setStorageValue(STORAGEVALUE_CASTLE_SPAM, (os.time() + tempo))
    else
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "".. CASTLE24H.castleNome .." ".. CASTLE24H.mensagemBemvindo .."")
    end

    return true
end
