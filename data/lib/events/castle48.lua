--[[
CREATE TABLE `castle_48` (
  `guild_id` int(3) NOT NULL,
  `winner` int(2) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1
]]

Castle48H = {
	players = {},
	msg = {
		prefix = "[Castle48H] ",
		start = "O evento começou, boa sorte a todos as guilds!",
		endEvent = "O evento acabou e todos foram levados para o templo.",
		guildWinner = "A guild ganhadora foi a %s. Todos da guild ganham %d% a mais de experiência até as 15h de amanhã.",
		openEvent = "O evento irá começar em %d minuto%s, preparem-se!",
		endingEvent = "O evento irá acabar em %d minuto%s! Conquistem o trono!",
		notOpen = "O evento ainda não foi aberto!",
		notGuild = "Você não possui guild para entrar nesse evento.",
		alreadyOwner = "A guild dominante já é a sua.",
		nowOwner = "A guild %s acabou de dominar o evento.",
		notWinner = "Nenhuma guild conquistou o castelo.",
	},
	days = {
		["Sunday"] = {"20:00"},
		["Monday"] = {"20:00"},
		["Tuesday"] = {"20:00"},
		["Wednesday"] = {"20:00"},
		["Thursday"] = {"20:00"},
		["Friday"] = {"20:00"},
		["Saturday"] = {"20:00"},
	},
	plusXP = 50,
	uniqueIdLever = 7123,
	storageGlobal = 74641,
	storageLever = 74642,
	actionIDEnter = 7197,
	actionIDExit = 7198,
}

function Castle48H:open()
	Game.broadcastMessage(Castle48H.msg.prefix .. Castle48H.msg.openEvent:format(5, "s"))
	addEvent(Game.broadcastMessage, 3 * 60 * 1000, Castle48H.msg.prefix .. Castle48H.msg.openEvent:format(3, "s"))
	addEvent(Game.broadcastMessage, 4 * 60 * 1000, Castle48H.msg.prefix .. Castle48H.msg.openEvent:format(1, ""))
	addEvent(function()
		Game.broadcastMessage(Castle48H.msg.prefix .. Castle48H.msg.start)
		Game.setStorageValue(Castle48H.storageGlobal, 1)
	end, 5 * 60 * 1000)
end

function Castle48H:close()
	Game.broadcastMessage(Castle48H.msg.prefix .. Castle48H.msg.endingEvent:format(5, "s"))
	addEvent(Game.broadcastMessage, 3 * 60 * 1000, Castle48H.msg.prefix .. Castle48H.msg.endingEvent:format(3, "s"))
	addEvent(Game.broadcastMessage, 4 * 60 * 1000, Castle48H.msg.prefix .. Castle48H.msg.endingEvent:format(1, ""))
	addEvent(function()
		for a, b in ipairs(Castle48H.players) do
			local player = Player(b)
			player:teleportTo(player:getTown():getTemplePosition())
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			Castle48H.players[a] = nil
		end
	end, 5 * 60 * 1000)
	addEvent(function()
		if Game.getStorageValue(Castle48H.storageLever) == -1 then
			Game.broadcastMessage(Castle48H.msg.prefix .. Castle48H.msg.notWinner)
			return false
		end

		local guild = Guild(Game.getStorageValue(Castle48H.storageLever))
		Game.broadcastMessage(Castle48H.msg.prefix .. Castle48H.msg.guildWinner:format(guild:getName(), Castle48H.plusXP))
		Game.setStorageValue(STORAGEVALUE_CASTLE48_WINNER, Game.getStorageValue(Castle48H.storageLever))
		Game.setStorageValue(Castle48H.storageGlobal, -1)
		Game.setStorageValue(Castle48H.storageLever, -1)
	end, 5 * 60 * 1000)
end

function Castle48H:useLever(playerId)
	local castleStorage = Game.getStorageValue(Castle48H.storageLever)
	local player = Player(playerId)
	if not player then
		return false
	end

	if Game.getStorageValue(Castle48H.storageGlobal) ~= 1 then
		player:sendCancelMessage(Castle48H.msg.prefix .. Castle48H.msg.notOpen)
		player:teleportTo(player:getTown():getTemplePosition())
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		return false
	end

	local guild = player:getGuild()

	if not guild then
		player:sendCancelMessage(Castle48H.msg.prefix .. Castle48H.msg.notGuild)
		player:teleportTo(player:getTown():getTemplePosition())
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		return false
	end

	if castleStorage == guild:getId() then
		player:sendCancelMessage(Castle48H.msg.prefix .. Castle48H.msg.alreadyOwner)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	Game.setStorageValue(Castle48H.storageLever, guild:getId())
	Game.broadcastMessage(Castle48H.msg.prefix .. Castle48H.msg.nowOwner:format(guild:getName()))
	player:sendCancelMessage("Sua guild é a atual dona do castelo.")
	player:getPosition():sendMagicEffect(50)
	return true
end

function Castle48H:enter(playerId)
	local player = Player(playerId)
	if not player then
		return false
	end

	table.insert(Castle48H.players, player:getId())
end

function Castle48H:exit(playerId)
	local player = Player(playerId)
	if not player then
		return false
	end

	for a, b in ipairs(Castle48H.players) do
		if b == player:getId() then
			table.remove(Castle48H.players, player:getId())
		end
	end
end
