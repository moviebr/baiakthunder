function onSay(player, words, param)
	if not table.contains(BomberTeam1, player) and not table.contains(BomberTeam2, player) then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Só é permitido soltar bombas dentro e durante a partida.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end
	
	if player:getStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_ACTIVEBOMB) < player:getStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_MAXBOMB) then
		local bombsize = player:getStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_SIZE)
		local item = Game.createItem(26142, 1, player:getPosition())
		player:setStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_ACTIVEBOMB, player:getStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_ACTIVEBOMB) + 1)
		addEvent(explosion, 2 * 1 * 1000, player:getPosition(), bombsize, player.uid)
	end
end

function explosion(position, bombsize, player)
	local player = Player(player)
	local BombItem = Tile(position):getItemById(26142)
	if BombItem then
		local centerPosition = position		
		local limit1, limit2, limit3, limit4 = 0, 0, 0, 0
		for i = 1, bombsize do	
			if Tile(Position(centerPosition.x, centerPosition.y - i, centerPosition.z)) then
				local sqm = Position(centerPosition.x, centerPosition.y - i, centerPosition.z)
				if Tile(sqm):getItemById(10755) or Tile(sqm):getItemById(10756) or Tile(sqm):getItemById(10759) then
					limit1 = 1
				end
				if Tile(sqm):getItemById(9421) and limit1 == 0 then
					checktile(sqm, player.uid)
					limit1 = 1
				end
				if limit1 == 0 then
					checktile(sqm, player.uid)
				end
			end
			if Tile(Position(centerPosition.x, centerPosition.y + i, centerPosition.z)) then
				local sqm = Position(centerPosition.x, centerPosition.y + i, centerPosition.z)
				if Tile(sqm):getItemById(10755) or Tile(sqm):getItemById(10756) or Tile(sqm):getItemById(10759) then
					limit2 = 1
				end
				if Tile(sqm):getItemById(9421) and limit2 == 0 then
					checktile(sqm, player.uid)
					limit2 = 1
				end
				if limit2 == 0 then
					checktile(sqm, player.uid)
				end
			end
			if Tile(Position(centerPosition.x - i, centerPosition.y, centerPosition.z)) then
				local sqm = Position(centerPosition.x - i, centerPosition.y, centerPosition.z)
				if Tile(sqm):getItemById(10755) or Tile(sqm):getItemById(10756) or Tile(sqm):getItemById(10759) then
					limit3 = 1
				end
				if Tile(sqm):getItemById(9421) and limit3 == 0 then
					checktile(sqm, player.uid)
					limit3 = 1
				end
				if limit3 == 0 then
					checktile(sqm, player.uid)
				end
			end
			if Tile(Position(centerPosition.x + i, centerPosition.y, centerPosition.z)) then
				local sqm = Position(centerPosition.x + i, centerPosition.y, centerPosition.z)
				if Tile(sqm):getItemById(10755) or Tile(sqm):getItemById(10756) or Tile(sqm):getItemById(10759) then
					limit4 = 1
				end
				if Tile(sqm):getItemById(9421) and limit4 == 0 then
					checktile(sqm, player.uid)
					limit4 = 1
				end
				if limit4 == 0 then
					checktile(sqm, player.uid)
				end
			end
		end
	end
	position:sendMagicEffect(CONST_ME_FIREAREA)
	checktile(Position(position), player.uid)
	BombItem:remove()
	player:setStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_ACTIVEBOMB, player:getStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_ACTIVEBOMB) - 1)
end

function checktile(position)
	local player = Player(player)
	local block = Tile(position):getItemById(9421)
	if block then
		block:remove()
		-- blocos no mapa atual: 471
		local portalFinal
		-- o portal pode ser criado quando 90% dos blocos forem destruidos, ou se o time adversario estiver morto
		if (#BlockListBomberman >= (471*0.9) and BombermanPortal == 0) or (#BomberTeam1 == 0 or #BomberTeam2 == 0) and BombermanPortal == 0 then
			if math.random(1, 10) > 7 or #BlockListBomberman == 471 then 
				BombermanPortal = 2
				portalFinal = Game.createItem(1387, 1, position)
				portalFinal:setActionId(19004)
			end
		end
		
		-- guardar blocos destruidos para reconstruir o mapa
		if not table.contains(BlockListBomberman, position) then
		table.insert(BlockListBomberman, position)
		end
		
		if BombermanPortal == 2 then
		-- quando criar o portal nao criar item
			BombermanPortal = 1
		else
			local randomizer = math.random(0, 100)
			if randomizer > 75 then -- 25% de chance de dropar
				local premio = math.random(1, 10)
				local dropaction, drop, a, b
				if premio >= 1 and premio < 6 then
				-- a = id do item, pode ser alterado, b = Action Id do item, nao deve ser alterado
					a, b = 2684, 19001
				elseif premio >= 6 and premio < 9 then
					a, b = 4852, 19002
				elseif premio >= 9 and premio <= 10 then
					a, b = 2642, 19003
				end
				drop = Game.createItem(a, 1, position)
				drop:setActionId(b)
			end
		end	
	end
	
	local creature = Tile(position):getTopCreature()
	if creature and creature:isPlayer() then
		position:sendMagicEffect(CONST_ME_TELEPORT)
		-- primeiro hit: se tiver algum powerUP, nao morre, apenas perde os power ups
		if creature:getStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_SIZE) > 1 or creature:getStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_MAXBOMB) > 1 or creature:getStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_SPEED) > 1 then
			creature:setStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_MAXBOMB, 1)
			creature:setStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_SIZE, 1)
			creature:setStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_SPEED, 1)
			doChangeSpeed(creature, getCreatureBaseSpeed(creature)-creature:getSpeed())
			creature:sendTextMessage(MESSAGE_INFO_DESCR, "Você foi atingido, e perdeu suas habilidades.")
		else
		-- segundo hit: Se nao tiver powerUps, sai da partida
			creature:setStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_SIZE, -1)
			creature:setStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_MAXBOMB, -1)
			creature:setStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_SPEED, -1)
			doChangeSpeed(creature, getCreatureBaseSpeed(creature)-creature:getSpeed())
			-- posicao que o player eh expulso
			creature:teleportTo(Position(1057, 923, 5))
			creature:getPosition():sendMagicEffect(CONST_ME_FIREAREA)
			creature:sendTextMessage(MESSAGE_INFO_DESCR, "Você foi atingido, e morreu por estar sem habilidades.")
			creature:setOutfit(BombermanOutfit[creature:getGuid()])
			if table.contains(BomberTeam1, creature) then
				for i = 1, #BomberTeam1 do
					if BomberTeam1[i] == creature then
					table.remove(BomberTeam1, i)
					end
				end
			end
			if table.contains(BomberTeam2, creature) then
				for i = 1, #BomberTeam2 do
					if BomberTeam2[i] == creature then
					table.remove(BomberTeam2, i)
					end
				end
			end	
		end
	else
		-- remover o comentario da parte abaixo se quiser permitir monstros comuns na arena
		--[[if creature then
			if table.contains(BomberTeam1, creature) then
				for i = 1, #BomberTeam1 do
					if BomberTeam1[i] == creature then
					table.remove(BomberTeam1, i)
					end
				end
			end
			if table.contains(BomberTeam2, creature) then
				for i = 1, #BomberTeam2 do
					if BomberTeam2[i] == creature then
					table.remove(BomberTeam2, i)
					end
				end
			end
			creature:teleportTo(Position(1057, 923, 5))
		end]]
	end
	
	--[[limits from 1009, 905, 5 to 1036, 929, 5]]
	-- aqui peguei o menor e maior ponto em X, e Y do mapa. O que estiver dentro desse raio, solta o efeito de explosao da bomba
	if position.x >= 1709 and position.x <= 1735 and position.y >= 903 and position.y <= 927 then 
		position:sendMagicEffect(CONST_ME_FIREAREA)
	end
end