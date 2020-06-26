function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	local target = Player(param)

	if target then
		target:getPosition():sendMagicEffect(CONST_ME_POFF)
		target:teleportTo(target:getTown():getTemplePosition())
		target:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		target:sendCancelMessage("Você foi teletransportada para o templo.")
		return true
	end

	player:teleportTo(player:getTown():getTemplePosition())

	return false
end
