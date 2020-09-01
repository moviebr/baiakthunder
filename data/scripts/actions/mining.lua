local mining = Action()
local configMining = {
	msg = {
		naoLocal = "Você não pode minerar aqui.",
		naoPick = "Você consegue minerar somente com pick.",
		minerouWin = "Você ganhou uma %s.",
		dano = "As pedras desabaram e você levou um hit.",
		fail = "Falha!",
		upNivel = "Você subiu de nível na mineração! Agora você é %s. Parabéns!",
		usarEspecial = true,
		especial = "[PREMIUM]",
	},
	level = {
		active = true,
		storageTentativas = 81056,
		storageNivel = 81057,
		[1] = {name = "Iniciante", qntMin = 0, qntMax = 20},
		[2] = {name = "Intermediário", qntMin = 21, qntMax = 199},
		[3] = {name = "Avançado", qntMin = 200}
	},
	itens = {
		{itemid = 2147, chancePickNormal = 100, chancePickEspecial = 15000},
		{itemid = 2146, chancePickNormal = 100, chancePickEspecial = 15000},
		{itemid = 2150, chancePickNormal = 100, chancePickEspecial = 15000},
		{itemid = 9970, chancePickNormal = 100, chancePickEspecial = 15000},
		{itemid = 2149, chancePickNormal = 100, chancePickEspecial = 15000},
		{itemid = 2145, chancePickNormal = 100, chancePickEspecial = 15000},
		{itemid = 2156, chancePickNormal = 20, chancePickEspecial = 4000},
		{itemid = 2155, chancePickNormal = 20, chancePickEspecial = 4000},
		{itemid = 2158, chancePickNormal = 20, chancePickEspecial = 4000},
		{itemid = 2153, chancePickNormal = 20, chancePickEspecial = 4000},
		{itemid = 11421, chancePickNormal = 10, chancePickEspecial = 2000, level = true, nivelMin = 3},
	},
	hit = {
		active = true,
		danoMin = 300, 
		danoMax = 500, 
		chance = 400
	},
	idPick = 2553,
	idPickEspecial = 11421,
	actionIdPedras = 34561,
}

function mining.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	print(player:getStorageValue(configMining.level.storageNivel))
	print("-----")
	print(player:getStorageValue(configMining.level.storageTentativas))
	rand = configMining.itens[math.random(#configMining.itens)]
	randHit = math.random(configMining.hit.danoMin,configMining.hit.danoMax)

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
		if configMining.hit.active and configMining.hit.chance >= math.random(0,10000) then
			player:getPosition():sendMagicEffect(CONST_ME_STONES)
			player:getPosition():sendMagicEffect(1)
			player:addHealth(- randHit)
			player:sendTextMessage(22, configMining.msg.dano)
			return true
		end
	
		if rand.chancePickNormal >= math.random(0,10000) and item.itemid == configMining.idPick then
			local name = ItemType(rand.itemid)
			if configMining.level.active then
				player:setStorageValue(configMining.level.storageTentativas, (player:getStorageValue(configMining.level.storageTentativas) + 1))
			end
			if configMining.level.active and rand.level and player:getStorageValue(configMining.level.storageNivel) >= rand.nivelMin then
				player:getPosition():sendMagicEffect(CONST_ME_HEARTS)
				player:addItem(rand.itemid, 1)
				player:sendTextMessage(22, string.format(configMining.msg.minerouWin, name:getName()))
				return true
			end
			player:getPosition():sendMagicEffect(CONST_ME_HEARTS)
			player:addItem(rand.itemid, 1)
			player:sendTextMessage(22, string.format(configMining.msg.minerouWin, name:getName()))
			return true
		else
			Game.sendAnimatedText(configMining.msg.fail, toPosition, math.random(255))
			toPosition:sendMagicEffect(4)
		end
	
		if rand.chancePickEspecial >= math.random(0,10000) and item.itemid == configMining.idPickEspecial then
			local name = ItemType(rand.itemid)
			player:addItem(rand.itemid, 1)
			if configMining.level.active then
				player:setStorageValue(configMining.level.storageTentativas, (player:getStorageValue(configMining.level.storageTentativas) + 1))
			end
			if configMining.level.active and rand.level and player:getStorageValue(configMining.level.storageNivel) >= rand.nivelMin then
				player:getPosition():sendMagicEffect(CONST_ME_HEARTS)
				player:addItem(rand.itemid, 1)
				player:sendTextMessage(22, string.format(configMining.msg.minerouWin, name:getName()))
				return true
			end
			player:sendTextMessage(22, string.format(configMining.msg.minerouWin, name:getName()))
			player:getPosition():sendMagicEffect(CONST_ME_HEARTS)
			if configMining.msg.usarEspecial then
				player:say(configMining.msg.especial, TALKTYPE_MONSTER_SAY, true)
			end
			return true
		else
			Game.sendAnimatedText(configMining.msg.fail, toPosition, math.random(255))
			toPosition:sendMagicEffect(4)
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