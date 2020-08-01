local dodge = TalkAction("!dodge")
local critical = TalkAction("!critical")

function dodge.onSay(player, words, param)
	local skill = player:getDodgeLevel()
	local message = "DODGE SYSTEM\nO sistema consiste em defender uma porcentagem dos ataques recebidos.\n\nPor Exemplo:\nCada pedra utilizada atribui 0,3% a mais de chance.\nCom 10 pedras, voce tera 3% de chance de defender 50% dos ataques recebidos.\nCom 100 pedras (maximo), voce tera 30% de chance de defender 50% dos ataques recebidos.\nCada pedra que voce usar, sua skill de dodge aumenta em 1 ponto.\n\n------------------\nDodge Skill: [" .. skill .. "/100]"
	doPlayerPopupFYI(player, message)
end

dodge:register()

function critical.onSay(player, words, param)
	local skill = player:getCriticalLevel()
	local message = "CRITICAL SYSTEM\nO sistema consiste em ter uma chance de dar um dano critico.\n\nPor Exemplo:\nCada pedra utilizada atribui 0,3% a mais de chance.\nCom 10 pedras, voce tera 3% de chance de hitar um dano critico dos ataques desferidos ao seu oponente.\nCom 100 pedras (maximo), voce tera 30% de chance de hitar um dano critico dos ataques desferidos ao seu oponente.\nCada pedra que voce usar, sua skill de dodge aumenta em 1 ponto.\n\n------------------\nCritical Skill: [" .. skill .. "/100]"
	doPlayerPopupFYI(player, message)
end

critical:register()