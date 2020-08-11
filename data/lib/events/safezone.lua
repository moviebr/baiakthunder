SAFEZONE = {
	teleportTimeClose = 5,
	eventTimeTotal = 30,
	positionTeleportOpen = Position(1003, 1217, 7),
	positionEnterEvent = Position(1545, 957, 7),
	storage = 12149,
	actionId = 6412,
	protectionTileId = {9562, 9563, 9564, 9565},
	levelMin = 150,
	minPlayers = 5,
	maxPlayers = 50,
	reward = {9020, 5},
	players = {},
	days = {
		["Sunday"] = {"20:00"},
		["Monday"] = {"20:00"},
		["Tuesday"] = {"20:00"},
		["Wednesday"] = {"20:00"},
		["Thursday"] = {"20:00"},
		["Friday"] = {"20:00"},
		["Saturday"] = {"20:00"},
	},
	messages = {
		prefix = "[SafeZone] ",
		messageStart = "O evento irá começar agora com %d participantes! Boa sorte!",
		messageNoStart = "O evento não foi iniciado por falta de participantes!",
		messageTime = "O evento foi finalizado por ultrapassar o limite de tempo!",
		messageOpen = "O evento foi aberto, você tem %d minutos para entrar no portal do evento que se encontra no templo!",
		messageWait = "O teleporte para o evento está aberto, você tem %d minuto(s) para entrar!",
		messageFinish = "O evento foi finalizado e o ganhador foi o %s! Parabéns!",
		messageWinner = "Você ganhou %d %s como premiação pelo primeiro lugar!",
	},
	lifeColor = {
		[1] = 94, -- red
		[2] = 77, -- orange
		[3] = 79 -- yellow
	},
	positionEvent = {firstTile = {x = 1538, y = 951, z = 7}, tilesX = 15, tilesY = 11}
}

function SAFEZONE:teleportCheck()
	local tile = Tile(SAFEZONE.positionTeleportOpen)
	if tile then
		local item = tile:getItemById(1387)
		if item then
			item:remove()

			local totalPlayers = SAFEZONE:totalPlayers()
			if totalPlayers >= SAFEZONE.minPlayers then
				Game.broadcastMessage(SAFEZONE.messages.prefix .. SAFEZONE.messages.messageStart:format(totalPlayers), MESSAGE_STATUS_WARNING)
				SAFEZONE:createProtectionTiles()
				addEvent(function()
					if totalPlayers > 0 then
						Game.broadcastMessage(SAFEZONE.messages.prefix .. SAFEZONE.messages.messageTime, MESSAGE_STATUS_WARNING)
						SAFEZONE:removePlayers()
					end
				end, SAFEZONE.eventTimeTotal * 60 * 1000)
			else
				Game.broadcastMessage(SAFEZONE.messages.prefix .. SAFEZONE.messages.messageNoStart, MESSAGE_STATUS_WARNING)
				SAFEZONE:removePlayers()
			end
		else
			Game.broadcastMessage(SAFEZONE.messages.prefix .. SAFEZONE.messages.messageOpen:format(SAFEZONE.teleportTimeClose), MESSAGE_STATUS_WARNING)
			addEvent(Game.broadcastMessage, (SAFEZONE.teleportTimeClose - 3) * 60 * 1000, SAFEZONE.messages.prefix .. (SAFEZONE.messages.messageWait):format(SAFEZONE.teleportTimeClose - 2))
			addEvent(Game.broadcastMessage, (SAFEZONE.teleportTimeClose - 1) * 60 * 1000, SAFEZONE.messages.prefix .. (SAFEZONE.messages.messageWait):format(SAFEZONE.teleportTimeClose - 4))
			
			local teleport = Game.createItem(1387, 1, SAFEZONE.positionTeleportOpen)
			if teleport then
				teleport:setActionId(SAFEZONE.actionId)
			end
			addEvent(function()
				SAFEZONE:teleportCheck()
			end, SAFEZONE.teleportTimeClose * 60000)
		end
	end
end

function SAFEZONE:removePlayers()
	for a in pairs(SAFEZONE.players) do
		local player = Player(a)
		player:setStorageValue(SAFEZONE.storage, 0)
		player:setStorageValue(STORAGEVALUE_EVENTS, 0)
		player:teleportTo(player:getTown():getTemplePosition())
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		SAFEZONE.players[player:getId()] = nil
	end
end

function SAFEZONE:insertPlayer(playerId)
	SAFEZONE.players[playerId] = {}
end

function SAFEZONE:removePlayer(playerId)
	SAFEZONE.players[playerId] = nil
end

function SAFEZONE:totalPlayers()
	local x = 0
	for a in pairs(SAFEZONE.players) do
		x = x + 1
	end
	return x
end

function SAFEZONE:totalProtectionTile()
	local totalPlayers = SAFEZONE:totalPlayers()
	if totalPlayers >= 10 then
		return totalPlayers - 3
	else
		return totalPlayers - 1
	end
end

function SAFEZONE:createProtectionTiles()
	local totalPlayers = SAFEZONE:totalPlayers()
	if SAFEZONE:totalPlayers() == 1 then
		for a in pairs(SAFEZONE.players) do
			local player = Player(a)
			if player:getStorageValue(SAFEZONE.storage) > 0 then
				player:setStorageValue(SAFEZONE.storage, 0)
				SAFEZONE.players[a] = nil
				player:setStorageValue(STORAGEVALUE_EVENTS, 0)
				player:teleportTo(player:getTown():getTemplePosition())
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

				local itemType = ItemType(SAFEZONE.reward[1])
				if itemType:getId() ~= 0 then
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, SAFEZONE.messages.prefix .. SAFEZONE.messages.messageWinner:format(SAFEZONE.reward[2],itemType:getName()))
					player:addItem(itemType:getId(), SAFEZONE.reward[2])
				end
				Game.broadcastMessage(SAFEZONE.messages.prefix .. SAFEZONE.messages.messageFinish:format(player:getName()), MESSAGE_STATUS_WARNING)
			end
		end

	elseif totalPlayers >= SAFEZONE.minPlayers then
		local createTiles, totalTiles = 0, SAFEZONE:totalProtectionTile()
		local tileX = SAFEZONE.positionEvent.firstTile.x
		local tileY = SAFEZONE.positionEvent.firstTile.y
		local tileZ = SAFEZONE.positionEvent.firstTile.z
		local tilesX = SAFEZONE.positionEvent.tilesX
		local tilesY = SAFEZONE.positionEvent.tilesY
		local protectionTileId = SAFEZONE.protectionTileId
		while createTiles < totalTiles do
			local randomX = math.random(tileX, tileX + tilesX)
			local randomY = math.random(tileY, tileY + tilesY)
			local newPosition = Position({x = randomX, y = randomY, z = tileZ})
			local tile = Tile(newPosition)
			if tile then
				local item1 = tile:getItemById(protectionTileId[1])
				local item2 = tile:getItemById(protectionTileId[2])
				local item3 = tile:getItemById(protectionTileId[3])
				local item4 = tile:getItemById(protectionTileId[4])
				if not item1 and not item2 and not item3 and not item4 then
					local randomTile = math.random(protectionTileId[1], protectionTileId[4])
					local tileProtection = Game.createItem(randomTile, 1, newPosition)
					if tileProtection then
						tileProtection:getPosition():sendMagicEffect(CONST_ME_ENERGYHIT)
						addEvent(function()
							SAFEZONE:deleteProtectionTiles(newPosition, randomTile)
						end, 5000)
						createTiles = createTiles + 1
					end
				end
			end
		end
		addEvent(function()
			SAFEZONE:effectArea(SAFEZONE.positionEvent.firstTile, SAFEZONE.positionEvent.tilesX, SAFEZONE.positionEvent.tilesY)
		end, 5000)
		addEvent(function()
			SAFEZONE:checkPlayersinProtectionTiles()
		end, 4000)
		addEvent(function()
			SAFEZONE:createProtectionTiles()
		end, 6000)
	end
end

function SAFEZONE:deleteProtectionTiles(position, tileId)
	local tile = Tile(position)
	if tile then
		local item = tile:getItemById(tileId)
		if item then
			item:getPosition():sendMagicEffect(CONST_ME_POFF)
			item:remove()
		end
	end
end

function SAFEZONE:checkPlayersinProtectionTiles()
	local protectionTileId = SAFEZONE.protectionTileId
	for a in pairs(SAFEZONE.players) do
		local player = Player(a)
		if player:getStorageValue(SAFEZONE.storage) > 0 then
			local tile = Tile(player:getPosition())
			if tile then
				local item1 = tile:getItemById(protectionTileId[1])
				local item2 = tile:getItemById(protectionTileId[2])
				local item3 = tile:getItemById(protectionTileId[3])
				local item4 = tile:getItemById(protectionTileId[4])
				if not item1 and not item2 and not item3 and not item4 then
					if player:getStorageValue(SAFEZONE.storage) > 1 then

						player:setStorageValue(SAFEZONE.storage, player:getStorageValue(SAFEZONE.storage) - 1)
						local lifes = player:getStorageValue(SAFEZONE.storage)
						player:setStorageValue(SAFEZONE.storage, 0)
						player:setStorageValue(STORAGEVALUE_EVENTS, 0)
						player:getPosition():sendMagicEffect(CONST_ME_FIREAREA)
						SAFEZONE.players[player:getId()] = nil

						local outfit = player:getSex() == 0 and 136 or 128
						if lifes == 1 then
							local lifeColor = SAFEZONE.lifeColor[1]
							player:setOutfit({lookType = outfit, lookHead = lifeColor, lookBody = lifeColor, lookLegs = lifeColor, lookFeet = lifeColor})
						elseif lifes == 2 then
							local lifeColor = SAFEZONE.lifeColor[2]
							player:setOutfit({lookType = outfit, lookHead = lifeColor, lookBody = lifeColor, lookLegs = lifeColor, lookFeet = lifeColor})
						end
						
						player:setStorageValue(SAFEZONE.storage, lifes)
					else
						player:setStorageValue(SAFEZONE.storage, 0)
						player:setStorageValue(STORAGEVALUE_EVENTS, 0)
						player:getPosition():sendMagicEffect(CONST_ME_FIREAREA)
						player:teleportTo(player:getTown():getTemplePosition())
						player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
					end
				end
			end
		end
	end
end

function SAFEZONE:effectArea(firstTile, tilesX, tilesY)
	local fromPosition = firstTile
	local toPositionX = fromPosition.x + tilesX
	local toPositionY = fromPosition.y + tilesY
	for x = fromPosition.x, toPositionX do
		for y = fromPosition.y, toPositionY do
			local position = Position({x = x, y = y, z = fromPosition.z})
			if position then
				position:sendMagicEffect(CONST_ME_SMALLPLANTS)
			end
		end
	end
end