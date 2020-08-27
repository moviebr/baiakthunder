local items = Action()
local levers = {
	[2655] = {id = 9693, value = 45},
	[2656] = {id = 12411, value = 50},
	[2657] = {id = 12640, value = 100},
	[2658] = {id = 8978, value = 80},
	[2659] = {id = 12544, value = 190},
}

function items.onUse(player, item, fromPosition, target, toPosition, isHotkey)

	local choose = levers[item.actionid]

	if not choose then
		return false
	end

	local userItem = ItemType(choose.id)
	local itemWeight = userItem:getWeight()

	if not player:getFreeCapacity() < itemWeight then
		player:sendCancelMessage("Você não tem espaço suficiente.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	if not player:removeMoney(choose.value) then
		player:sendCancelMessage("Você não tem dinheiro suficiente.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	player:addItem(choose.id)
	player:sendCancelMessage("Você comprou ".. userItem:getName() ..".")
	player:getPosition():sendMagicEffect(29)

	item:transform(item.itemid == 1945 and 1946 or 1945)

	return true
end

items:aid(2655,2656,2657,2658,2659)
items:register()