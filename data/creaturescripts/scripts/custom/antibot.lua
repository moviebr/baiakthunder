function onLogin(player)
	if not configManager.getBoolean(configKeys.ANTI_BOT) then
		return true
	end

	if player:getAccountType() >= ACCOUNT_TYPE_GAMEMASTER then
		return true
	end

	player:registerEvent("AntiBot")
	checkAnti(player:getId())
	
	return true
end

function checkAnti(playerId)
	local player = Player(playerId)
	if not player then
		return false
	end

	min, max = ANTIBOT.verification[1], ANTIBOT.verification[2]
	random = math.random(min, max)

	addEvent(function()
		ANTIBOT:time(player:getId())
		checkAnti(player:getId())
	end, random * 60 * 1000)
end