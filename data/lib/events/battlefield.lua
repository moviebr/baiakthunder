BATTLEFIELD = {
	openPortalPosition = Position(1003, 1217, 7),
	waitingRoomPosition = Position(1545, 1070, 4),
	baseRed = Position(1537, 1080, 6),
	baseBlue = Position(1553, 1080, 6),
	timeOpenPortal = 5, -- Em minutos
	timeEventTotal = 30, -- Em minutos
	timeRemoveWalls = 30, -- Em segundos
	minPlayers = 5,
	maxPlayers = 50,
	level = {
		active = true,
		levelMin = 150,
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
		messageWait = "O teleporte para o evento está aberto, você tem %d minuto(s) para entrar!",
		messageTimeEnd = "O evento foi encerrado por ultrapassar o tempo limite!",
		messageOpenWalls = "Os muros de madeira foram removidos! Boa sorte!",
	},
	walls = {
		[1] = Position(1546, 1095, 6),
		[2] = Position(1546, 1096, 6),
		[3] = Position(1546, 1097, 6),
		[4] = Position(1546, 1098, 6),
	},
	days = {
		["Sunday"] = {"15:00"},
		["Monday"] = {"15:00"},
		["Tuesday"] = {"15:00"},
		["Wednesday"] = {"15:00"},
		["Thursday"] = {"15:00"},
		["Friday"] = {"15:00"},
		["Saturday"] = {"15:00"},
	},
	players = {},
	blueTeamOutfit = {lookType = 134, lookHead = 88, lookBody = 88, lookLegs = 88, lookFeet = 88},
	redTeamOutfit = {lookType = 143, lookHead = 94, lookBody = 94, lookLegs = 94, lookFeet = 94},
	idWalls = 3516,
	actionID = 6489,
	storageEventStatus = 34873, 
	-- 0 não iniciou, 1 iniciou, 2 iniciou com ganhador azul, 3 iniciou com ganhador red, 4 iniciou sem ganhador
}

function BATTLEFIELD:totalPlayers()
	local x = 0
	local y = 0

	for a, b in pairs(BATTLEFIELD.players) do
		if a == "red" then
			x = x + 1
		else
			y = y + 1
		end
	end

	return x + y
end

function BATTLEFIELD:bluePlayers()
	local x = 0
	for b, c in pairs(BATTLEFIELD.players) do
		if b == "blue" then
			x = x + 1
		end
	end
	return x
end

function BATTLEFIELD:redPlayers()
	local y = 0
	for b, c in pairs(BATTLEFIELD.players) do
		if b == "red" then
			y = y + 1
		end
	end
	return y
end

function BATTLEFIELD:insertPlayer(playerId)
	local player = Player(playerId)

	if #BATTLEFIELD.players["red"] > #BATTLEFIELD.players["blue"] then
		table.insert(BATTLEFIELD.players["blue"], player:getId())
		player:sendCancelMessage(BATTLEFIELD.messages.prefix .."Você entrou para o time azul.")
		player:setOutfit(BATTLEFIELD.blueTeamOutfit)
	else
		table.insert(BATTLEFIELD.players["red"], player:getId())
		player:sendCancelMessage(BATTLEFIELD.messages.prefix .."Você entrou para o time vermelho.")
		player:setOutfit(BATTLEFIELD.redTeamOutfit)
	end

	player:setStorageValue(STORAGEVALUE_EVENTS, 1)
	player:teleportTo(BATTLEFIELD.waitingRoomPosition)
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	return true
end

function BATTLEFIELD:removePlayer(playerId)
	local player = Player(playerId)
	for a, b in pairs(BATTLEFIELD.players) do
		if b == player:getId() then
			b = nil
		end
	end
end

function BATTLEFIELD:checkTeleport()
	local tile = Tile(BATTLEFIELD.openPortalPosition)
	if tile then
		local item = tile:getItemById(1387)
		if item then
			item:getPosition():sendMagicEffect(CONST_ME_POFF)
			item:remove()
			if BATTLEFIELD:totalPlayers() >= BATTLEFIELD.minPlayers then
				Game.broadcastMessage(BATTLEFIELD.messages.prefix .. (BATTLEFIELD.messages.messageStart):format(totalPlayers), MESSAGE_STATUS_WARNING)
				for _, pid in pairs(BATTLEFIELD.players) do
					local player = Player(pid)
					player:sendTextMessage(MESSAGE_INFO_DESCR, BATTLEFIELD.messages.prefix .. "Em ".. BATTLEFIELD.timeRemoveWalls .." segundos os muros de madeira serão removidos!")
				end
				Game.setStorageValue(BATTLEFIELD.storageEventStatus, 1)
				addEvent(function()
					Game.broadcastMessage(BATTLEFIELD.messages.prefix .. BATTLEFIELD.messages.messageOpenWalls, MESSAGE_STATUS_WARNING)
					BATTLEFIELD:checkWalls()
				end, BATTLEFIELD.timeRemoveWalls * 1000)
				addEvent(function()
					if Game.getStorageValue(BATTLEFIELD.storageEventStatus) ~= 0 then
						Game.broadcastMessage(BATTLEFIELD.messages.prefix .. BATTLEFIELD.messages.messageTimeEnd, MESSAGE_STATUS_WARNING)
						Game.setStorageValue(BATTLEFIELD.storageEventStatus, 4)
						BATTLEFIELD:finishEvent()
					end
				end, BATTLEFIELD.timeEventTotal * 60 * 1000)
				BATTLEFIELD:startEvent()
			else
				Game.broadcastMessage(BATTLEFIELD.messages.prefix .. BATTLEFIELD.messages.messageNoStart, MESSAGE_STATUS_WARNING)
				Game.setStorageValue(BATTLEFIELD.storageEventStatus, 0)
				BATTLEFIELD:finishEvent()
			end
		else
			Game.broadcastMessage(BATTLEFIELD.messages.prefix .. (BATTLEFIELD.messages.messageOpen):format(BATTLEFIELD.timeOpenPortal), MESSAGE_STATUS_WARNING)
			addEvent(Game.broadcastMessage, (BATTLEFIELD.timeOpenPortal - 3) * 60 * 1000, BATTLEFIELD.messages.prefix .. (BATTLEFIELD.messages.messageWait):format(BATTLEFIELD.timeOpenPortal - 2))
			addEvent(Game.broadcastMessage, (BATTLEFIELD.timeOpenPortal - 1) * 60 * 1000, BATTLEFIELD.messages.prefix .. (BATTLEFIELD.messages.messageWait):format(BATTLEFIELD.timeOpenPortal - 4))
			local teleport = Game.createItem(1387, 1, BATTLEFIELD.openPortalPosition)
			if teleport then
				teleport:setActionId(BATTLEFIELD.actionID)
			end
			addEvent(BFcheckTeleport, BATTLEFIELD.timeOpenPortal * 60 * 1000)
			Game.setStorageValue(BATTLEFIELD.storageEventStatus, 0)
		end
	end
end

function BATTLEFIELD:checkStatus()
	local blueTeam = BATTLEFIELD:bluePlayers()
	local redTeam = BATTLEFIELD:redPlayers()
	local gameStatus = Game.getStorageValue(BATTLEFIELD.storageEventStatus)

	if blueTeam > 0 and redTeam == 0 then
		Game.broadcastMessage(BATTLEFIELD.messages.prefix .. (BATTLEFIELD.messages.messageFinish):format("azul"), MESSAGE_STATUS_WARNING)
		Game.setStorageValue(BATTLEFIELD.storageEventStatus, 2)
		BATTLEFIELD:finishEvent()
	elseif redTeam > 0 and blueTeam == 0 then
		Game.broadcastMessage(BATTLEFIELD.messages.prefix .. (BATTLEFIELD.messages.messageFinish):format("vermelho"), MESSAGE_STATUS_WARNING)
		Game.setStorageValue(BATTLEFIELD.storageEventStatus, 3)
		BATTLEFIELD:finishEvent()
	end

	if gameStatus ~= 0 then
		addEvent(function()
			BATTLEFIELD:checkStatus()
		end, 5000)
	end
end

function BATTLEFIELD:startEvent()
	if Game.getStorageValue(BATTLEFIELD.storageEventStatus) == 1 then
		for a, b in ipairs(BATTLEFIELD.players) do
			local player = Player(b)
			if a == "blue" and player:getId() == b then
				player:teleportTo(BATTLEFIELD.baseBlue)
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			else
				player:teleportTo(BATTLEFIELD.baseRed)
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			end
		end
	end
	addEvent(function()
		BATTLEFIELD:checkStatus()
	end, 30000)
end

function BATTLEFIELD:finishEvent()
	local gameStatus = Game.getStorageValue(BATTLEFIELD.storageEventStatus)
	if gameStatus == 0 or gameStatus == 4 then
		for a, b in pairs(BATTLEFIELD.players) do
			local player = Player(b)
			player:teleportTo(player:getTown():getTemplePosition())
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			player:setStorageValue(STORAGEVALUE_EVENTS, 0)
			BATTLEFIELD.players[a] = nil
		end
	elseif gameStatus == 2 or gameStatus == 3 then
		for c, d in pairs(BATTLEFIELD.players) do
			local player = Player(d)
			if c == "blue" and d == player:getId() and gameStatus == 2 then
				player:addItem(BATTLEFIELD.reward.itemId, BATTLEFIELD.reward.count)
			elseif c == "red" and d == player:getId() and gameStatus == 3 then
				player:addItem(BATTLEFIELD.reward.itemId, BATTLEFIELD.reward.count)
			end
			player:setStorageValue(STORAGEVALUE_EVENTS, 0)
			player:teleportTo(player:getTown():getTemplePosition())
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			BATTLEFIELD.players[c] = nil
		end
	end
	Game.setStorageValue(BATTLEFIELD.storageEventStatus, 0)
	BATTLEFIELD:checkWalls()
end

function BATTLEFIELD:checkWalls()
	for i = 1, #BATTLEFIELD.walls do 
		local tile = Tile(BATTLEFIELD.walls[i])
		if tile then
			local item = tile:getItemById(BATTLEFIELD.idWalls)
			if item then
				item:getPosition():sendMagicEffect(CONST_ME_POFF)
				item:remove()
			else
				wall = Game.createItem(BATTLEFIELD.idWalls, 1, BATTLEFIELD.walls[i])
				wall:getPosition():sendMagicEffect(CONST_ME_POFF)
			end
		end
	end
end