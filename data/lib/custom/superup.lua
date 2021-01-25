SUPERUP = {
	msg = {
		naoDisponivel = "Essa cave está ocupada pelo jogador %s até %s.",
		disponivel = "Parabéns, você comprou uma cave do Super UP com duração de %d %s!",
		naoItem = "Você precisa de uma %s para comprar uma cave.",
		tempoAcabou = "O seu tempo de Super UP acabou!",
		possuiCave = "Você já possui uma cave do Super UP!",
	},
	areas = {
		[20000] = {nome = "Demon", entrada = Position(546, 1250, 7), from = Position(1008, 889, 7), to = Position(1030, 903, 7)},
		[20001] = {nome = "Grim Reaper", entrada = Position(548, 1249, 7), from = Position(1008, 889, 7), to = Position(1030, 903, 7)},
		[20002] = {nome = "Grim Reaper", entrada = Position(548, 1249, 7), from = Position(1008, 889, 7), to = Position(1030, 903, 7)},
		[20003] = {nome = "Grim Reaper", entrada = Position(548, 1249, 7), from = Position(1008, 889, 7), to = Position(1030, 903, 7)},
		[20004] = {nome = "Grim Reaper", entrada = Position(548, 1249, 7), from = Position(1008, 889, 7), to = Position(1030, 903, 7)},
		[20005] = {nome = "Grim Reaper", entrada = Position(548, 1249, 7), from = Position(1008, 889, 7), to = Position(1030, 903, 7)},
		[20006] = {nome = "Grim Reaper", entrada = Position(548, 1249, 7), from = Position(1008, 889, 7), to = Position(1030, 903, 7)},
		[20007] = {nome = "Grim Reaper", entrada = Position(548, 1249, 7), from = Position(1008, 889, 7), to = Position(1030, 903, 7)},
		[20008] = {nome = "Grim Reaper", entrada = Position(548, 1249, 7), from = Position(1008, 889, 7), to = Position(1030, 903, 7)},
		[20009] = {nome = "Grim Reaper", entrada = Position(548, 1249, 7), from = Position(1008, 889, 7), to = Position(1030, 903, 7)},
		[20010] = {nome = "Grim Reaper", entrada = Position(548, 1249, 7), from = Position(1008, 889, 7), to = Position(1030, 903, 7)},
		[20011] = {nome = "Grim Reaper", entrada = Position(548, 1249, 7), from = Position(1008, 889, 7), to = Position(1030, 903, 7)},
		[20012] = {nome = "Grim Reaper", entrada = Position(548, 1249, 7), from = Position(1008, 889, 7), to = Position(1030, 903, 7)},
		[20013] = {nome = "Grim Reaper", entrada = Position(548, 1249, 7), from = Position(1008, 889, 7), to = Position(1030, 903, 7)},
		[20014] = {nome = "Grim Reaper", entrada = Position(548, 1249, 7), from = Position(1008, 889, 7), to = Position(1030, 903, 7)},
		[20015] = {nome = "Grim Reaper", entrada = Position(548, 1249, 7), from = Position(1008, 889, 7), to = Position(1030, 903, 7)},
		[20016] = {nome = "Grim Reaper", entrada = Position(548, 1249, 7), from = Position(1008, 889, 7), to = Position(1030, 903, 7)},
		[20017] = {nome = "Grim Reaper", entrada = Position(548, 1249, 7), from = Position(1008, 889, 7), to = Position(1030, 903, 7)},
		[20018] = {nome = "Grim Reaper", entrada = Position(548, 1249, 7), from = Position(1008, 889, 7), to = Position(1030, 903, 7)},
		[20019] = {nome = "Grim Reaper", entrada = Position(548, 1249, 7), from = Position(1008, 889, 7), to = Position(1030, 903, 7)},
		[20020] = {nome = "Grim Reaper", entrada = Position(548, 1249, 7), from = Position(1008, 889, 7), to = Position(1030, 903, 7)},
	},
	setTime = 3, -- Em horas
	itemID = 8978,
}

function SUPERUP:getCave(id)
	local resultCave = db.storeQuery("SELECT guid_player, to_time FROM exclusive_hunts WHERE `hunt_id` = " .. id)
	if not resultCave then
		return false
	end

	local caveOwner = result.getDataInt(resultCave, "guid_player")
	local caveTime = result.getDataLong(resultCave, "to_time")
	result.free(resultCave)

	return {dono = caveOwner, tempo = caveTime}
end

function SUPERUP:freeCave()
	freeCaves = {}
	local db = db.storeQuery("SELECT `hunt_id`, `to_time`, `guid_player` FROM exclusive_hunts")
	if not db then
		return
	end

	repeat
		local idHunt = result.getDataInt(db, "hunt_id")
		local tempoFinal = result.getDataLong(db, "to_time")
		local guidPlayer = result.getDataInt(db, "guid_player")
		result.free(db)

		table.insert(freeCaves, {idHunt, tempoFinal, guidPlayer})

	until not result.next(db)
	return freeCaves
end
