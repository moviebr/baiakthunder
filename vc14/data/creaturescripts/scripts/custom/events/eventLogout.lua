function onLogout(player)
	local gameid = player:getStorageValue(currentgameid)
		if(gameid > 0 ) then
			player:getBackItems()
			player:setStorageValue(currentgameid, -1)
				if gameplayers[gameid] then
					for i=1,#gameplayers[gameid] do
						Player(gameplayers[gameid][i]):sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, player:getName() .. " has left the hunger games with "..player:getStorageValue(killstreak).." kills | Tributes still alive: " .. #gameplayers[gameid])
					end
					for k,v in pairs(gameplayers[gameid]) do
						if v == player:getName() then
							table.remove(gameplayers[gameid],k)
						end
					end
				end
			player:setStorageValue(killstreak, 0)
			player:teleportTo((player:getTown()):getTemplePosition())
			if gameplayers[gameid] and #gameplayers[gameid] == 1 then
				Player(gameplayers[gameid][1]):getBackItems()
				Player(gameplayers[gameid][1]):setStorageValue(gameid, -1)
				Game.broadcastMessage(MESSAGE_EVENT_ADVANCE,gameplayers[gameid][1] .." Has won The Hunger Games in ".. game[gameid].name .." with "..Player(gameplayers[gameid][1]):getStorageValue(killstreak).." Kill Streaks! Congratulations!")
				Player(gameplayers[gameid][1]):teleportTo((Player(gameplayers[gameid][1]):getTown()):getTemplePosition())
				Player(gameplayers[gameid][1]):setStorageValue(killstreak, 0)
				for _, item in pairs(prize) do
					Player(gameplayers[gameid][1]):addItem(item[1],item[2])
				end
				for k,v in pairs(gameplayers[gameid]) do
					if v == gameplayers[gameid][1] then
						table.remove(gameplayers[gameid],i)
					end
				end
				table.insert(availablearenas, gameid)
			elseif gameplayers[gameid] and #gameplayers[gameid] < 1 then
				Game.broadcastMessage(MESSAGE_EVENT_ADVANCE,game[gameid].name .." Has Ended without winners because all players have left the game!")
				table.insert(availablearenas, gameid)
			end
		end
		for k,v in pairs(queue) do
			if v == player:getName() then
				table.remove(queue,i)
			end
		end
	return true
end 