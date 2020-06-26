function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
    if not player then
        return false
    end
	
	local guild = player:getGuild()
    if not guild then
        player:teleportTo(fromPosition, true)
        player:sendCancelMessage(CASTLE.castleNome .." " ..CASTLE.mensagemPrecisaGuild)
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

	local guildId = guild:getId()
	local guildName = guild:getName()
	
	
		if guildId == Game.getStorageValue(STORAGEVALUE_CASTLE_DOMINADO) or guildId == getGuildIdFromCastle() then
			player:sendCancelMessage(CASTLE.castleNome .." " .. CASTLE.mensagemBemvindo)
			return true
		else
			player:sendCancelMessage(CASTLE.castleNome .." " .. CASTLE.mensagemGuildNaoDominante .." (".. guildName ..")")
			player:teleportTo(fromPosition, true)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end
end