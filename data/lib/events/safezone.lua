SAFEZONE = {
	teleportTimeClose = 5,
	eventTimeTotal = 30,
	positionTeleportOpen = Position(1003, 1217, 7),
	positionEnterEvent = Position(),
	storage = 12149,
	actionId = 6412,
	protectionTileId = {9562, 9563, 9564, 9565},
	levelMin = 150,
	minPlayers = 5,
	maxPlayers = 50,
	reward = {9020, 5},
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
	positionEvent = {firstTile = {x = 904, y = 580, z = 7}, tilesX = 18, tilesY = 12}
}

function safezoneTeleportCheck()
	local tile = Tile(SAFEZONE.positionTeleportOpen)
	if tile then
		local item = tile:getItemById(1387)
		if item then
			item:remove()

			local totalPlayers = safezoneTotalPlayers()
			if totalPlayers >= SAFEZONE.minPlayers then
				Game.broadcastMessage(SAFEZONE.messages.prefix .. SAFEZONE.messages.messageStart:format(totalPlayers), MESSAGE_STATUS_WARNING)
				createProtectionTiles()
				addEvent(function()
					if totalPlayers > 0 then
						Game.broadcastMessage(SAFEZONE.messages.prefix .. SAFEZONE.messages.messageTime, MESSAGE_STATUS_WARNING)
						safezoneRemovePlayers()
					end
				end, eventTimeTotal * 60 * 1000)
			else
				Game.broadcastMessage(SAFEZONE.messages.prefix .. SAFEZONE.messages.messageNoStart, MESSAGE_STATUS_WARNING)
				safezoneRemovePlayers()
			end
		else
			Game.broadcastMessage(SAFEZONE.messages.prefix .. SAFEZONE.messages.messageOpen:format(SAFEZONE.teleportTimeClose), MESSAGE_STATUS_WARNING)
			addEvent(Game.broadcastMessage, (SAFEZONE.teleportTimeClose - 3) * 60 * 1000, SAFEZONE.messages.prefix .. (SAFEZONE.messages.messageWait):format(SAFEZONE.teleportTimeClose - 2))
			addEvent(Game.broadcastMessage, (SAFEZONE.teleportTimeClose - 1) * 60 * 1000, SAFEZONE.messages.prefix .. (SAFEZONE.messages.messageWait):format(SAFEZONE.teleportTimeClose - 4))
			
			local teleport = Game.createItem(1387, 1, SAFEZONE.positionTeleportOpen)
			if teleport then
				teleport:setActionId(SAFEZONE.actionId)
			end
			addEvent(safezoneTeleportCheck, SAFEZONE.teleportTimeClose * 60000)
		end
	end
end

function safezoneRemovePlayers()
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(SAFEZONE.storage) > 0 then
			player:setStorageValue(SAFEZONE.storage, 0)
			player:setStorageValue(STORAGEVALUE_EVENTS, 0)
			player:teleportTo(player:getTown():getTemplePosition())
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		end
	end
end

function safezoneTotalPlayers()
	local x = 0
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(SAFEZONE.storage) > 0 then
			x = x + 1
		end
	end
	return x
end

local function totalProtectionTile()
	local totalPlayers = safezoneTotalPlayers()
	if totalPlayers >= 10 then
		return totalPlayers - 3
	else
		return totalPlayers - 1
	end
end

function createProtectionTiles()
	local totalPlayers = safezoneTotalPlayers()
	if safezoneTotalPlayers() == 1 then
		for _, player in ipairs(Game.getPlayers()) do
			if player:getStorageValue(SAFEZONE.storage) > 0 then
				player:setStorageValue(SAFEZONE.storage, 0)
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
		local createTiles, totalTiles = 0, totalProtectionTile()
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
						addEvent(deleteProtectionTiles, 5000, newPosition, randomTile)
						createTiles = createTiles + 1
					end
				end
			end
		end
		addEvent(safezoneEffectArea, 5000, SAFEZONE.positionEvent.firstTile, SAFEZONE.positionEvent.tilesX, SAFEZONE.positionEvent.tilesY)
		addEvent(checkPlayersinProtectionTiles, 4000)
		addEvent(createProtectionTiles, 6000)
	end
end

function deleteProtectionTiles(position, tileId)
	local tile = Tile(position)
	if tile then
		local item = tile:getItemById(tileId)
		if item then
			item:getPosition():sendMagicEffect(CONST_ME_POFF)
			item:remove()
		end
	end
end

function checkPlayersinProtectionTiles()
	local protectionTileId = SAFEZONE.protectionTileId
	for _, player in ipairs(Game.getPlayers()) do
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

function safezoneEffectArea(firstTile, tilesX, tilesY)
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