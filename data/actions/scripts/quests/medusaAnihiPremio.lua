function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	
	if player:getStorageValue(88914) >= 0 then
		player:sendCancelMessage("Você já pegou seu prêmio.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return true
	end

	if item.actionid == 34589 then
		player:setStorageValue(88914, 1)
		player:addItem(2407)
		player:getPosition():sendMagicEffect(30)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você ganhou 1x ".. ItemType(2407):getName().. ".")
	elseif item.actionid == 34590 then
		player:setStorageValue(88914, 1)
		player:addItem(2466)
		player:getPosition():sendMagicEffect(30)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você ganhou 1x ".. ItemType(2466):getName().. ".")
	elseif item.actionid == 34591 then
		player:setStorageValue(88914, 1)
		player:addItem(7456)
		player:getPosition():sendMagicEffect(30)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você ganhou 1x ".. ItemType(7456):getName().. ".")
	elseif item.actionid == 34592 then
		player:setStorageValue(88914, 1)
		player:addItem(8855)
		player:getPosition():sendMagicEffect(30)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você ganhou 1x ".. ItemType(8855):getName().. ".")
	end
	
	return true
end
