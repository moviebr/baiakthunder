local dodge = Action()

function dodge.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getDodgeLevel() < DODGE.LEVEL_MAX then
		item:remove(1)
		player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
		player:setDodgeLevel(player:getDodgeLevel() + 1)
		player:sendCancelMessage("Você aumentou sua skill de dodge para [" .. player:getDodgeLevel() .. "/" .. DODGE.LEVEL_MAX .. "].")
	elseif player:getDodgeLevel() >= DODGE.LEVEL_MAX then
		player:sendTextMessage(MESSAGE_STATUS_WARNING, "Você alcancou o máximo de Dodge.")
		return false
    end
	return true
end

dodge:id(12411)
dodge:register()