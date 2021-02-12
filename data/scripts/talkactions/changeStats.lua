local change = TalkAction("!changestats")

function change.onSay(player, words, param)
    
    local switch = player:getStorageValue(92131) == -1 and 1 or -1

	player:sendTextMessage(MESSAGE_INFO_DESCR, 'Vida e Mana (' .. (switch == 1 and 'porcentagem' or 'absoluto') .. ')')
	player:setStorageValue(92131, switch)

    return false
end

change:register()
