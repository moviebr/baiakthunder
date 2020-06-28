--[[
CREATE TABLE `castle_48` (
  `guild_id` int(3) NOT NULL,
  `time` int(11) NOT NULL,
	`winner` int(2) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1
]]

Castle48H = {
	players = {},
	msg = {
		prefix = "[Castle48H] ",
		endEvent = "O evento acabou e todos foram levados para o templo.",
		guildWinner = "A guild ganhadora foi a %s. Todos da guild ganham %d% a mais de experiência até as 15h de amanhã."
		openEvent = "O evento irá começar em %d minuto%s, preparem-se!",
		endingEvent = "O evento irá acabar em %d minutos! Conquistem o trono!"
		notOpen = "O evento ainda não foi aberto!",
		notGuild = "Você não possui guild para entrar nesse evento.",
		alreadyOwner = "A guild dominante já é a sua.",
		nowOwner = "A guild %s acabou de dominar o evento.",
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
	positionKing = Position(),
	uniqueIdLever = 7123,
	storageGlobal = 74641,
	storageGuildLever = 74642,
	actionIDEnter = 7197,
	actionIDExit = 7198,

}

function Castle48H:open()
	Game.broadcastMessage(Castle48H.msg.prefix .. Castle48H.msg.openEvent:format(5, "s"))
	addEvent(function()
		Game.setStorageValue(Castle48H.storageGlobal, 1)
	end, 5 * 60 * 1000)
end

function Castle48H:useLever(id)
	local guild = db.storeQuery("SELECT * FROM castle_48 WHERE guild_id = ".. id)
	if not guild then
		db.query("INSERT INTO castle48 (`guild_id`, `time`, `winner`) VALUES (".. id ..", 0, 0)")
		return true
	end

	local guildTime = result.getDataLong(guild, "time")

	return {id = id, time = guildTime}
end

function Castle48H:setTime(id)

end

function Castle48H:enter(player)
	table.insert(Castle48H.players, player:getId())
end

function Castle48H:exit(player)
	local index = table.find(Castle48H.players, player:getId())
	if index then
		table.remove(Castle48H.players, index)
	end
end

function Castle48H:close()
	Game.setStorageValue(Castle48H.storageGlobal, -1)
	Game.setStorageValue(Castle48H.storageGuildLever, -1)
	Game.broadcastMessage(Castle48H.msg.prefix .. Castle48H.msg.endEvent)
	addEvent(Game.broadcastMessage, 10 * 1000, Castle48H.msg.prefix .. Castle48H.msg.guildWinner:format(guild, Castle48H.plusXP)) -- Revisar
	addEvent(function()
		db.query("DELETE FROM `castle_48` WHERE `winner` = 0")
	end, )
	for a, id in ipairs(Castle48H.players) do
		local player = Player(id)
		if player then
			player:teleportTo(player:getTown():getTemplePosition())
			Player:getPosition():sendMagicEffect(CONST_ME_POFF)
			Castle48H.players[a] = nil
		end
	end
end
