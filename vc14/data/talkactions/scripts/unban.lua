function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end
	
	if param == "" then
		player:popupFYI("----- [Ban System] -----\n\n/unban Name\n\nExemple:\n/unban Movie")
		return false
	end

	local resultId = db.storeQuery("SELECT `account_id`, `lastip` FROM `players` WHERE `name` = " .. db.escapeString(param))
	if resultId == false then
		return false
	end

	db.asyncQuery("DELETE FROM `account_bans` WHERE `account_id` = " .. result.getNumber(resultId, "account_id"))
	db.asyncQuery("DELETE FROM `ip_bans` WHERE `ip` = " .. result.getNumber(resultId, "lastip"))
	result.free(resultId)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, param .. " has been unbanned.")
	return false
end
