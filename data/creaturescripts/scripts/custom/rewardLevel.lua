local table = {
	[50] = {type = "bank", id = {5000, 0}, msg = "Foi depositado em seu bank 5000 gold coins por alcançar o level 50!"},
	[100] = {type = "bank", id = {20000, 0}, msg = "Foi depositado em seu bank 20000 gold coins por alcançar o level 100!"},
	[200] = {type = "item", id = {9693, 1}, msg = "Você ganhou um addon doll por alcançar o level 200!"},
	[400] = {type = "addon", id = {154, 158}, msg = "Você ganhou p addon Shaman Full por alcançar o level 400!"},
}

local storage = 15000

function onAdvance(player, skill, oldLevel, newLevel)

	if skill ~= SKILL_LEVEL or newLevel <= oldLevel then
		return true
	end

	for level, _ in pairs(table) do
		if newLevel >= level and player:getStorageValue(storage) < level then
			if table[level].type == "item" then
				player:addItem(table[level].id[1], table[level].id[2])
			elseif table[level].type == "bank" then
				player:setBankBalance(player:getBankBalance() + table[level].id[1])
			elseif table[level].type == "addon" then
				player:addOutfitAddon(table[level].id[1], 3)
				player:addOutfitAddon(table[level].id[2], 3)
			else
				return false
			end

			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, table[level].msg)
			player:setStorageValue(storage, level)
		end
	end

	player:save()

	return true
end
