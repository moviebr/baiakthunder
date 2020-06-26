BOSSES ={
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

function openTpBosses()
	local tile = Tile(BOSSES.posTpOpen)
	if tile then
		local item = tile:getItemById(1387)
		if item then
			item:getPosition():sendMagicEffect(CONST_ME_POFF)
			item:remove()
		else
			local teleport = Game.createItem(1387, 1, BOSSES.posTpOpen)
			if teleport then
				teleport:setActionId(BOSSES.actionIdTp)
			end
			addEvent(openTpBosses, tempoTpAberto * 60 * 1000)
			addEvent(Game.broadcastMessage, (BOSSES.tempoTpAberto - 15) * 60 * 1000, (BOSSES.mensagemTpFechar))
		end
	end
end

function verificarDiaeHorario()
	for index, v in pairs(BOSSES.bosses) do
		if v.dia == os.date("%x") and v.horario  == tonumber(os.date("%H")) then
			addEvent(function()
				local monster = Game.createMonster(index, BOSSES.posNasceBoss)
				monster:setEmblem(GUILDEMBLEM_ENEMY)
				local idMonster = monster:getId()
			end, 15 * 60 * 1000)
			addEvent(function()
				removerMonstro(idMonster)
			end, v.tempoMatar * 60 * 60 * 1000)
			mandarMensagens()
		end
	end
end

function mandarMensagens()
	local pos = BOSSES.posMensagem
	
	addEvent(function()
	Game.sendTextOnPosition(BOSSES.mensagemUm, pos)
	end, 5 * 60 * 1000)
	addEvent(Game.broadcastMessage, 5 * 60 * 1000, BOSSES.mensagemUm, MESSAGE_STATUS_WARNING)
	addEvent(function()
	Game.sendTextOnPosition(BOSSES.mensagemDois, pos)
	end, 10 * 60 * 1000)
	addEvent(Game.broadcastMessage, 10 * 60 * 1000, BOSSES.mensagemDois, MESSAGE_STATUS_WARNING)
	addEvent(function()
	Game.sendTextOnPosition(BOSSES.mensagemTres, pos)
	end, 15 * 60 * 1000)
	addEvent(Game.broadcastMessage, 15 * 60 * 1000, BOSSES.mensagemTres, MESSAGE_STATUS_WARNING)
	return true
end

function removerMonstro(id)
	monstro = Monster(id)
	if monstro then
		monstro:getPosition():sendMagicEffect(CONST_ME_POFF)
		monstro:remove()
	end
end