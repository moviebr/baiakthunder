function onLogin(player)
    freeBless = {
        level = 100,
        blesses = {1, 2, 3, 4, 5}
    }
	
	if player:getLevel() <= freeBless.level then
		for i = 1, #freeBless.blesses do
			if player:hasBlessing(i) then
				return true
			end
		end
		
		player:say("[FREE BLESS]", TALKTYPE_MONSTER_SAY)
		player:getPosition():sendMagicEffect(50)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você ganhou todas as blesses por estar abaixo do level ".. freeBless.level ..".")
		for i = 1, #freeBless.blesses do
			player:addBlessing(freeBless.blesses[i])
		end
	end
	return true
end