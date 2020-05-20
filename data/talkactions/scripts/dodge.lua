function onSay(player, words, param)
	local skill = player:getDodgeLevel()
	local message = "DODGE SYSTEM\nO sistema consiste em defender % dos ataques recebidos.\n\nPor Exemplo:\nCada pedra utilizada atribui 0,3% a mais de chance.\nCom 10 pedras, voce tera 3% de chance de defender 50% dos ataques recebidos.\nCom 100 pedras (maximo), voce tera 30% de chance de defender 50% dos ataques recebidos.\nCada pedra que voce usar, sua skill de dodge aumenta em 1 ponto.\n\n------------------\nDodge Skill: [" .. skill .. "/100]"
	doPlayerPopupFYI(player, message)
end