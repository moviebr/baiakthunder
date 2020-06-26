Bosses ={
	bosses = {
		["Merlin"] = {dia = "05/10/20", horario = 12, tempoMatar = 1,}, -- mes/dia/ano - somente a hora - em horas
	},
	posMensagem = Position(369, 196, 7),
	posNasceBoss = Position(1646, 975, 9),
	posTpOpen = Position(1003, 1217, 7),
	posDestino = Position(1646, 960, 8),
	level = {
		active = true,
		levelMin = 150,
	},
	tempoTpAberto = 20, -- Em minutos
	mensagemUm = "Trovões, raios e terremotos nas profundezas do continente ... O portal mágico está entrando em colapso!",  -- 15 min
	mensagemDois = "Não há mais magia capaz de parar o que está por vir. O portal está completamente aberto!", -- 10 min
	mensagemTres = "Cidadãos, cuidado! Uma criatura do mal acaba de escapar do portal.", -- 5 min
	mensagemTpFechar = "O teleport irá fechar em 5 minutos e não será possível entrar mais na sala do boss.",
	actionIdTp = 4247,
}

function Bosses:openTp()
	local tile = Tile(Bosses.posTpOpen)
	if tile then
		local item = tile:getItemById(1387)
		if item then
			item:getPosition():sendMagicEffect(CONST_ME_POFF)
			item:remove()
		else
			local teleport = Game.createItem(1387, 1, Bosses.posTpOpen)
			if teleport then
				teleport:setActionId(Bosses.actionIdTp)
			end
			addEvent(function()
				Bosses:openTp()
			end, Bosses.tempoTpAberto * 60 * 1000)
			addEvent(Game.broadcastMessage, (Bosses.tempoTpAberto - 15) * 60 * 1000, (Bosses.mensagemTpFechar))
		end
	end
end

function Bosses:checkTime()
	for index, v in pairs(Bosses.bosses) do
		if v.dia == os.date("%x") and v.horario  == tonumber(os.date("%H")) then
			addEvent(function()
				local monster = Game.createMonster(index, Bosses.posNasceBoss)
				monster:setEmblem(GUILDEMBLEM_ENEMY)
				local idMonster = monster:getId()
			end, 15 * 60 * 1000)
			addEvent(function()
				Bosses:removeMonster(idMonster)
			end, v.tempoMatar * 60 * 60 * 1000)
			Bosses:sendMessages()
		end
	end
end

function Bosses:sendMessages()
	local pos = Bosses.posMensagem
	
	addEvent(function()
	Game.sendTextOnPosition(Bosses.mensagemUm, pos)
	end, 5 * 60 * 1000)
	addEvent(Game.broadcastMessage, 5 * 60 * 1000, Bosses.mensagemUm, MESSAGE_STATUS_WARNING)
	addEvent(function()
	Game.sendTextOnPosition(Bosses.mensagemDois, pos)
	end, 10 * 60 * 1000)
	addEvent(Game.broadcastMessage, 10 * 60 * 1000, Bosses.mensagemDois, MESSAGE_STATUS_WARNING)
	addEvent(function()
	Game.sendTextOnPosition(Bosses.mensagemTres, pos)
	end, 15 * 60 * 1000)
	addEvent(Game.broadcastMessage, 15 * 60 * 1000, Bosses.mensagemTres, MESSAGE_STATUS_WARNING)
	return true
end

function Bosses:removeMonster(id)
	monstro = Monster(id)
	if monstro then
		monstro:getPosition():sendMagicEffect(CONST_ME_POFF)
		monstro:remove()
	end
end