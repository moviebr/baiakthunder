local config = {
	centerPos = Position(1178, 1027, 7),
	enterPos = Position(1177, 1031, 7),
	exitPos = ,
	storageGlobal = 95741,
	storageDone = 63578,
	qntMaxDay = 5,
}

function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player or creature:isMonster() then
		creature:teleportTo(fromPosition, true)
		return true
	end

	if item.actionid == 26741 then
		if Game.getStorageValue(config.storageGlobal) == nil or Game.getStorageValue(config.storageGlobal) < 0 then
			Game.setStorageValue(config.storageGlobal, 0)
		end

		if Game.getStorageValue(config.storageGlobal) >= config.qntMaxDay then
			player:sendCancelMesage("Essa quest só pode ser feita ".. config.qntMaxDay .." vezes por dia.")
			player:teleportTo(fromPosition, true)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
		end

		if player:getItemCount(8293) == 0 then
			player:sendCancelMesage("Você precisa de um ".. ItemType(8293):getName() .." para entrar.")
			player:teleportTo(fromPosition, true)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
		end

		if player:getStorageValue(config.storageDone) >= 1 then
			player:sendCancelMesage("Você já completou essa quest.")
			player:teleportTo(fromPosition, true)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
		end

		local spec = Game.getSpectators(centerPos, false, false, 0, 10, 0, 9)
		if #spec > 0 then
			player:sendCancelMesage("Já tem um jogador dentro da quest.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
		end

		Game.setStorageValue(config.storageGlobal, Game.getStorageValue(config.storageGlobal) + 1)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:teleportTo(config.enterPos)
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

	elseif item.actionid == 26742 then
		player:teleportTo(config.exitPos)
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	end

	return true
end