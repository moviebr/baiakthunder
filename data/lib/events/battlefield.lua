BATTLEFIELD = {
	openPortalPosition = Position(1003, 1217, 7),
	waitingRoomPosition = Position(1545, 1070, 4),
	baseRed = Position(1537, 1080, 6),
	baseBlue = Position(1553, 1080, 6),
	timeOpenPortal = 5, -- Em minutos
	timeEventTotal = 20, -- Em minutos
	timeRemoveWalls = 20, -- Em segundos
	minPlayers = 5,
	maxPlayers = 50,
	level = {
		active = true,
		levelMin = 100,
	},
	reward = {
		itemId = 9020,
		count = 5,
	},
	messages = {
		prefix = "[Battlefield] ",
		messageOpen = "O evento foi aberto, você tem %d minutos para entrar no portal do evento que se encontra no templo!",
		messageStart = "O teleporte para o evento foi fechado e será iniciado com %d participantes! Boa sorte!",
		messageNoStart = "O evento não foi iniciado por falta de participantes!",
		messageFinish = "O evento acabou! O time %s foi o campeão do evento!",
		messageWait = "O teleporte para o evento está aberto, você tem %d minutos para entrar!",
	},
	walls = {
		[1] = Position(1546, 1095, 6),
		[2] = Position(1546, 1096, 6),
		[3] = Position(1546, 1097, 6),
		[4] = Position(1546, 1098, 6),
	},
	days = {
		["Sunday"] = {"14:05", "22:44"},
		["Monday"] = {"15:00", "18:42"},
		["Tuesday"] = {"15:00"},
		["Wednesday"] = {"15:00"},
		["Thursday"] = {"15:00"},
		["Friday"] = {"15:00"},
		["Saturday"] = {"15:00"},
	},
	blueTeamOutfit = {lookType = 134, lookHead = 88, lookBody = 88, lookLegs = 88, lookFeet = 88, addons = 3},
	redTeamOutfit = {lookType = 143, lookHead = 94, lookBody = 94, lookLegs = 94, lookFeet = 94, addons = 3},
	idWalls = 3517,
	actionID = 6489,
	storageTeam = 34870, -- Player - 1 azul, 2 vermelho
	storageTeamBlue = 34871, -- Game
	storageTeamRed = 34872, -- Game
	storageEventStatus = 34873, -- 0 não iniciou, 1 iniciou, 2 iniciou com ganhador azul, 3 inicou com ganhador red, 4 iniciou sem ganhador
}

function BFcheckTeleport()
	local tile = Tile(BATTLEFIELD.openPortalPosition)
	if tile then
		local item = tile:getItemById(1387)
		if item then
			item:getPosition():sendMagicEffect(CONST_ME_POFF)
			item:remove()
			local totalPlayers = BFcheckPlayers()
			if totalPlayers >= BATTLEFIELD.minPlayers then
				Game.broadcastMessage(BATTLEFIELD.messages.prefix .. (BATTLEFIELD.messages.messageStart):format(totalPlayers), MESSAGE_STATUS_WARNING)
				Game.setStorageValue(BATTLEFIELD.storageEventStatus, 1)
				BFstartEvent()
				addEvent(function()
					Game.setStorageValue(BATTLEFIELD.storageEventStatus, 4)
					BFfinishEvent()
			end, BATTLEFIELD.timeEventTotal * 60 * 1000)
			else
				Game.broadcastMessage(BATTLEFIELD.messages.prefix .. BATTLEFIELD.messages.messageNoStart, MESSAGE_STATUS_WARNING)
				Game.setStorageValue(BATTLEFIELD.storageEventStatus, 0)
				BFfinishEvent()
			end
		else
			Game.broadcastMessage(BATTLEFIELD.messages.prefix .. (BATTLEFIELD.messages.messageOpen):format(BATTLEFIELD.timeOpenPortal), MESSAGE_STATUS_WARNING)
			addEvent(Game.broadcastMessage, (BATTLEFIELD.timeOpenPortal - 3) * 60 * 1000, BATTLEFIELD.messages.prefix .. (BATTLEFIELD.messages.messageWait):format(BATTLEFIELD.timeOpenPortal - 2))
			addEvent(Game.broadcastMessage, (BATTLEFIELD.timeOpenPortal - 1) * 60 * 1000, BATTLEFIELD.messages.prefix .. (BATTLEFIELD.messages.messageWait):format(BATTLEFIELD.timeOpenPortal - 4))
			Game.setStorageValue(BATTLEFIELD.storageEventStatus, 0)
			Game.setStorageValue(BATTLEFIELD.storageTeamBlue, 0)
			Game.setStorageValue(BATTLEFIELD.storageTeamRed, 0)
			local teleport = Game.createItem(1387, 1, BATTLEFIELD.openPortalPosition)
			if teleport then
				teleport:setActionId(BATTLEFIELD.actionID)
			end
			addEvent(BFcheckTeleport, BATTLEFIELD.timeOpenPortal * 60 * 1000)
		end
	end
end

function BFcheckPlayers()
	local x = 0
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(STORAGEVALUE_EVENTS) >= 1 then
			x = x + 1
		end
	end
	return x
end

function BFcheckRedTeam()
	local y = 0
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(BATTLEFIELD.storageTeam) == 2 then
			y = y + 1
		end
	end
	return y
end

function BFcheckBlueTeam()
	local z = 0
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(BATTLEFIELD.storageTeam) == 1 then
			z = z + 1
		end
	end
	return z
end

function BFstartEvent()
	local blueTeam = BFcheckBlueTeam()
	local redTeam = BFcheckRedTeam()

	if blueTeam > 0 and redTeam == 0 then
		Game.broadcastMessage(BATTLEFIELD.messages.prefix .. (BATTLEFIELD.messages.messageFinish):format("azul"), MESSAGE_STATUS_WARNING)
		Game.setStorageValue(BATTLEFIELD.storageEventStatus, 2)
		BFfinishEvent()
	elseif redTeam > 0 and blueTeam == 0 then
		Game.broadcastMessage(BATTLEFIELD.messages.prefix .. (BATTLEFIELD.messages.messageFinish):format("vermelho"), MESSAGE_STATUS_WARNING)
		Game.setStorageValue(BATTLEFIELD.storageEventStatus, 3)
		BFfinishEvent()
	end

	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(BATTLEFIELD.storageTeam) == 1 then
			player:teleportTo(BATTLEFIELD.baseBlue)
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		elseif player:getStorageValue(BATTLEFIELD.storageTeam) == 2 then
			player:teleportTo(BATTLEFIELD.baseRed)
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		end
	end
	addEvent(BFcheckWalls, BATTLEFIELD.timeRemoveWalls * 1000)
end

function BFfinishEvent()
	local gameStatus = Game.getStorageValue(BATTLEFIELD.storageEventStatus)
	for _, player in ipairs(Game.getPlayers()) do
		player:setStorageValue(STORAGEVALUE_EVENTS, 0)
		if gameStatus == 2 then
			if player:getStorageValue(BATTLEFIELD.storageTeam) == 1 then
				player:addItem(BATTLEFIELD.reward.itemId, BATTLEFIELD.reward.count)
			end
				player:setStorageValue(storageTeam, 0)
				player:teleportTo(player:getTown():getTemplePosition())
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		elseif gameStatus == 3 then
			if player:getStorageValue(BATTLEFIELD.storageTeam) == 2 then
				player:addItem(BATTLEFIELD.reward.itemId, BATTLEFIELD.reward.count)
			end
				player:setStorageValue(storageTeam, 0)
				player:teleportTo(player:getTown():getTemplePosition())
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		else
			player:setStorageValue(storageTeam, 0)
			player:teleportTo(player:getTown():getTemplePosition())
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		end
	end
	Game.setStorageValue(BATTLEFIELD.storageEventStatus, 0)
	Game.setStorageValue(BATTLEFIELD.storageTeamRed, 0)
	Game.setStorageValue(BATTLEFIELD.storageTeamBlue, 0)
	BFcheckWalls()
end

function BFcheckWalls()
	for i = 1, #BATTLEFIELD.walls do 
		local tile = Tile(BATTLEFIELD.walls[i])
		if tile then
			local item = tile:getItemById(BATTLEFIELD.idWalls)
			if item then
				item:getPosition():sendMagicEffect(CONST_ME_POFF)
				item:remove()
			else
				wall = Game.createItem(1387, 1, BATTLEFIELD.walls[i])
				wall:getPosition():sendMagicEffect(CONST_ME_POFF)
			end
		end
	end
end