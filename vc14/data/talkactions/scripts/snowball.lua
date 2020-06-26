function onSay(player, words, param)
	if not isInArena(player) then
		return false
	end

	if param == SNOWBALL.comandoAtirar then
		if player:getExhaustion(10107) > 1 then
			return true
		end

		if not SNOWBALL.muniInfinito then
			if player:getStorageValue(10108) > 0 then
				player:setStorageValue(10108, player:getStorageValue(10108) - 1)
				player:sendCancelMessage(SNOWBALL.prefixo .. (SNOWBALL.mensagemQntBolas):format(player:getStorageValue(10108)))
			else
				player:sendCancelMessage(SNOWBALL.prefixo .. SNOWBALL.mensagemNaoTemBola)
				return true
			end
		end

		player:setExhaustion(10107, SNOWBALL.muniExhaust)
		enviarSnowball(player:getId(), player:getPosition(), SNOWBALL.muniDistancia, player:getDirection())
		return false
	elseif param == "info" then
		local str = "     ## -> Player Infos <- ##\n\nPontos: ".. player:getStorageValue(10109) .."\nBolas de neve: ".. player:getStorageValue(10108)

		str = str .. "\n\n          ## -> Ranking <- ##\n\n"
		for i = 1, 5 do
			if CACHE_GAMEPLAYERS[i] then
				str  = str .. i .. ". " .. Player(CACHE_GAMEPLAYERS[i]):getName() .."\n"
			end
		end
		for pos, players in ipairs(CACHE_GAMEPLAYERS) do
			if player:getId() == players then
				str = str .. "Minha posição no ranking: " .. pos
			end
		end

		player:showTextDialog(2111, str)
		return false
	end
end