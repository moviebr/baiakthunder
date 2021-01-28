local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local count = {}
local transfer = {}

function onCreatureAppear(cid)
npcHandler:onCreatureAppear(cid)
end
function onCreatureDisappear(cid)
npcHandler:onCreatureDisappear(cid)
end
function onCreatureSay(cid, type, msg)
npcHandler:onCreatureSay(cid, type, msg)
end
function onThink()
npcHandler:onThink()
end

local voices = { {text = 'Não se esqueça de depositar seu dinheiro aqui no Banco antes de sair para a aventura.'} }
npcHandler:addModule(VoiceModule:new(voices))
--------------------------------guild bank-----------------------------------------------
local receiptFormat = 'Data: %s\nType: %s\nQuantidade: %d\nReceipt Owner: %s\nRecipient: %s\n\n%s'
local function getReceipt(info)
	local receipt = Game.createItem(info.success and 24301 or 24302)
	receipt:setAttribute(ITEM_ATTRIBUTE_TEXT, receiptFormat:format(os.date('%d. %b %Y - %H:%M:%S'), info.type, info.amount, info.owner, info.recipient, info.message))

	return receipt
end

local function getGuildIdByName(name, func)
	db.asyncStoreQuery('SELECT `id` FROM `guilds` WHERE `name` = ' .. db.escapeString(name),
		function(resultId)
			if resultId then
				func(result.getNumber(resultId, 'id'))
				result.free(resultId)
			else
				func(nil)
			end
		end
	)
end

local function getGuildBalance(id)
	local guild = Guild(id)
	if guild then
		return guild:getBankBalance()
	else
		local balance
		local resultId = db.storeQuery('SELECT `balance` FROM `guilds` WHERE `id` = ' .. id)
		if resultId then
			balance = result.getNumber(resultId, 'balance')
			result.free(resultId)
		end

		return balance
	end
end

local function setGuildBalance(id, balance)
	local guild = Guild(id)
	if guild then
		guild:setBankBalance(balance)
	else
		db.query('UPDATE `guilds` SET `balance` = ' .. balance .. ' WHERE `id` = ' .. id)
	end
end

local function transferFactory(playerName, amount, fromGuildId, info)
	return function(toGuildId)
		if not toGuildId then
			local player = Player(playerName)
			if player then
				info.success = false
				info.message = 'Lamentamos informar que não foi possível atender sua solicitação, porque não conseguimos encontrar a guild destinatária.'
				local inbox = player:getInbox()
				local receipt = getReceipt(info)
				inbox:addItemEx(receipt, INDEX_WHEREEVER, FLAG_NOLIMIT)
			end
		else
			local fromBalance = getGuildBalance(fromGuildId)
			if fromBalance < amount then
				info.success = false
				info.message = 'Lamentamos informar que não foi possível atender sua solicitação devido à falta da quantia necessária em sua conta da guild.'
			else
				info.success = true
				info.message = 'Temos o prazer de informar que sua solicitação de transferência foi realizada com sucesso.'
				setGuildBalance(fromGuildId, fromBalance - amount)
				setGuildBalance(toGuildId, getGuildBalance(toGuildId) + amount)
			end

			local player = Player(playerName)
			if player then
				local inbox = player:getInbox()
				local receipt = getReceipt(info)
				inbox:addItemEx(receipt, INDEX_WHEREEVER, FLAG_NOLIMIT)
			end
		end
	end
end
--------------------------------guild bank-----------------------------------------------

local function greetCallback(cid)
	count[cid], transfer[cid] = nil, nil
	return true
end

local function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end
	local player = Player(cid)
---------------------------- help ------------------------
	if msgcontains(msg, 'bank account') or msgcontains(msg, 'conta da guild') then
		npcHandler:say({
			'Todo cidadão tem um. A grande vantagem é que você pode acessar seu dinheiro em todas as agências do Banco! ...',
			'Gostaria de saber mais sobre as funções {básicas} da sua conta bancária, as funções {avançadas} ou talvez já esteja entediado?'
		}, cid)
		npcHandler.topic[cid] = 0
		return true
---------------------------- balance ---------------------
--------------------------------guild bank-----------------------------------------------
	elseif msgcontains(msg, 'guild balance') then
		npcHandler.topic[cid] = 0
		if not player:getGuild() then
			npcHandler:say('Você não é membro de uma guild.', cid)
			return false
		end
		npcHandler:say('O saldo da conta da sua guild é ' .. player:getGuild():getBankBalance() .. ' gold.', cid)
		return true
--------------------------------guild bank-----------------------------------------------
	elseif msgcontains(msg, 'balance') or msgcontains(msg, 'saldo') then
		npcHandler.topic[cid] = 0
		if player:getBankBalance() >= 100000000 then
			npcHandler:say('Eu acho que você deve ser um dos habitantes mais ricos do mundo! O saldo da sua conta é ' .. player:getBankBalance() .. ' gold.', cid)
			return true
		elseif player:getBankBalance() >= 10000000 then
			npcHandler:say('Você ganhou dez milhões e ainda cresce! O saldo da sua conta é ' .. player:getBankBalance() .. ' gold.', cid)
			return true
		elseif player:getBankBalance() >= 1000000 then
			npcHandler:say('Uau, você atingiu o número mágico de um milhão de golds!! O saldo da sua conta é ' .. player:getBankBalance() .. ' gold!', cid)
			return true
		else
			npcHandler:say('O saldo da sua conta é ' .. player:getBankBalance() .. ' gold.', cid)
			return true
		end
---------------------------- deposit ---------------------
--------------------------------guild bank-----------------------------------------------
	elseif msgcontains(msg, 'guild deposit') then
		if not player:getGuild() then
			npcHandler:say('Você não é membro de uma guild.', cid)
			npcHandler.topic[cid] = 0
			return false
		end
	   -- count[cid] = player:getMoney()
	   -- if count[cid] < 1 then
		   -- npcHandler:say('You do not have enough gold.', cid)
		   -- npcHandler.topic[cid] = 0
		   -- return false
		--end
		if string.match(msg, '%d+') then
			count[cid] = getMoneyCount(msg)
			if count[cid] < 1 then
				npcHandler:say('Você não tem dinheiro.', cid)
				npcHandler.topic[cid] = 0
				return false
			end
			npcHandler:say('Você gostaria de depositar ' .. count[cid] .. ' gold na sua {guild account} ou {conta da guild}?', cid)
			npcHandler.topic[cid] = 23
			return true
		else
			npcHandler:say('Por favor me diga quantos gold você gostaria de depositar.', cid)
			npcHandler.topic[cid] = 22
			return true
		end
	elseif npcHandler.topic[cid] == 22 then
		count[cid] = getMoneyCount(msg)
		if isValidMoney(count[cid]) then
			npcHandler:say('Você realmente gostaria de depositar ' .. count[cid] .. ' gold para sua {guild account} ou {conta da guild}?', cid)
			npcHandler.topic[cid] = 23
			return true
		else
			npcHandler:say('Você não tem dinheiro.', cid)
			npcHandler.topic[cid] = 0
			return true
		end
	elseif npcHandler.topic[cid] == 23 then
		if msgcontains(msg, 'yes') or msgcontains(msg, 'sim') then
			npcHandler:say('Tudo bem, fizemos um pedido para depositar a quantidade de ' .. count[cid] .. ' gold da conta da guild. Verifique sua inbox para confirmação.', cid)
			local guild = player:getGuild()
			local info = {
				type = 'Guild Deposit',
				amount = count[cid],
				owner = player:getName() .. ' da ' .. guild:getName(),
				recipient = guild:getName()
			}
			local playerBalance = player:getBankBalance()
			if playerBalance < tonumber(count[cid]) then
				info.message = 'Lamentamos informar que não foi possível atender sua solicitação devido à falta da quantia necessária em sua conta bancária.'
				info.success = false
			else
				info.message = 'Temos o prazer de informar que sua solicitação de transferência foi realizada com sucesso.'
				info.success = true
				guild:setBankBalance(guild:getBankBalance() + tonumber(count[cid]))
				player:setBankBalance(playerBalance - tonumber(count[cid]))
			end

			local inbox = player:getInbox()
			local receipt = getReceipt(info)
			inbox:addItemEx(receipt, INDEX_WHEREEVER, FLAG_NOLIMIT)
		elseif msgcontains(msg, 'no') or msgcontains(msg, 'não') or msgcontains(msg, 'nao') then
			npcHandler:say('Tudo bem. Tem mais algo que eu poderia fazer por você?', cid)
		end
		npcHandler.topic[cid] = 0
		return true
--------------------------------guild bank-----------------------------------------------
	elseif msgcontains(msg, 'deposit') then
		count[cid] = player:getMoney()
		if count[cid] < 1 then
			npcHandler:say('Você não tem nenhum dinheiro.', cid)
			npcHandler.topic[cid] = 0
			return false
		end
		if msgcontains(msg, 'all') or msgcontains(msg, 'tudo') then
			count[cid] = player:getMoney()
			npcHandler:say('Você gostaria de depositar ' .. count[cid] .. ' gold?', cid)
			npcHandler.topic[cid] = 2
			return true
		else
			if string.match(msg,'%d+') then
				count[cid] = getMoneyCount(msg)
				if count[cid] < 1 then
					npcHandler:say('Você não tem nenhum dinheiro.', cid)
					npcHandler.topic[cid] = 0
					return false
				end
				npcHandler:say('Você gostaria de depositar ' .. count[cid] .. ' gold?', cid)
				npcHandler.topic[cid] = 2
				return true
			else
				npcHandler:say('Por favor, me informe quanto você gostaria de depositar.', cid)
				npcHandler.topic[cid] = 1
				return true
			end
		end
		if not isValidMoney(count[cid]) then
			npcHandler:say('Desculpe mas você não pode depositar todo esse dinheiro.', cid)
			npcHandler.topic[cid] = 0
			return false
		end
	elseif npcHandler.topic[cid] == 1 then
		count[cid] = getMoneyCount(msg)
		if isValidMoney(count[cid]) then
			npcHandler:say('Você gostaria de depositar ' .. count[cid] .. ' gold?', cid)
			npcHandler.topic[cid] = 2
			return true
		else
			npcHandler:say('Você não tem dinheiro.', cid)
			npcHandler.topic[cid] = 0
			return true
		end
	elseif npcHandler.topic[cid] == 2 then
		if msgcontains(msg, 'yes') or msgcontains(msg, 'sim') then
			if player:depositMoney(count[cid]) then
				npcHandler:say('Tudo bem, nós adicionamos a quantidade de ' .. count[cid] .. ' gold ao seu {saldo}. You can {withdraw} your money anytime you want to.', cid)
			else
				npcHandler:say('Você não tem dinheiro.', cid)
			end
		elseif msgcontains(msg, 'no') or msgcontains(msg, 'não') or msgcontains(msg, 'nao') then
			npcHandler:say('Como quiser. Há algo mais que eu possa fazer por você?', cid)
		end
		npcHandler.topic[cid] = 0
		return true
---------------------------- withdraw --------------------
--------------------------------guild bank-----------------------------------------------
	elseif msgcontains(msg, 'guild withdraw') or msgcontains(msg, 'retirar guild') then
		if not player:getGuild() then
			npcHandler:say('Sinto muito, mas parece que você não está em nenhuma guild.', cid)
			npcHandler.topic[cid] = 0
			return false
		elseif player:getGuildLevel() < 2 then
			npcHandler:say('Somente líderes da guilda ou vice-líderes podem sacar dinheiro da conta da guild.', cid)
			npcHandler.topic[cid] = 0
			return false
		end

		if string.match(msg,'%d+') then
			count[cid] = getMoneyCount(msg)
			if isValidMoney(count[cid]) then
				npcHandler:say('Tem certeza de que deseja retirar ' .. count[cid] .. ' gold da conta da guild?', cid)
				npcHandler.topic[cid] = 25
			else
				npcHandler:say('Não há gold suficiente na sua conta da guild.', cid)
				npcHandler.topic[cid] = 0
			end
			return true
		else
			npcHandler:say('Por favor me diga quanto gold você gostaria de retirar da sua conta da guild.', cid)
			npcHandler.topic[cid] = 24
			return true
		end
	elseif npcHandler.topic[cid] == 24 then
		count[cid] = getMoneyCount(msg)
		if isValidMoney(count[cid]) then
			npcHandler:say('Tem certeza de que deseja retirar ' .. count[cid] .. ' gold da conta da sua guild?', cid)
			npcHandler.topic[cid] = 25
		else
			npcHandler:say('Não há gold suficiente na sua conta da guild.', cid)
			npcHandler.topic[cid] = 0
		end
		return true
	elseif npcHandler.topic[cid] == 25 then
		if msgcontains(msg, 'yes') or msgcontains(msg, 'sim') then
			local guild = player:getGuild()
			local balance = guild:getBankBalance()
			npcHandler:say('Fizemos um pedido para retirar ' .. count[cid] .. ' gold da sua conta da guild. Verifique sua caixa de entrada para confirmação.', cid)
			local info = {
				type = 'Guild Withdraw',
				amount = count[cid],
				owner = player:getName() .. ' of ' .. guild:getName(),
				recipient = player:getName()
			}
			if balance < tonumber(count[cid]) then
				info.message = 'Lamentamos informar que não foi possível atender sua solicitação devido à falta da quantia necessária em sua conta da guild.'
				info.success = false
			else
				info.message = 'Temos o prazer de informar que sua solicitação de transferência foi realizada com sucesso.'
				info.success = true
				guild:setBankBalance(balance - tonumber(count[cid]))
				local playerBalance = player:getBankBalance()
				player:setBankBalance(playerBalance + tonumber(count[cid]))
			end

			local inbox = player:getInbox()
			local receipt = getReceipt(info)
			inbox:addItemEx(receipt, INDEX_WHEREEVER, FLAG_NOLIMIT)
			npcHandler.topic[cid] = 0
		elseif msgcontains(msg, 'no') or msgcontains(msg, 'não') or msgcontains(msg, 'nao') then
			npcHandler:say('Como quiser. Há algo mais que eu possa fazer por você?', cid)
			npcHandler.topic[cid] = 0
		end
		return true
--------------------------------guild bank-----------------------------------------------
	elseif msgcontains(msg, 'withdraw') or msgcontains(msg, 'retira') then
		if string.match(msg,'%d+') then
			count[cid] = getMoneyCount(msg)
			if isValidMoney(count[cid]) then
				npcHandler:say('Tem certeza de que deseja retirar ' .. count[cid] .. ' gold da sua conta?', cid)
				npcHandler.topic[cid] = 7
			else
				npcHandler:say('Não há gold suficiente em sua conta.', cid)
				npcHandler.topic[cid] = 0
			end
			return true
		else
			npcHandler:say('Me diga quantos gold você gostaria de retirar.', cid)
			npcHandler.topic[cid] = 6
			return true
		end
	elseif npcHandler.topic[cid] == 6 then
		count[cid] = getMoneyCount(msg)
		if isValidMoney(count[cid]) then
			npcHandler:say('Tem certeza de que deseja retirar ' .. count[cid] .. ' gold da sua conta?', cid)
			npcHandler.topic[cid] = 7
		else
			npcHandler:say('Não há gold suficiente em sua conta.', cid)
			npcHandler.topic[cid] = 0
		end
		return true
	elseif npcHandler.topic[cid] == 7 then
		if msgcontains(msg, 'yes') or msgcontains(msg, 'sim') then
			if player:getFreeCapacity() >= getMoneyWeight(count[cid]) then
				if not player:withdrawMoney(count[cid]) then
					npcHandler:say('Não há gold suficiente em sua conta.', cid)
				else
					npcHandler:say('Aqui está, ' .. count[cid] .. ' gold. Please let me know if there is something else I can do for you.', cid)
				end
			else
				npcHandler:say('Espere, você não tem espaço em seu inventário para carregar todas essas moedas. Não quero que você o deixe cair no chão, talvez volte com um carrinho!', cid)
			end
			npcHandler.topic[cid] = 0
		elseif msgcontains(msg, 'no') or msgcontains(msg, 'nao') or msgcontains(msg, 'não') then
			npcHandler:say('O cliente é rei! Volte sempre que quiser, se desejar {retirar} ou {withdraw} seu dinheiro.', cid)
			npcHandler.topic[cid] = 0
		end
		return true
---------------------------- transfer --------------------
--------------------------------guild bank-----------------------------------------------
	elseif msgcontains(msg, 'guild transfer') or msgcontains(msg, 'guild transferir') then
		if not player:getGuild() then
			npcHandler:say('Sinto muito, mas parece que você não está atualmente em uma guild.', cid)
			npcHandler.topic[cid] = 0
			return false
		elseif player:getGuildLevel() < 2 then
			npcHandler:say('Somente líderes da guild ou vice-líderes podem transferir dinheiro da conta da guild.', cid)
			npcHandler.topic[cid] = 0
			return false
		end

		if string.match(msg, '%d+') then
			count[cid] = getMoneyCount(msg)
			if isValidMoney(count[cid]) then
				transfer[cid] = string.match(msg, 'to%s*(.+)$')
				if transfer[cid] then
					npcHandler:say('Então você gostaria de transferir ' .. count[cid] .. ' gold da conta da sua guild para a da guild ' .. transfer[cid] .. '?', cid)
					npcHandler.topic[cid] = 28
				else
					npcHandler:say('Para qual guild você gostaria de transferir ' .. count[cid] .. ' gold?', cid)
					npcHandler.topic[cid] = 27
				end
			else
				npcHandler:say('Não há gold suficiente na sua conta da guild.', cid)
				npcHandler.topic[cid] = 0
			end
		else
			npcHandler:say('Diga-me a quantidade de gold que você gostaria de transferir.', cid)
			npcHandler.topic[cid] = 26
		end
		return true
	elseif npcHandler.topic[cid] == 26 then
		count[cid] = getMoneyCount(msg)
		if player:getGuild():getBankBalance() < count[cid] then
			npcHandler:say('Não há gold suficiente na sua conta da guild.', cid)
			npcHandler.topic[cid] = 0
			return true
		end
		if isValidMoney(count[cid]) then
			npcHandler:say('Qual guild você gostaria de transferir ' .. count[cid] .. ' gold?', cid)
			npcHandler.topic[cid] = 27
		else
			npcHandler:say('Não há gold suficiente na sua conta.', cid)
			npcHandler.topic[cid] = 0
		end
		return true
	elseif npcHandler.topic[cid] == 27 then
		transfer[cid] = msg
		if player:getGuild():getName() == transfer[cid] then
			npcHandler:say('Preencha este campo com a pessoa que recebe seu gold!', cid)
			npcHandler.topic[cid] = 0
			return true
		end
		npcHandler:say('Então você gostaria de transferir ' .. count[cid] .. ' gold da sua conta da guild para a guild ' .. transfer[cid] .. '?', cid)
		npcHandler.topic[cid] = 28
		return true
	elseif npcHandler.topic[cid] == 28 then
		if msgcontains(msg, 'yes') or msgcontains(msg, 'sim') then
			npcHandler:say('Fizemos um pedido para transferir ' .. count[cid] .. ' gold da sua conta da guild para a guild ' .. transfer[cid] .. '. Verifique sua inbox para confirmação.', cid)
			local guild = player:getGuild()
			local balance = guild:getBankBalance()
			local info = {
				type = 'Guild to Guild Transfer',
				amount = count[cid],
				owner = player:getName() .. ' da ' .. guild:getName(),
				recipient = transfer[cid]
			}
			if balance < tonumber(count[cid]) then
				info.message = 'Lamentamos informar que não foi possível atender sua solicitação devido à falta da quantia necessária em sua conta da guild.'
				info.success = false
				local inbox = player:getInbox()
				local receipt = getReceipt(info)
				inbox:addItemEx(receipt, INDEX_WHEREEVER, FLAG_NOLIMIT)
			else
				getGuildIdByName(transfer[cid], transferFactory(player:getName(), tonumber(count[cid]), guild:getId(), info))
			end
			npcHandler.topic[cid] = 0
		elseif msgcontains(msg, 'no') or msgcontains(msg, 'nao') or msgcontains(msg, 'não') then
			npcHandler:say('Como quiser. Há algo mais que eu possa fazer por você?', cid)
		end
		npcHandler.topic[cid] = 0
--------------------------------guild bank-----------------------------------------------
	elseif msgcontains(msg, 'transfer') then
		npcHandler:say('Diga-me a quantidade de gold que você gostaria de transferir.', cid)
		npcHandler.topic[cid] = 11
	elseif npcHandler.topic[cid] == 11 then
		count[cid] = getMoneyCount(msg)
		if player:getBankBalance() < count[cid] then
			npcHandler:say('Não há gold suficiente em sua conta.', cid)
			npcHandler.topic[cid] = 0
			return true
		end
		if isValidMoney(count[cid]) then
			npcHandler:say('Para quem você gostaria de transferir ' .. count[cid] .. ' gold?', cid)
			npcHandler.topic[cid] = 12
		else
			npcHandler:say('Não há gold suficiente em sua conta.', cid)
			npcHandler.topic[cid] = 0
		end
	elseif npcHandler.topic[cid] == 12 then
		transfer[cid] = msg
		if player:getName() == transfer[cid] then
			npcHandler:say('Preencha este campo com a pessoa que receberá os golds!', cid)
			npcHandler.topic[cid] = 0
			return true
		end
		if playerExists(transfer[cid]) then
		local arrayDenied = {"accountmanager", "rooksample", "druidsample", "sorcerersample", "knightsample", "paladinsample"}
			if isInArray(arrayDenied, string.gsub(transfer[cid]:lower(), " ", "")) then
				npcHandler:say('Este jogador não existe.', cid)
				npcHandler.topic[cid] = 0
				return true
			end
			npcHandler:say('Você gostaria de transferir ' .. count[cid] .. ' gold para ' .. transfer[cid] .. '?', cid)
			npcHandler.topic[cid] = 13
		else
			npcHandler:say('Este jogador não existe.', cid)
			npcHandler.topic[cid] = 0
		end
	elseif npcHandler.topic[cid] == 13 then
		if msgcontains(msg, 'yes') or msgcontains(msg, 'sim') then
			if not player:transferMoneyTo(transfer[cid], count[cid]) then
				npcHandler:say("Creio que esse jogador não está apto a receber transferências.", cid)
			else
				npcHandler:say('Certo. Você transferiu ' .. count[cid] .. ' gold para ' .. transfer[cid] ..'.', cid)
				transfer[cid] = nil
			end
		elseif msgcontains(msg, 'no') or msgcontains(msg, 'nao') or msgcontains(msg, 'não') then
			npcHandler:say('Tudo bem, há algo mais que eu possa fazer por você?', cid)
		end
		npcHandler.topic[cid] = 0
---------------------------- money exchange --------------
	elseif msgcontains(msg, 'change gold') or msgcontains(msg, 'trocar gold') then
		npcHandler:say('Quantas platinum coins você gostaria de receber?', cid)
		npcHandler.topic[cid] = 14
	elseif npcHandler.topic[cid] == 14 then
		if getMoneyCount(msg) < 1 then
			npcHandler:say('Desculpe, você não tem dinheiro.', cid)
			npcHandler.topic[cid] = 0
		else
			count[cid] = getMoneyCount(msg)
			npcHandler:say('Então você gostaria que eu trocasse ' .. count[cid] * 100 .. ' de suas gold coins em ' .. count[cid] .. ' platinum coins?', cid)
			npcHandler.topic[cid] = 15
		end
	elseif npcHandler.topic[cid] == 15 then
		if msgcontains(msg, 'yes') or msgcontains(msg, 'sim') then
			if player:removeItem(2148, count[cid] * 100) then
				player:addItem(2152, count[cid])
				npcHandler:say('Aqui está.', cid)
			else
				npcHandler:say('Desculpe, você não tem dinheiro.', cid)
			end
		else
			npcHandler:say('Well, can I help you with something else?', cid)
		end
		npcHandler.topic[cid] = 0
	elseif msgcontains(msg, 'change platinum') or msgcontains(msg, 'trocar platinum') then
		npcHandler:say('Deseja trocar suas platinum coins em gold ou crystal?', cid)
		npcHandler.topic[cid] = 16
	elseif npcHandler.topic[cid] == 16 then
		if msgcontains(msg, 'gold') then
			npcHandler:say('Quantas platinum coins você gostaria de transformar em gold?', cid)
			npcHandler.topic[cid] = 17
		elseif msgcontains(msg, 'crystal') then
			npcHandler:say('Quantas crystal coins você gostaria de receber?', cid)
			npcHandler.topic[cid] = 19
		else
			npcHandler:say('Bem, posso ajudá-lo com outra coisa?', cid)
			npcHandler.topic[cid] = 0
		end
	elseif npcHandler.topic[cid] == 17 then
		if getMoneyCount(msg) < 1 then
			npcHandler:say('Desculpe, você não tem platinum coins suficientes.', cid)
			npcHandler.topic[cid] = 0
		else
			count[cid] = getMoneyCount(msg)
			npcHandler:say('Então você gostaria que eu trocasse ' .. count[cid] .. ' of your platinum coins into ' .. count[cid] * 100 .. ' gold coins for you?', cid)
			npcHandler.topic[cid] = 18
		end
	elseif npcHandler.topic[cid] == 18 then
		if msgcontains(msg, 'yes') or msgcontains(msg, 'sim') then
			if player:removeItem(2152, count[cid]) then
				player:addItem(2148, count[cid] * 100)
				npcHandler:say('Aqui está.', cid)
			else
				npcHandler:say('Desculpe, você não possui platinum coins suficientes.', cid)
			end
		else
			npcHandler:say('Bem, posso ajudá-lo com outra coisa?', cid)
		end
		npcHandler.topic[cid] = 0
	elseif npcHandler.topic[cid] == 19 then
		if getMoneyCount(msg) < 1 then
			npcHandler:say('Desculpe, você não possui platinum coins suficientes.', cid)
			npcHandler.topic[cid] = 0
		else
			count[cid] = getMoneyCount(msg)
			npcHandler:say('Então você gostaria que eu trocasse ' .. count[cid] * 100 .. ' de suas moedas de platinum em ' .. count[cid] .. ' crystal coins para você?', cid)
			npcHandler.topic[cid] = 20
		end
	elseif npcHandler.topic[cid] == 20 then
		if msgcontains(msg, 'yes') or msgcontains(msg, 'sim') then
			if player:removeItem(2152, count[cid] * 100) then
				player:addItem(2160, count[cid])
				npcHandler:say('Aqui está.', cid)
			else
				npcHandler:say('Desculpe, você não possui platinum coins suficientes.', cid)
			end
		else
			npcHandler:say('Bem, posso ajudá-lo com outra coisa?', cid)
		end
		npcHandler.topic[cid] = 0
	elseif msgcontains(msg, 'change crystal') or msgcontains(msg, 'trocar crystal') then
		npcHandler:say('Quantas crystal coins você gostaria de transformar em platinum coins?', cid)
		npcHandler.topic[cid] = 21
	elseif npcHandler.topic[cid] == 21 then
		if getMoneyCount(msg) < 1 then
			npcHandler:say('Desculpe, você não possui crystal coins suficientes.', cid)
			npcHandler.topic[cid] = 0
		else
			count[cid] = getMoneyCount(msg)
			npcHandler:say('Ok, você quer que eu troque ' .. count[cid] .. ' de suas crystal coins em ' .. count[cid] * 100 .. ' platinum coins para você?', cid)
			npcHandler.topic[cid] = 22
		end
	elseif npcHandler.topic[cid] == 22 then
		if msgcontains(msg, 'yes') or msgcontains(msg, 'sim') then
			if player:removeItem(2160, count[cid])  then
				player:addItem(2152, count[cid] * 100)
				npcHandler:say('Aqui está.', cid)
			else
				npcHandler:say('Desculpe, você não possui crystal coins suficientes.', cid)
			end
		else
			npcHandler:say('Certo, posso te ajudar com alguma outra coisa?', cid)
		end
		npcHandler.topic[cid] = 0
	end
	return true
end

keywordHandler:addKeyword({'money'}, StdModule.say, {npcHandler = npcHandler, text = 'Nós podemos {change} ou {trocar} dinheiro para você. Você também consegue ter acesso à sua {bank account}.'})
keywordHandler:addKeyword({'change'}, StdModule.say, {npcHandler = npcHandler, text = 'Existem três tipos diferentes de moedas no banco: 100 gold coins em 1 platinum coin, 100 platinum coins em 1 crystal coin. Portanto, se você quiser trocar 100 de gold em 1 platinum, basta dizer {change gold} ou {trocar gold} e depois 1 platinum.'})
keywordHandler:addKeyword({'bank'}, StdModule.say, {npcHandler = npcHandler, text = 'Nós podemos {change} ou {trocar} dinheiro para você. Você também consegue ter acesso à sua {bank account}.'})
keywordHandler:addKeyword({'help'}, StdModule.say, {npcHandler = npcHandler, text = 'Você pode verificar o {balance} ou {saldo} da sua conta, {deposit} ou {depositar} dinheiro ou {withdraw} ou {retirar}. Você também pode {transfer} ou {transferir} dinheiro para outros personagens.'})
keywordHandler:addKeyword({'functions'}, StdModule.say, {npcHandler = npcHandler, text = 'Você pode verificar o {balance} ou {saldo} da sua conta, {deposit} ou {depositar} dinheiro ou {withdraw} ou {retirar}. Você também pode {transfer} ou {transferir} dinheiro para outros personagens.'})
keywordHandler:addKeyword({'basic'}, StdModule.say, {npcHandler = npcHandler, text = 'Eu posso checar o seu {balance} ou {saldo} da sua conta, {deposit} ou depositar dinheiro ou {withdraw} ou {retirar}. Você também pode {transfer} ou {transferir} dinheiro para outros personagens.'})
keywordHandler:addKeyword({'job'}, StdModule.say, {npcHandler = npcHandler, text = 'Eu trabalho nesse banco. Eu posso trocar golds e te ajudar em funções na sua conta.'})

npcHandler:setMessage(MESSAGE_GREET, "Sim? O que eu posso fazer por você, |PLAYERNAME|? Alguma transação de banco?")
npcHandler:setMessage(MESSAGE_FAREWELL, "Tenha um ótimo dia.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Tenha um ótimo dia.")
npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())