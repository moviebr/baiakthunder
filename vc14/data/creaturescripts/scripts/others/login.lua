function onLogin(player)
	local loginStr = "Bem-vindo ao " .. configManager.getString(configKeys.SERVER_NAME) .. "!"
	if player:getLastLoginSaved() <= 0 then
		loginStr = loginStr .. " Por favor escolha sua roupa."
		player:sendOutfitWindow()
	else
		if loginStr ~= "" then
			player:sendTextMessage(MESSAGE_STATUS_DEFAULT, loginStr)
		end

		loginStr = string.format("Sua última visita foi em %s.", os.date("%a %b %d %X %Y", player:getLastLoginSaved()))
	end
	player:sendTextMessage(MESSAGE_STATUS_DEFAULT, loginStr)

	if player:isPremium() and player:getAccountType() < ACCOUNT_TYPE_GOD then
		player:say("[PREMIUM]", TALKTYPE_MONSTER_SAY)
		player:getPosition():sendMagicEffect(50)
	end

	-- Stamina
	nextUseStaminaTime[player.uid] = 0

	-- Eventos
	if player:getStorageValue(STORAGEVALUE_EVENTS) >= 1 then
		player:teleportTo(player:getTown():getTemplePosition())
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:setStorageValue(STORAGEVALUE_EVENTS, 0)

		-- Battlefield
		player:setStorageValue(BATTLEFIELD.storageTeam, 0)
	end

	-- Dodge/Critical System
	if player:getDodgeLevel() == -1 then
		player:setDodgeLevel(0) 
	end
	if player:getCriticalLevel() == -1 then
		player:setCriticalLevel(0) 
	end
	
	player:loadSpecialStorage()
	
	-- Promotion
	local vocation = player:getVocation()
	local promotion = vocation:getPromotion()
	if player:isPremium() then
		local value = player:getStorageValue(STORAGEVALUE_PROMOTION)
		if not promotion and value ~= 1 then
			player:setStorageValue(STORAGEVALUE_PROMOTION, 1)
		elseif value == 1 then
			player:setVocation(promotion)
		end
	elseif not promotion then
		player:setVocation(vocation:getDemotion())
	end

	-- Events
	player:registerEvent("PlayerDeath")
	player:registerEvent("AnimationUp")
	player:registerEvent("DropLoot")
	player:registerEvent("HungerGames")
	player:registerEvent("DodgeCriticalSystem")
	player:registerEvent("DodgeManaSystem")
	player:registerEvent("AutoLoot")
	player:registerEvent("Exiva")
	player:registerEvent("Events")
	player:registerEvent("Tasks")
	player:registerEvent("SuperUP")
	return true
end
