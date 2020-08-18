MONSTER_HUNT = {
	list = {"Demon", "Rotworm", "Cyclops"},
	days = {
		["Sunday"] = {"13:55"},
		["Monday"] = {"13:55"},
		["Tuesday"] = {"13:55"},
		["Wednesday"] = {"13:55"},
		["Thursday"] = {"13:55"},
		["Friday"] = {"13:55"},
		["Saturday"] = {"13:55"},
	},
	messages = {
		prefix = "[Monster Hunt] ",
		warnInit = "O evento irá começar em %d minuto%s. Seu objetivo será matar a maior quantidade de monstros escolhidos pelo sistema.",
		init = "O monstro escolhido pelo sistema foi %s. Você tem 1 hora para matar a maior quantidade desse monstro.",
		warnEnd = "Faltam %d minuto%s para acabar o evento. Se apressem!",
		final = "O jogador %s foi o ganhador do evento! Parabéns.",
		reward = "Você recebeu o seu prêmio no mailbox!"
		kill = "Você já matou %d do evento.",
	},
	rewards = {
		{id = 2160, count = 100},
	},
	storages = {
		monster = 891641,
		player = 891642,
	},
	players = {},
}

function MONSTER_HUNT:initEvent()
	Game.setStorageValue(MONSTER_HUNT.storages.monster, 0)
	Game.broadcastMessage(MONSTER_HUNT.messages.prefix .. MONSTER_HUNT.messages.warnInit:format(5, "s"))
	addEvent(function()
		Game.broadcastMessage(MONSTER_HUNT.messages.prefix .. MONSTER_HUNT.messages.warnInit:format(3, "s"))
	end, 2 * 60 * 1000)
	addEvent(function()
		Game.broadcastMessage(MONSTER_HUNT.messages.prefix .. MONSTER_HUNT.messages.warnInit:format(1, ""))
	end, 4 * 60 * 1000)
	addEvent(function()
		local rand = math.random(#MONSTER_HUNT.list)
		Game.setStorageValue(MONSTER_HUNT.storages.monster, rand)
		Game.broadcastMessage(MONSTER_HUNT.messages.prefix .. MONSTER_HUNT.messages.init:format(MONSTER_HUNT.list[rand]))
	end, 5 * 60 * 1000)
	return true
end

function MONSTER_HUNT:endEvent()
	Game.broadcastMessage(MONSTER_HUNT.messages.prefix .. MONSTER_HUNT.messages.warnEnd:format(5, "s"))
	addEvent(function()
		Game.broadcastMessage(MONSTER_HUNT.messages.prefix .. MONSTER_HUNT.messages.warnEnd:format(3, "s"))
	end, 2 * 60 * 1000)
	addEvent(function()
		Game.broadcastMessage(MONSTER_HUNT.messages.prefix .. MONSTER_HUNT.messages.warnEnd:format(1, ""))
	end, 4 * 60 * 1000)
	addEvent(function()
		for a, b in spairs(MONSTER_HUNT.players, function(t,a,b) return t[b] < t[a] end) do
			local player = Player(a[1])
			if player then
				Game.broadcastMessage(MONSTER_HUNT.messages.prefix .. MONSTER_HUNT.messages.final:format(player:getName())
				player:setStorageValue(MONSTER_HUNT.storages.player, -1)
				for c, d in ipairs(MONSTER_HUNT.rewards) do
					local item = Game.createItem(d.id, d.count)
					player:getInbox():addItemEx(item, INDEX_WHEREEVER, FLAG_NOLIMIT)
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, MONSTER_HUNT.messages.prefix .. MONSTER_HUNT.messages.reward)
					player:getPosition():sendMagicEffect(30)
				end
			else
				local player = Player(a, true)

				if not player then
					return false
				end

				Game.broadcastMessage(MONSTER_HUNT.messages.prefix .. MONSTER_HUNT.messages.final:format(player:getName())
				player:setStorageValue(MONSTER_HUNT.storages.player, -1)
				for c, d in ipairs(MONSTER_HUNT.rewards) do
					local item = Game.createItem(d.id, d.count)
					player:getInbox():addItemEx(item, INDEX_WHEREEVER, FLAG_NOLIMIT)
				end
				player:delete()
			end
		end
		for a in ipairs(MONSTER_HUNT.players) do
			local player = Player(a, true)
			if not player then
				return false
			end
			player:setStorageValue(MONSTER_HUNT.storages.player, -1)
			MONSTER_HUNT.players[a] = nil
			player:delete()
		end
		Game.setStorageValue(MONSTER_HUNT.storages.monster, -1)
	end, 5 * 60 * 1000)
	return true
end

function spairs(t, order)
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end