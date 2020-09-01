function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return
	end
		
	if item:getActionId() == 19001 then
		if player:getStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_SIZE) == 10 then
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Sua bomba atinge o máximo (+10) de sqms.")
			return true
		end
		player:setStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_SIZE, player:getStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_SIZE) + 1)
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Agora sua bomba atinge até "..player:getStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_SIZE).." sqm.")
		item:remove()
	elseif item:getActionId() == 19002 then
		if player:getStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_MAXBOMB) == 10 then
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Você pode soltar o número máximo (+10) de bombas.")
			return true
		end
		player:setStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_MAXBOMB, player:getStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_MAXBOMB) + 1)
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Agora você pode soltar até "..player:getStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_MAXBOMB).." bombas.")
		item:remove()	
	elseif item:getActionId() == 19003 then
		if player:getStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_SPEED) == 10 then
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Você está com a velocidade (+10) maxima.")
			return true
		end
	
		local speed = player:getStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_SPEED)
		if speed >= 0 and speed < 11 then
			player:setStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_SPEED, player:getStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_SPEED) + 1)
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Agora sua velocidade está +("..player:getStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_SPEED)..") points.")
			doChangeSpeed(creature, getCreatureBaseSpeed(creature))
		end
		item:remove()	
	elseif item:getActionId() == 19004 then
		exitPosition = Position(1721, 942, 7)
		local team1, team2 = #BomberTeam1, #BomberTeam2
		if team1 == 0 or team2 == 0 then
			stopEvent(bombermanEnd)
			if team1 > team2 then
				for i = 1, #BomberTeam1 do
					if isPlayer(BomberTeam1[i]) then
					resetplayerbomberman(BomberTeam1[i])
					BomberTeam1[i]:sendTextMessage(MESSAGE_INFO_DESCR, "Seu time venceu. Parabéns!")
					--BomberTeam1[i]:addItem(2160) TIME A: Exemplo de recompensa que cada ganhador ganharia
					BomberTeam1[i]:setOutfit(BombermanOutfit[BomberTeam1[i]:getGuid()])
					end
					BomberTeam1[i]:teleportTo(Position(exitPosition))
				end
			else
				for i = 1, #BomberTeam2 do
					if isPlayer(BomberTeam2[i]) then
					resetplayerbomberman(BomberTeam2[i])
					BomberTeam2[i]:setOutfit(BombermanOutfit[BomberTeam2[i]:getGuid()])
					BomberTeam2[i]:sendTextMessage(MESSAGE_INFO_DESCR, "Seu time venceu. Parabéns!")
					--BomberTeam2[i]:addItem(2160) TIME B: Exemplo de recompensa que cada ganhador ganharia
					end
					BomberTeam2[i]:teleportTo(Position(exitPosition))
				end
			end
			BomberTeam1, BomberTeam2 = {}, {} 
			for i = 1, #BlockListBomberman do
				local powerItens = {2684, 4852, 2642}
				for pointer = 1, 3 do
				if Tile(BlockListBomberman[i]):getItemById(powerItens[pointer]) then
					remover = Tile(BlockListBomberman[i]):getItemById(powerItens[pointer])
					remover:remove()
				end
				end
				if not Tile(BlockListBomberman[i]):getItemById(9421) then
				Game.createItem(9421, 1, BlockListBomberman[i])
				end 
			end
		BlockListBomberman = {}
		BombermanPortal = 0
		item:remove()
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Restam integrantes do time adversário.")
		end
	end
	return true
end

function resetplayerbomberman(player)
	local player = Player(player)
		player:setStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_ACTIVEBOMB, -1)
		player:setStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_MAXBOMB, -1)
		player:setStorageValue(STORAGEVALUE_MINIGAME_BOMBERMAN_SPEED, -1)
		doChangeSpeed(player, getCreatureBaseSpeed(player)-player:getSpeed())
end