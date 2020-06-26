function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end
	
	local split = param:split(",")
	local name = (split[1])
	local tempo = (split[2])
	local reason = (split[3])
	
	if name == nil or tempo == nil or reason == nil then
		player:popupFYI("----- [Ban System] -----\n\n/ipban Name, Time (in days), Reason\n\nExemple:\n/ipban Movie, 7, Flood")
		return false
	end
	
	if not tonumber(tempo) then
		player:sendCancelMessage("Write time with numbers only.")
		return false
	end

	local resultId = db.storeQuery("SELECT `name`, `lastip` FROM `players` WHERE `name` = " .. db.escapeString(name))
	if resultId == false then
		return false
	end

	local targetName = result.getString(resultId, "name")
	local targetIp = result.getNumber(resultId, "lastip")
	result.free(resultId)

	local targetPlayer = Player(name)
	if targetPlayer then
		targetIp = targetPlayer:getIp()
		targetPlayer:remove()
	end

	if targetIp == 0 then
		return false
	end

	resultId = db.storeQuery("SELECT 1 FROM `ip_bans` WHERE `ip` = " .. targetIp)
	if resultId ~= false then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, targetName .. "  is already IP banned.")
		result.free(resultId)
		return false
	end

	local timeNow = os.time()
	db.query("INSERT INTO `ip_bans` (`ip`, `reason`, `banned_at`, `expires_at`, `banned_by`) VALUES (" ..
			targetIp .. ", ".. db.escapeString(reason) ..", " .. timeNow .. ", " .. timeNow + (tempo * 86400) .. ", " .. player:getGuid() .. ")")
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, targetName .. "  has been IP banned.")
	return false
end
