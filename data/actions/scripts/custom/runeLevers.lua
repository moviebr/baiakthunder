local runes = {
	[1523] = {id = 2293, charges = 1, value = 45}, -- magic wall rune
	[1524] = {id = 2278, charges = 1, value = 50}, -- paralyze rune
	[1525] = {id = 2305, charges = 1, value = 100}, -- fire bomb rune
	[1526] = {id = 2273, charges = 1, value = 80}, -- uh rune
	[1527] = {id = 2274, charges = 1, value = 190}, -- avalanche
	[1528] = {id = 2268, charges = 1, value = 120} -- sd
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local rune = runes[item.actionid]
	if not rune then
		return false
	end

	local runeId = ItemType(rune.id)
	local itemWeight = runeId:getWeight() * rune.charges
	if player:getFreeCapacity() >= itemWeight then
		if not player:removeMoney(rune.value) then
			player:sendCancelMessage("Você não tem ".. rune.value .." gold coins para comprar ".. rune.charges .." ".. runeId:getName() ..".")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
		elseif not player:addItem(rune.id, rune.charges) then
			print("[ERROR] ACTION: runes_lever, FUNCTION: addItem, PLAYER: "..player:getName())
		else
			player:sendCancelMessage("Você comprou ".. rune.charges .."x ".. runeId:getName() ..".")
			player:getPosition():sendMagicEffect(29)
		end
		
	else
		player:sendCancelMessage("Você não tem a cap necessária para comprar.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
	end

	item:transform(item.itemid == 1945 and 1946 or 1945)
	return true
end