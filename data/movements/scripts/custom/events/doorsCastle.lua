function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
    if not player then
        return false
    end

	local guild = player:getGuild()
    if not guild then
        player:teleportTo(fromPosition, true)
        player:sendCancelMessage(CASTLE24H.castleNome .." " ..CASTLE24H.mensagemPrecisaGuild)
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return true
    end

	local guildId = guild:getId()
	local guildName = guild:getName()


		if guildId == Game.getStorageValue(STORAGEVALUE_CASTLE_DOMINADO) or guildId == CASTLE24H:getGuildIdFromCastle() then
			player:sendCancelMessage(CASTLE24H.castleNome .." " .. CASTLE24H.mensagemBemvindo)
			return true
		else
			player:sendCancelMessage(CASTLE24H.castleNome .." " .. CASTLE24H.mensagemGuildNaoDominante .." (".. guildName ..")")
			player:teleportTo(fromPosition, true)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
		end
end
