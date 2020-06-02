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

--[[
CREATE TABLE `exclusive_hunts` (
  `hunt_id` int(2) NOT NULL,
  `bought_by` VARCHAR(32) NOT NULL,
  `time` int(11) NOT NULL,
  `to_time` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1
]]

SUPERUP = {
	msg = {
		naoDisponivel = "Essa cave está ocupada pelo jogador %s até %d.",
		disponivel = "Parabéns, você comprou uma cave do Super UP!",
		naoItem = "Você precisa de uma %s para comprar uma cave.",
		tempoAcabou = "O seu tempo de Super UP acabou!",
		possuiCave = "Você já possui uma cave do Super UP!",
	},
	areas = {
		[1] = {nome = "Demon", entrada = Position(284, 223, 7), from = Position(284, 223, 7), to = Position(284, 223, 7)},
	},
	itemID = 8978,
}

function Player.hasCave(self)
	if self:getStorageValue(STORAGEVALUE_SUPERUP) >= 1 or self:getStorageValue(STORAGEVALUE_SUPERUP_TEMPO) > os.time() then
		self:sendCancelMessage(SUPERUP.possuiCave)
		self:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	else
		return true
	end
end