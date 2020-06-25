function onSay(player, words, param)

	local addondoll_id = 9693
	local word = OUTFIT_LIST[string.lower(param)]

	if param == "" or not word then
		player:sendCancelMessage("Digite novamente, algo está errado!")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	if player:getItemCount(addondoll_id) < 1 then
		player:sendCancelMessage("Você não tem addon doll!")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	if (player:hasOutfit(word[1], 3) or player:hasOutfit(word[2], 3)) then
		player:sendCancelMessage("Você já tem esse addon")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	if not player:removeItem(addondoll_id, 1) then
		player:sendCancelMessage("Digite novamente, algo está errado!")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	if word[1] == 138 or word[2] == 130 then
		player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
		player:addOutfitAddon(word[1], 1)
		player:addOutfitAddon(word[2], 1)
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Seu addon 1 de mage foi adicionado!")
		return true
	end

	player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
	player:addOutfitAddon(word[1], 3)
	player:addOutfitAddon(word[2], 3)
	player:sendTextMessage(MESSAGE_INFO_DESCR, "Seu addon full foi adicionado!")

	return true
end