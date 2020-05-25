function onStepIn(creature, item, position, fromPosition)
	local getTeamRed = Game.getStorageValue(BATTLEFIELD.storageTeamRed)
	local getTeamBlue = Game.getStorageValue(BATTLEFIELD.storageTeamBlue)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if BATTLEFIELD.level.active and player:getLevel() < BATTLEFIELD.level.levelMin then
		player:sendCancelMessage(BATTLEFIELD.messages.prefix .."Você precisa ter level " .. BATTLEFIELD.level.levelMin .. " ou maior para entrar no evento.")
		player:teleportTo(fromPosition, true)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	if player:getItemCount(2165) >= 1 then
		player:sendCancelMessage(BATTLEFIELD.messages.prefix .."Você não pode entrar no evento com um stealth ring.")
		player:teleportTo(fromPosition, true)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local ring = player:getSlotItem(CONST_SLOT_RING)
	if ring then
		if ring:getId() == 2202 then
			player:sendCancelMessage(BATTLEFIELD.messages.prefix .."Você não pode entrar no evento usando um stealth ring.")
			player:teleportTo(fromPosition, true)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end
	end

	if BFcheckPlayers() >= BATTLEFIELD.maxPlayers then
		player:sendCancelMessage(BATTLEFIELD.messages.prefix .."O evento já atingiu o máximo de participantes.")
		player:teleportTo(fromPosition, true)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if getTeamRed > getTeamBlue then
		Game.setStorageValue(BATTLEFIELD.storageTeamBlue, (getTeamBlue + 1))
		player:setStorageValue(BATTLEFIELD.storageTeam, 1)
		player:sendCancelMessage(BATTLEFIELD.messages.prefix .."Você entrou para o time azul.")
		player:setOutfit(BATTLEFIELD.blueTeamOutfit)
	elseif getTeamRed == getTeamBlue then
		Game.setStorageValue(BATTLEFIELD.storageTeamRed, (getTeamRed + 1))
		player:setStorageValue(BATTLEFIELD.storageTeam, 2)
		player:sendCancelMessage(BATTLEFIELD.messages.prefix .."Você entrou para o time vermelho.")
		player:setOutfit(BATTLEFIELD.redTeamOutfit)
	else
		Game.setStorageValue(BATTLEFIELD.storageTeamRed, (getTeamRed + 1))
		player:setStorageValue(BATTLEFIELD.storageTeam, 2)
		player:sendCancelMessage(BATTLEFIELD.messages.prefix .."Você entrou para o time vermelho.")
		player:setOutfit(BATTLEFIELD.redTeamOutfit)
	end
	player:setStorageValue(STORAGEVALUE_EVENTS, 1)
	player:teleportTo(BATTLEFIELD.waitingRoomPosition)
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	
end