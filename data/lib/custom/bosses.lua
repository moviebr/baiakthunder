config ={
	bosses = {
		["Ferumbras"] = {dia = "05/10/20", horario = 12, tempoMatar = 1,}, -- mes/dia/ano - somente a hora - em horas
	},
	posMensagem = Position(369, 196, 7),
	posNasceBoss = Position(367, 197, 7),
	mensagemUm = "Thunder, lightning and earthquakes in the depths of the continent ... The magic portal is collapsing!",  -- 15 min
	mensagemDois = "No more magic is able to stop what is to come. The portal is completely open!", -- 10 min
	mensagemTres = "Citizens, watch out! An evil creature has just escaped the portal.", -- 5 min
}

function verificarDiaeHorario()
	for index, v in pairs(config.bosses) do
		if v.dia == os.date("%x") and v.horario  == tonumber(os.date("%H")) then
			print(">> Boss System initiated [".. index .." - ".. v.horario .."]")
			addEvent(function()
				local monster = Game.createMonster(index, config.posNasceBoss)
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
	local pos = config.posMensagem
	
	addEvent(function()
	Game.sendTextOnPosition(config.mensagemUm, pos)
	end, 5 * 60 * 1000)
	addEvent(Game.broadcastMessage, 5 * 60 * 1000, config.mensagemUm, MESSAGE_STATUS_WARNING)
	addEvent(function()
	Game.sendTextOnPosition(config.mensagemDois, pos)
	end, 10 * 60 * 1000)
	addEvent(Game.broadcastMessage, 10 * 60 * 1000, config.mensagemDois, MESSAGE_STATUS_WARNING)
	addEvent(function()
	Game.sendTextOnPosition(config.mensagemTres, pos)
	end, 15 * 60 * 1000)
	addEvent(Game.broadcastMessage, 15 * 60 * 1000, config.mensagemTres, MESSAGE_STATUS_WARNING)
	return true
end

function removerMonstro(id)
	monstro = Monster(id)
	if monstro then
		monstro:getPosition():sendMagicEffect(CONST_ME_POFF)
		monstro:remove()
	end
end