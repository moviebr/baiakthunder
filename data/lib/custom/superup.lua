superUp = {
	msg = {
		naoDisponivel = "Essa cave está ocupada pelo jogador %s até %d.",
		disponivel = "Parabéns, você comprou uma cave do Super UP!",
		naoItem = "Você precisa de uma %s para comprar uma cave.",
		tempoAcabou = "O seu tempo de Super UP acabou!",
		possuiCave = "Você já possui uma cave do Super UP!",
	},
	areas = {
		[1] = {nome = "Demon", entrada = {x = 284, y = 223, z = 7}, from = {x = 284, y = 223, z = 7}, to = {x = 284, y = 223, z = 7}},
	},
	storage = 7143,
	storageTempo = 7144,
	itemID = 8978,
}

--[[
1. Player tem uma chave, ao tentar passar por
	1.1. Caso não tenha uma chave disponível, retornar erro
	1.2. Caso já tenha uma cave, retornar erro
	1.3. Comprar cave se tudo certo
		1. Adicionar uma storage com o value do index da cave
		2. Adicionar no banco de dados quem comprou, horário de compra e até quando ele comprou
		3. Adicionar uma storage com o tempo que ele tem de cave
			1. Fazer um onLogin e onThink para retirar ele da cave caso tenha acabado o tempo



2. Função verificar se tem cave
3. Função verificar de quem é a cave e quanto tempo restante
4. Função retirar player da cave caso tempo tenha acabado
--]]

function Player.hasCave(self)
	if self:getStorageValue(superUp.storage) >= 1 or self:getStorageValue(superUp.storageTempo) > os.time() then
		self:sendCancelMessage(superUp.possuiCave)
		self:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	else
		return true
	end
end

function caveOwnerAndTime(self, id)
	local resultId = db.storeQuery(string.format('SELECT * FROM `exclusive_hunts` WHERE `hunt_id` = %d AND `bought_by` = %s', id, db.escapeString(self:getName())))
	if not resultId then
		return false
	end

	local id = result.getDataInt(resultId, "hunt_id")
	local bought = result.getDataString(resultId, "bought_by")
	local to_time = result.getDataInt(resultId, "to_time")
	result.free(resultId)

	return {id = id, bought = bought, toTime = to_time}
end

