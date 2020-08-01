local ban = TalkAction("/ban")

function ban.onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end
	
	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end

	local split = param:split(",")
	local name = (split[1])
	local tempo = (split[2])
	local reason = (split[3])
	
	if not name or not tempo or not reason then
		player:popupFYI("--------- [Ban System] ---------\n\n/ban Nome, Tempo (em dias), Razão\n\nExemplo:\n/ban Movie, 7, Flood")
		return false
	end

	if not tonumber(tempo) then
		player:sendCancelMessage("Escrevo o tempo em números.")
		return false
	end

	local accountId = getAccountNumberByPlayerName(name)
	if accountId == 0 then
		return false
	end

	local resultId = db.storeQuery("SELECT 1 FROM `account_bans` WHERE `account_id` = " .. accountId)
	if resultId ~= false then
		result.free(resultId)
		return false
	end

	local timeNow = os.time()
	db.query("INSERT INTO `account_bans` (`account_id`, `reason`, `banned_at`, `expires_at`, `banned_by`) VALUES (" ..
			accountId .. ", " .. db.escapeString(reason) .. ", " .. timeNow .. ", " .. timeNow + (tempo * 86400) .. ", " .. player:getGuid() .. ")")

	local target = Player(name)
	if target then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, target:getName() .. " foi banido.")
		target:remove()
	else
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, name .. " foi banido.")
	end
end

ban:separator(" ")
ban:register()