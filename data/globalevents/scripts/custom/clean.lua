local function clean()
	cleanMap()
end

function Player.warnClean(self, x)
    if x <= 0 then
		return
	end
	
    self:say("Limpeza em ".. x .. " segundos", TALKTYPE_MONSTER_SAY, false, self)

    local playerName = self:getName()
    addEvent(function()
        local player = Player(playerName)
        if player then
            player:warnClean(x - 5)
        end
    end, 5000)
end


function onThink(interval)
	Game.broadcastMessage('O servidor se limpará em 5 minutos. Pegue seus itens.', MESSAGE_STATUS_WARNING)
	addEvent(Game.broadcastMessage, 60000, 'O servidor se limpará em 4 minutos. Pegue seus itens.', MESSAGE_STATUS_WARNING)
	addEvent(Game.broadcastMessage, 120000, 'O servidor se limpará em 3 minutos. Pegue seus itens.', MESSAGE_STATUS_WARNING)
	addEvent(Game.broadcastMessage, 180000, 'O servidor se limpará em 2 minutos. Pegue seus itens.', MESSAGE_STATUS_WARNING)
	addEvent(Game.broadcastMessage, 240000, 'O servidor se limpará em 1 minuto. Pegue seus itens.', MESSAGE_STATUS_WARNING)
	addEvent(Game.broadcastMessage, 270000, 'O servidor se limpará em 30 segundos. Pegue seus itens.', MESSAGE_STATUS_WARNING)
	addEvent(function()
		for pid, player in ipairs(Game.getPlayers()) do
			player:warnClean(30)
		end
	end, 270000)
	addEvent(clean, 5 * 60 * 1000)
	addEvent(Game.broadcastMessage, 5 * 60 * 1000, 'O servidor foi limpo, bom jogo. Próxima limpeza em 3 horas.', MESSAGE_STATUS_WARNING)
	return true
end