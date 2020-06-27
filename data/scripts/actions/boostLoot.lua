local loot = Action()

function loot.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local xpPot = expPotion[item:getId()]
	if not xpPot then
		return false
	end

	if player:getStorageValue(STORAGEVALUE_POTIONXP_ID) >= 1 or player:getStorageValue(STORAGEVALUE_POTIONXP_TEMPO) > os.time() then
		player:sendCancelMessage("Você já possui algum bônus de experiência.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	if not item:remove() then
		player:sendCancelMessage("Você não possui nenhum tipo de poção de loot bônus.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end


	player:sendCancelMessage("Você ativou um bônus de loot de +".. xpPot.exp .."% por ".. xpPot.tempo .." hora".. (xpPot.tempo > 1 and "s" or "") ..".")
	player:getPosition():sendMagicEffect(31)
	player:setStorageValue(STORAGEVALUE_POTIONXP_ID, item:getId())
	player:setStorageValue(STORAGEVALUE_POTIONXP_TEMPO, os.time() + xpPot.tempo * 60)
	local idPlayer = player:getId()
	addEvent(function()
		local player = Player(idPlayer)
		if player then
			player:setStorageValue(STORAGEVALUE_POTIONXP_ID, -1)
			player:setStorageValue(STORAGEVALUE_POTIONXP_TEMPO, -1)
			player:sendCancelMessage("O seu tempo de loot bônus pela poção acabou!")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
		end
	end, xpPot.tempo * 60 * 1000)
	return true
end

loot:id(10089, 10760, 11100)
loot:register()