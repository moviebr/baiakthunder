local presents = {
	[5957] = { -- lottery ticket normal
		8978, 12544
	}
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local count = 1
	local targetItem = presents[item.itemid]
	if not targetItem then
		return true
	end

	local gift = targetItem[math.random(#targetItem)]
	if type(gift) == "table" then
		gift = gift[1]
		count = gift[2]
	end

	player:addItem(gift, count)
	item:remove(1)
	player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
	return true
end
