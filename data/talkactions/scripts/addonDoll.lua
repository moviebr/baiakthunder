local outfits =
{
	--[outfit] = {id_female, id_male}
	["citizen"] = {136, 128},
	["hunter"] = {137, 129},
	--["mage"] = {138, 130},
	["knight"] = {139, 131},
	["noblewoman"] = {140, 132},
	["summoner"] = {141, 133},
	["warrior"] = {142, 134},
	["barbarian"] = {147, 143},
	["druid"] = {148, 144},
	["wizard"] = {149, 145},
	["oriental"] = {150, 146},
	["pirate"] = {155, 151},
	["assassin"] = {156, 152},
	["beggar"] = {157, 153},
	["shaman"] = {158, 154},
	["norsewoman"] = {252, 251},
	["nightmare"] = {269, 268},
	["jester"] = {270, 273},
	["brotherhood"] = {279, 278},
	["demonhunter"] = {288, 289},
	["yalaharian"] = {324, 325},
	["warmaster"] = {336, 335},
	["wayfarer"] = {366, 367}
}

function onSay(player, words, param)

	local addondoll_id = 9693

	if player:getItemCount(addondoll_id) > 0 then
		local word = outfits[string.lower(param)]
		if param ~= "" and word then
			if (not player:hasOutfit(word[1], 3) or not player:hasOutfit(word[2], 3)) and player:removeItem(addondoll_id, 1) then
				player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
				player:addOutfitAddon(word[1], 3)
				player:addOutfitAddon(word[2], 3)
				player:sendTextMessage(MESSAGE_INFO_DESCR, "Seu addon full foi adicionado!")
			else
				player:sendCancelMessage("Você já tem esse addon")
			end
		else
			player:sendCancelMessage("Digite novamente, algo está errado!")
		end
	else
		player:sendCancelMessage("Você não tem addon doll!")
	end

	return true
end