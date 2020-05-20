function onSay(player, words, param)
	local currentgame = player:getStorageValue(currentgameid)
	if currentgame > 0 then
		return player:addHealth(-player:getMaxHealth())
	else
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You can only do that in an event game.")
		return player:getPosition():sendMagicEffect(CONST_ME_POFF)
	end
end