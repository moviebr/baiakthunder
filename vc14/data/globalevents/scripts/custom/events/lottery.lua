local rewards = {
	{5957, 1},
}

function onTime(interval)
	local players = Game.getPlayers()
	
	if #players > 0 and #rewards > 0 then
		local uid, n = math.random(1, #players), math.random(1, #rewards)
		local ganhador = players[uid]
		local reward, count = rewards[n][1], rewards[n][2]
		
		if ganhador and reward and count then
			ganhador:addItem(reward, count)
			Game.broadcastMessage('O jogador '.. ganhador:getName()..' foi sorteado na loteria. Parabéns!', MESSAGE_STATUS_WARNING)
		end
	end
	
	return true
end