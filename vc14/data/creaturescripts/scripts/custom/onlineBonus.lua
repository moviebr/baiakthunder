local event = {}

local function addOnlineToken(playerId)
    local player = Player(playerId)
    if not player then
        return false
    end
    if player:getIp() == 0 then
        event[player:getId()] = nil       
        return false
    end
    player:addOnlineTime(1)
    player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você ganhou 1 online token por permanecer online por 1 hora sem deslogar.")
    player:addItem(12543, 1)
    
    event[player:getId()] = addEvent(addOnlineToken, 60 * 60 * 1000, player:getId())
end

function onLogin(player)
	player:registerEvent("OnlineBonus")
	if event[player:getId()] == nil then
		event[player:getId()] = addEvent(addOnlineToken, 60 * 60 * 1000, player:getId())    
    end
    return true
end