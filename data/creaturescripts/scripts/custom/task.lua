function onKill(player, target)
	local playerPos = player:getPosition()
	local positions = {
		{x = playerPos.x - 7, y = playerPos.y - 5, playerPos.z},
		{x = playerPos.x + 7, y = playerPos.y + 5, playerPos.z},
	}
	local partyList = {}
	if target:isPlayer()  or target:getMaster() then
		return true
	end

	local mon_name = target:getName():lower()

	local party = player:getParty()

	if party then
		local members = party:getMembers()
		local leader = party:getLeader()
		for a, b in ipairs(members) do
			if isInArea(b:getPosition(), positions[1], positions[2]) then
				partyList[#partyList + 1] = b
			end
		end
		if isInArea(leader:getPosition(), positions[1], positions[2]) then
			partyList[#partyList + 1] = leader
		end

		for c, d in ipairs(partyList) do
			local player = Player(d)
			local movie = getTaskInfos(d)
			if movie then
				if mon_name == movie.name or isInArray(movie.mons_list, mon_name) then
					local sto_value = player:getStorageValue(movie.storage)
					if sto_value < movie.amount then
						sto_value = sto_value + 1
						player:setStorageValue(movie.storage, sto_value)
						if sto_value < movie.amount then
							player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, '[Task System] Foi morto ['..(sto_value)..'/'..movie.amount..'] '..mon_name..'.')
						else
							player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, '[Task System] Você terminou sua task.')
						end
					end
				end
			end

			local tvr = getTaskDailyInfo(d)
			if tvr then
				if mon_name == tvr.name or isInArray(tvr.mons_list, mon_name) then
					local sto_value = player:getStorageValue(tvr.storage)
					if sto_value < tvr.amount then
						sto_value = sto_value + 1
						player:setStorageValue(tvr.storage, sto_value)
						if sto_value < tvr.amount then
							player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, '[Task System Daily] Foi morto ['..(sto_value)..'/'..tvr.amount..'] '..mon_name..'.')
						else
							player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, '[Task System Daily] Você terminou sua task.')
						end
					end
				end
			end

		end
	else

		local ret_t = getTaskInfos(player)
		if ret_t then
			if mon_name == ret_t.name or isInArray(ret_t.mons_list, mon_name) then
			local sto_value = player:getStorageValue(ret_t.storage)
				if sto_value < ret_t.amount then
					sto_value = sto_value + 1
					player:setStorageValue(ret_t.storage, sto_value)
					if sto_value < ret_t.amount then
						player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, '[Task System] Foi morto ['..(sto_value)..'/'..ret_t.amount..'] '..mon_name..'.')
					else
						player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, '[Task System] Você terminou sua task.')
					end
				end
			end
		end

		local ret_td = getTaskDailyInfo(player)
		if ret_td then
			if mon_name == ret_td.name or isInArray(ret_td.mons_list, mon_name) then
				local sto_value = player:getStorageValue(ret_td.storage)
				if sto_value < ret_td.amount then
					sto_value = sto_value + 1
					player:setStorageValue(ret_td.storage, sto_value)
					if sto_value < ret_td.amount then
						player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, '[Task System Daily] Foi morto ['..(sto_value)..'/'..ret_td.amount..'] '..mon_name..'.')
					else
						player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, '[Task System Daily] Você terminou sua task.')
					end
				end
			end
		end
	end

	return true
end