local presents = {
	[5957] = {
		{9020, 5}, 12544, 8978, 11421, 7477, 10089, 10760, 8205
	}
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local targetItem = presents[item.itemid]
	if not targetItem then
		return true
	end

	local gift = targetItem[math.random(#targetItem)]
	local itemID = gift
	local count = 1
	if type(gift) == "table" then
		itemID = gift[1]
		count = gift[2]
	end

	player:addItem(itemID, count)
	item:remove(1)
	player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
	return true
end
