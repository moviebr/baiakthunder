local mining = Action()

function mining.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local randBase = math.random(10000)
	local rand = configMining.itens[math.random(#configMining.itens)]
	local randHit = math.random(configMining.hit.danoMin,configMining.hit.danoMax)

	if configMining.level.active and player:getStorageValue(configMining.level.storageTentativas) >= configMining.level[player:getStorageValue(configMining.level.storageNivel) + 1].qntMin then
		player:setStorageValue(configMining.level.storageNivel, player:getStorageValue(configMining.level.storageNivel) + 1)
		player:sendTextMessage(22, configMining.msg.upNivel:format(configMining.level[player:getStorageValue(configMining.level.storageNivel)].name))
		player:getPosition():sendMagicEffect(50)
	end
	
	if target.actionid ~= configMining.actionIdPedras then
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendTextMessage(22, configMining.msg.naoLocal)
		return true
	end

	if item.itemid == configMining.idPick or item.itemid == configMining.idPickEspecial then
		if configMining.hit.active and configMining.hit.chance >= randBase then
			player:getPosition():sendMagicEffect(CONST_ME_STONES)
			player:getPosition():sendMagicEffect(1)
			player:addHealth(- randHit)
			player:sendTextMessage(22, configMining.msg.dano)
			return true
		end
	
		if rand.chancePickNormal >= randBase and item.itemid == configMining.idPick then
			local name = ItemType(rand.itemid)
			if configMining.level.active then
				player:setStorageValue(configMining.level.storageTentativas, (player:getStorageValue(configMining.level.storageTentativas) + 1))
			end
			if configMining.level.active and rand.level and player:getStorageValue(configMining.level.storageNivel) >= rand.nivelMin then
				player:getPosition():sendMagicEffect(32)
				player:addItem(rand.itemid, 1)
				player:sendTextMessage(22, string.format(configMining.msg.minerouWin, name:getName()))
				return true
			end
			player:getPosition():sendMagicEffect(CONST_ME_HEARTS)
			player:addItem(rand.itemid, 1)
			player:sendTextMessage(22, string.format(configMining.msg.minerouWin, name:getName()))
			return true
		elseif rand.chancePickEspecial >= randBase and item.itemid == configMining.idPickEspecial then
			local name = ItemType(rand.itemid)
			if configMining.level.active then
				player:setStorageValue(configMining.level.storageTentativas, (player:getStorageValue(configMining.level.storageTentativas) + 1))
			end
			if configMining.level.active and rand.level and player:getStorageValue(configMining.level.storageNivel) >= rand.nivelMin then
				player:getPosition():sendMagicEffect(32)
				player:addItem(rand.itemid, 1)
				player:sendTextMessage(22, string.format(configMining.msg.minerouWin, name:getName()))
				return true
			end
			player:addItem(rand.itemid, 1)
			player:sendTextMessage(22, string.format(configMining.msg.minerouWin, name:getName()))
			player:getPosition():sendMagicEffect(CONST_ME_HEARTS)
			if configMining.msg.usarEspecial then
				player:say(configMining.msg.especial, TALKTYPE_MONSTER_SAY, true)
			end
			return true
		else
			Game.sendAnimatedText(configMining.msg.fail, toPosition, math.random(255))
			toPosition:sendMagicEffect(4)
			return true
		end
	else
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendTextMessage(22, configMining.msg.naoPick)
		return false
	end
	
    return true
end

mining:id(configMining.idPick, configMining.idPickEspecial)
mining:register()