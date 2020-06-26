local premium = Action()

function premium.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local var = item:getAttribute(ITEM_ATTRIBUTE_DESCRIPTION)

	if var == nil then 
		return true 
	end

	local x = var:match("%b[]")
	print(var)
	print(x)
	if x == "[Sell Points System]" then
		local ret = var:match("%d+")
		print(ret)
		player:sendCancelMessage("Você recebeu "..ret.." Premium Points.")
		player:setPremiumPoints(player:getPremiumPoints() + ret)
		item:remove()
	end
	return true
end

premium:id(7702)
premium:register()