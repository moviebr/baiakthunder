local premium = Action()

function premium.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local var = item:getCustomAttribute("premiumPoints")

	if var == nil then 
		return true 
	end
	print(var)
	player:sendCancelMessage("Você recebeu ".. var .." Premium Points.")
	player:addPremiumPoints(var)
	item:remove()

	return true
end

premium:id(7702)
premium:register()