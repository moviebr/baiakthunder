local mining = Action()
local configMining = {
	msg = {
		naoLocal = "Você não pode minerar aqui.",
		naoPick = "Você consegue minerar somente com pick.",
		minerouWin = "Você ganhou uma %s.",
		dano = "As pedras desabaram e você levou um hit.",
		usarEspecial = true,
		especial = "[PREMIUM]",
	},
	level = {
		active = false,
		storage = 81056,
		[1] = {qntMin = 50, qntMax = 99},
		[2] = {qntMin = 100, qntMax = 199},
		[3] = {qntMin = 200}
	},
	itens = {
		{itemid = 2147, chancePickNormal = 8, chancePickEspecial = 20},
		{itemid = 2146, chancePickNormal = 8, chancePickEspecial = 20},
		{itemid = 2150, chancePickNormal = 8, chancePickEspecial = 20},
		{itemid = 9970, chancePickNormal = 8, chancePickEspecial = 20},
		{itemid = 2149, chancePickNormal = 8, chancePickEspecial = 20},
		{itemid = 2145, chancePickNormal = 8, chancePickEspecial = 20},
		{itemid = 2156, chancePickNormal = 2, chancePickEspecial = 5},
		{itemid = 2155, chancePickNormal = 2, chancePickEspecial = 5},
		{itemid = 2158, chancePickNormal = 2, chancePickEspecial = 5},
		{itemid = 2153, chancePickNormal = 2, chancePickEspecial = 5},
	},
	hit = {danoMin = 300, danoMax = 500, chance = 4},
	idPick = 2553,
	idPickEspecial = 11421,
	actionIdPedras = 34561,
}

function mining.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	rand = configMining.itens[math.random(#configMining.itens)]
	randHit = math.random(configMining.hit.danoMin,configMining.hit.danoMax)
	
	if target.actionid ~= configMining.actionIdPedras then
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendTextMessage(22, configMining.msg.naoLocal)
		return false
	end

	if item.itemid == configMining.idPick or item.itemid == configMining.idPickEspecial then
		if configMining.hit.chance >= math.random(1,100) then
			player:getPosition():sendMagicEffect(CONST_ME_STONES)
			player:getPosition():sendMagicEffect(1)
			player:addHealth(- randHit)
			player:sendTextMessage(22, configMining.msg.dano)
			return false
		end
	
		if rand.chancePickNormal >= math.random(1,100) and item.itemid == configMining.idPick then
			local name = ItemType(rand.itemid)
			if configMining.level.active then
				player:setStorageValue(configMining.level.storage, (player:getStorageValue(configMining.level.storage) + 1))
			end
			player:getPosition():sendMagicEffect(CONST_ME_HEARTS)
			player:addItem(rand.itemid, 1)
			player:sendTextMessage(22, string.format(configMining.msg.minerouWin, name:getName()))
			return true
		end
	
		if rand.chancePickEspecial >= math.random(1,100) and item.itemid == configMining.idPickEspecial then
			local name = ItemType(rand.itemid)
			player:addItem(rand.itemid, 1)
			if configMining.level.active then
				player:setStorageValue(configMining.level.storage, (player:getStorageValue(configMining.level.storage) + 1))
			end
			player:sendTextMessage(22, string.format(configMining.msg.minerouWin, name:getName()))
			player:getPosition():sendMagicEffect(CONST_ME_HEARTS)
			if configMining.msg.usarEspecial then
				player:say(configMining.msg.especial, TALKTYPE_MONSTER_SAY, true)
			end
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