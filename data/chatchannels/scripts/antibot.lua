function onJoin(player)
	if not ANTIBOT.playerQuestion[player:getId()] then
		player:sendTextMessage(MESSAGE_STATUS_BLUE_LIGHT, ANTIBOT.prefix .. ANTIBOT.messages.chat)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end
	return true
end

function onLeave(player)
	if ANTIBOT.playerQuestion[player:getId()] then
		return false
	end
	return true
end


function onSpeak(player, type, message)
	if not ANTIBOT.playerQuestion[player:getId()] then
		sendChannelMessage(13, TALKTYPE_CHANNEL_O, ANTIBOT.prefix .. ANTIBOT.messages.chat)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local question = ANTIBOT.questions[ANTIBOT.playerQuestion[player:getId()]]

	if question.skill then
		correctAnswer = tonumber(player:getSkillLevel(question.answer))
		message = tonumber(message)
	elseif question.answer == "level" then
		correctAnswer = tonumber(player:getLevel())
		message = tonumber(message)
	elseif question.answer == "day" then
		correctAnswer = tonumber(os.date("%d"))
		message = tonumber(message)
	elseif question.staticAnswer then
		message = message:lower()
		correctAnswer = question.answer:lower()
	end

	verification = false

	if message == correctAnswer then
		verification = true
	end

	if verification then
		addEvent(sendChannelMessage, 200, 13, TALKTYPE_CHANNEL_O, ANTIBOT.prefix .. ANTIBOT.messages.correctAnswer)
		ANTIBOT:reset(player:getId())
	else
		ANTIBOT:addTry(player:getId())
		addEvent(function()
			if ANTIBOT.punishment.try.players[player:getId()] and ANTIBOT.punishment.try.players[player:getId()] < ANTIBOT.punishment.try.max and player then
				sendChannelMessage(13, TALKTYPE_CHANNEL_O, ANTIBOT.prefix .. ANTIBOT.messages.incorrectAnswer:format(ANTIBOT.punishment.try.max - ANTIBOT.punishment.try.players[player:getId()]))
			end
		end, 100)
	end

	return true
end