function onKill(player, target)
	if target:isMonster() then
		return false
	end
	
	if not player:getGuild() or not target:getGuild() then
		return false
	end

	if player:getLevel() < GuildLevel.minLevelBonus or target:getLevel() < GuildLevel.minLevelBonus then
		return false
	end

	local guild1 = player:getGuild()
	local guild2 = target:getGuild()

	if guild1:getId() == guild2:getId() then
		return false
	end

	local max = math.max(5, guild2:getLevel() - guild1:getLevel() + (isInWar(player, target) and 20 or 16))
	local xp = math.random(4, max)
    guild1:addExperience(xp)
	guild2:addExperience(- math.ceil(xp / 1.25))
	
	player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Você adicionou ".. xp .." de experiência à sua guild por matar ".. target:getName() ..".")
	return true
end