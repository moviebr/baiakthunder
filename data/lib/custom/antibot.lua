ANTIBOT = {
	prefix = "[AntiBot] ",
	questions = {
		{question = "Qual o ano que começou o COVID-19?", staticAnswer = true, answer = "2019"},
		{question = "Qual seu skill atual de Sword?", skill = true, answer = SKILL_SWORD},
		{question = "Qual seu skill atual de Club?", skill = true, answer = SKILL_CLUB},
		{question = "Qual seu skill atual de Distance?", skill = true, answer = SKILL_DISTANCE},
		{question = "Qual seu level atual?", answer = "level"},
		{question = "Qual o dia de hoje?", answer = "day"},
	},
	playerQuestion = {},
	messages = {
		time = "Você possui %s para responder a pergunta.",
		chat = "Esse chat só pode ser usado durante a verificação.",
		howAnswer = "Você deve responder somente a resposta, por exemplo: Qual o dia de hoje? Resposta: %d",
		correctAnswer = "Você acertou a pergunta. Obrigado.",
		incorrectAnswer = "Você errou a resposta, você ainda possui %d tentativas.",
		logout = "Você não pode deslogar enquanto hover uma verificação ativa.",
	},
	punishment = {
		try = {
			max = 3,
			reason = "Quantidade excessiva de tentativas.",
			timePunishment = 1, -- In days
			players = {},
		},
		time = {
			maxTime = 180, -- In seconds
			reason = "Não respondeu a pergunta dentro do tempo estipulado.",
			timePunishment = 2, -- In days
			players = {},
		},
	},
	notUseOnTrainers = true, -- True = training players will not be checked
	notUseOnPz = true, -- True = players on pz will not be checked
	verification = {40, 60}, -- in minutes
}

function ANTIBOT:addTry(playerId)

	local player = Player(playerId)

	if not player then 
		return false
	end

	playerId = player:getId()

	if not ANTIBOT.punishment.try.players[playerId] then
		ANTIBOT.punishment.try.players[playerId] = 0
	end

	ANTIBOT.punishment.try.players[playerId] = ANTIBOT.punishment.try.players[playerId] + 1

	if ANTIBOT.punishment.try.players[playerId] and ANTIBOT.punishment.try.players[playerId] >= ANTIBOT.punishment.try.max then
		sendChannelMessage(13, TALKTYPE_CHANNEL_O, ANTIBOT.prefix .. ANTIBOT.punishment.try.reason)
		ANTIBOT:addPunishment(playerId)
	end
end

function ANTIBOT:time(playerId)
	local player = Player(playerId)

	if not player then
		ANTIBOT:reset(playerId)
		return false
	end

	playerId = player:getId()

	if (ANTIBOT.notUseOnPz) and (Tile(player:getPosition()):hasFlag(TILESTATE_PROTECTIONZONE)) then
		ANTIBOT:reset(playerId)
		return false
	end

	if ANTIBOT.notUseOnTrainers and staminaBonus.events[player:getName()] then
		ANTIBOT:reset(playerId)
		return false
	end

	if not ANTIBOT.punishment.time.players[playerId] then
		ANTIBOT.punishment.time.players[playerId] = 0
		ANTIBOT:sendQuestions(playerId)
	end

	addEvent(function()
		if ANTIBOT.punishment.time.players[playerId] and ANTIBOT.punishment.time.players[playerId] >= 0 and ANTIBOT.punishment.time.players[playerId] < ANTIBOT.punishment.time.maxTime then
			ANTIBOT.punishment.time.players[playerId] = ANTIBOT.punishment.time.players[playerId] + 1
			player:sendCancelMessage(ANTIBOT.prefix .. ANTIBOT.messages.time:format(string.diff(ANTIBOT.punishment.time.maxTime - ANTIBOT.punishment.time.players[playerId], true)))
			ANTIBOT:time(playerId)
		end
	end, 1000)

	if ANTIBOT.punishment.time.players[playerId] and ANTIBOT.punishment.time.players[playerId] >= ANTIBOT.punishment.time.maxTime then
		ANTIBOT:addPunishment(playerId)
	end

end

function ANTIBOT:sendQuestions(playerId)

	local player = Player(playerId)

	if not player then
		return false
	end

	playerId = player:getId()

	random = math.random(#ANTIBOT.questions)

	ANTIBOT.playerQuestion[playerId] = random

	player:say("ANTIBOT", TALKTYPE_MONSTER_SAY)
	player:openChannel(13)
	addEvent(sendChannelMessage, 500, 13, TALKTYPE_CHANNEL_O, ANTIBOT.prefix .. ANTIBOT.messages.howAnswer:format(os.date("%d")))
	addEvent(sendChannelMessage, 800, 13, TALKTYPE_CHANNEL_O, ANTIBOT.prefix .. ANTIBOT.questions[random].question)
end

function ANTIBOT:reset(playerId)
	ANTIBOT.punishment.try.players[playerId] = nil
	ANTIBOT.punishment.time.players[playerId] = nil
	ANTIBOT.playerQuestion[playerId] = nil
end

function ANTIBOT:addPunishment(playerId)

	local player = Player(playerId)
	if not player then 
		return false
	end

	playerId = player:getId()

	local accountId = getAccountNumberByPlayerName(player:getName())
	if accountId == 0 then
		return false
	end

	local resultId = db.storeQuery("SELECT 1 FROM `account_bans` WHERE `account_id` = " .. accountId)
	if resultId ~= false then
		result.free(resultId)
		return false
	end

	local timeNow = os.time()

	if ANTIBOT.punishment.try.players[playerId] and ANTIBOT.punishment.try.players[playerId] >= ANTIBOT.punishment.try.max then
		db.query("INSERT INTO `account_bans` (`account_id`, `reason`, `banned_at`, `expires_at`, `banned_by`) VALUES (" ..
			accountId .. ", " .. db.escapeString(ANTIBOT.prefix .. ANTIBOT.punishment.try.reason) .. ", " .. timeNow .. ", " .. timeNow + (ANTIBOT.punishment.try.timePunishment * 86400) .. ", " .. player:getGuid() .. ")")
	elseif ANTIBOT.punishment.time.players[playerId] and ANTIBOT.punishment.time.players[playerId] >= ANTIBOT.punishment.time.maxTime then
		db.query("INSERT INTO `account_bans` (`account_id`, `reason`, `banned_at`, `expires_at`, `banned_by`) VALUES (" ..
			accountId .. ", " .. db.escapeString(ANTIBOT.prefix .. ANTIBOT.punishment.time.reason) .. ", " .. timeNow .. ", " .. timeNow + (ANTIBOT.punishment.time.timePunishment * 86400) .. ", " .. player:getGuid() .. ")")
	end

	ANTIBOT:reset(playerId)
	player:save()
	player:getPosition():sendMagicEffect(CONST_ME_POFF)
	player:remove()
end
