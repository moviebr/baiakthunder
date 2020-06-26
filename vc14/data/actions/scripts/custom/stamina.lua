local stamina_full = 42

function onUse(player, item, fromPosition, target, toPosition, isHotkey)

	if player:getStamina() >= (stamina_full * 60) then
		player:sendCancelMessage("Sua stamina já está cheia.")
	else
		player:setStamina(stamina_full * 60)
		player:sendCancelMessage("Sua stamina foi recarregada.")
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
		item:remove(1)
	end

	return true
end