local modalConfig = {
	[1] = {id = 1, name = 'Loki', time = 120, amount = 1, itemId = 6523, area = {fromPosition = Position(2434, 2202, 7), toPosition = Position(2541, 2262, 7), entrace = Position(2490, 2215, 7), centerPosition = Position(2489, 2234, 7), rangeX = 49, rangeY = 34}},
	[2] = {id = 2, name = 'Loki', time = 120, amount = 1, itemId = 6523, area = {fromPosition = Position(2504, 2119, 7), toPosition = Position(2577, 2199, 7), entrace = Position(2551, 2191, 7), centerPosition = Position(2543, 2161, 7), rangeX = 37, rangeY = 38}},
	[3] = {id = 3, name = 'Loki', time = 120, amount = 1, itemId = 6523, area = {fromPosition = Position(2606, 2125, 7), toPosition = Position(2704, 2272, 7), entrace = Position(2619, 2129, 7), centerPosition = Position(2654, 2205, 7), rangeX = 47, rangeY = 80}},
	[4] = {id = 4, name = 'Loki', time = 120, amount = 1, itemId = 6523, area = {fromPosition = Position(2737, 2145, 7), toPosition = Position(2811, 2214, 7), entrace = Position(2793, 2150, 7), centerPosition = Position(2775, 2177, 7), rangeX = 40, rangeY = 37}},
	[5] = {id = 5, name = 'Loki', time = 120, amount = 1, itemId = 6523, area = {fromPosition = Position(2819, 2142, 7), toPosition = Position(2888, 2229, 7), entrace = Position(2824, 2191, 7), centerPosition = Position(2851, 2191, 7), rangeX = 38, rangeY = 50}},
	[6] = {id = 6, name = 'Loki', time = 120, amount = 1, itemId = 6523, area = {fromPosition = Position(2446, 2383, 7), toPosition = Position(2557, 2440, 7), entrace = Position(2505, 2394, 7), centerPosition = Position(2504, 2413, 7), rangeX = 49, rangeY = 34}},
	[7] = {id = 7, name = 'Loki', time = 120, amount = 1, itemId = 6523, area = {fromPosition = Position(2523, 2303, 7), toPosition = Position(2594, 2375, 7), entrace = Position(2566, 2370, 7), centerPosition = Position(2558, 2340, 7), rangeX = 37, rangeY = 38}},
	[8] = {id = 8, name = 'Loki', time = 120, amount = 1, itemId = 6523, area = {fromPosition = Position(2621, 2304, 7), toPosition = Position(2720, 2450, 7), entrace = Position(2634, 2308, 7), centerPosition = Position(2669, 2384, 7), rangeX = 47, rangeY = 80}},
	[9] = {id = 9, name = 'Loki', time = 120, amount = 1, itemId = 6523, area = {fromPosition = Position(2754, 2325, 7), toPosition = Position(2826, 2392, 7), entrace = Position(2808, 2329, 7), centerPosition = Position(2790, 2356, 7), rangeX = 40, rangeY = 37}},
	[10] = {id = 10, name = 'Loki', time = 120, amount = 1, itemId = 6523, area = {fromPosition = Position(2834, 2319, 7), toPosition = Position(2904, 2408, 7), entrace = Position(2839, 2370, 7), centerPosition = Position(2866, 2370, 7), rangeX = 38, rangeY = 50}},
}

--[[
CREATE TABLE `exclusive_hunts` (
  `hunt_id` int(2) NOT NULL,
  `bought_by` VARCHAR(32) NOT NULL,
  `hunting` VARCHAR(32) NOT NULL,
  `time` int(11) NOT NULL,
  `to_time` int(11) NOT NULL,
  `active` int(1) NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1
]]

if not ExclusiveHunts then
	ExclusiveHunts = {}
end

function mTOh(mins)
    return math.floor(mins/60), (mins%60)
end

function ExclusiveHunts.areaEmpty(self, id)
	local resultId = db.storeQuery(string.format('SELECT * FROM `exclusive_hunts` WHERE `hunt_id` = %d AND `active` = 1', id))
	if not resultId then
		return true
	end

	result.free(resultId)
	return false
end

function ExclusiveHunts.sendModalWindow(self, cid)
	local player = Player(cid)
	if not player then
		return false
	end

	local getHunt = self:getHunt(cid)
	if getHunt then
		player:sendTextMessage(MESSAGE_INFO_DESCR, string.format('Voc� ainda possui uma Hunt de %s por %s. Espere ela acabar para voc� obter outra.', getHunt.hunting, showTimeLeft((getHunt.toTime) - os.time(), true)))
		return false
	end

	local storage = Storage.exclusiveHunts
    if not player:useDailyItem(storage, 3) then
    	player:sendTextMessage(MESSAGE_INFO_DESCR, 'Voc� j� entrou dentro da Exclusive Hunt tr�s vezes hoje.')
    	return false
    end

    if player:getStorageValue(9483384) >= os.time() then
    	player:sendTextMessage(MESSAGE_INFO_DESCR, string.format('Voc� precisa aguentar %s antes de alugar uma Exclusive Hunt novamente.', showTimeLeft(player:getStorageValue(9483384) - os.time(), true)))
    	return true
    end

	local window = ModalWindow {
		title = "Exclusive Hunts",
		message = "Escolha uma Exclusive Hunt na qual voc� gostaria de ter acesso",
	}

	local count = 0
	for v, k in ipairs(modalConfig) do
		if self:areaEmpty(k.id) then
			local name = string.format("[Monstro: %s] - Hunt por %s horas", k.name, mTOh(k.time))
			local choice = window:addChoice(name)

	        choice.huntId = k.id
	        choice.monsterName = k.name
	        choice.time = k.time
	        count = count + 1
	    end
	end

	if count == 0 then
	    player:sendTextMessage(MESSAGE_INFO_DESCR, 'Todas as Exclusive Hunts est�o ocupadas no momento.')
	    return false
	end

	window:addButton("Entrar",
		function(button, choice)
			self:payTheEntrace(cid, choice.huntId, choice.monsterName, choice.time)
		end
	)
	window:setDefaultEnterButton("Entrar")

	window:addButton("Sair")
	window:setDefaultEscapeButton("Sair")
	window:sendToPlayer(player)
	return true
end

function ExclusiveHunts.playersHasHunt(self, cid)
	local player = Player(cid)
	if not player then
		return false
	end

	local resultId = db.storeQuery(string.format('SELECT * FROM `exclusive_hunts` WHERE `active` = 1 AND `bought_by` = %s', db.escapeString(player:getName())))
	if resultId then
		result.free(resultId)
		return true
	end

	return false
end

function ExclusiveHunts.getHunt(self, cid)
	local player = Player(cid)
	if not player then
		return false
	end

	local resultId = db.storeQuery(string.format('SELECT * FROM `exclusive_hunts` WHERE `active` = 1 AND `bought_by` = %s', db.escapeString(player:getName())))
	if not resultId then
		return false
	end

	local id = result.getDataInt(resultId, "hunt_id")
	local bought = result.getDataString(resultId, "bought_by")
	local time = result.getDataInt(resultId, "time")
	local to_time = result.getDataInt(resultId, "to_time")
    local active = result.getDataInt(resultId, "active")
    local hunting = result.getDataString(resultId, "hunting")
    result.free(resultId)

    return {id = id, bought = bought, time = time, toTime = to_time, active = active, hunting = hunting}
end

function ExclusiveHunts.removeArea(self, name, id)
	local tmpHunt = modalConfig[id]
	if not tmpHunt then
		return true
	end

	local tmpPlayer = Player(name)
	if not tmpPlayer then
		return true
	end

	local getHunt = self:getHunt(tmpPlayer:getId())
	if not getHunt or type(getHunt) ~= 'table' then
		return true 
	end

	if isInRange(tmpPlayer:getPosition(), tmpHunt.area.fromPosition, tmpHunt.area.toPosition) then
		tmpPlayer:teleportTo(tmpPlayer:getTown():getTemplePosition())
		tmpPlayer:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	end

	local spectators, spectator = Game.getSpectators(tmpHunt.area.centerPosition, false, false, tmpHunt.area.rangeX, tmpHunt.area.rangeX, tmpHunt.area.rangeY, tmpHunt.area.rangeY)
	for i = 1, #spectators do
		spectator = spectators[i]
		if spectator:isMonster() then
			if CreatureSpawn and StoreSpawn then
				local creatureId = spectator:getId()
			    local spawnId = CreatureSpawn[creatureId]
			    Game.removeSpawn(spawnId)
			end
		end
	end

	tmpPlayer:setStorageValue(9483384, os.time() + 10 * 60)
	tmpPlayer:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format('A sua Hunt exclusiva de %s acabou!', getHunt.hunting))
	db.query(string.format('DELETE FROM `exclusive_hunts` WHERE `bought_by` = %s AND (`active` = 1 AND `hunt_id` = %d)', db.escapeString(tmpPlayer:getName()), id))
	return true
end

function ExclusiveHunts.payTheEntrace(self, cid, id, monsterName, time)
	local player = Player(cid)
	if not player then
		return false
	end

	local tmpHunt = modalConfig[id]
	if not tmpHunt then
		return false
	end

	if not self:areaEmpty(id) then
		player:sendTextMessage(MESSAGE_INFO_DESCR, 'Essa �rea j� est� ocupada.')
		return false
	end

	if player:getItemCount(tmpHunt.itemId) < tmpHunt.amount then
		player:sendTextMessage(MESSAGE_INFO_DESCR, string.format('Voc� n�o tem %d %s', tmpHunt.amount, ItemType(tmpHunt.itemId):getName()))
		return false
	end
	
	if not player:removeItem(tmpHunt.itemId, tmpHunt.amount) then
		player:sendTextMessage(MESSAGE_INFO_DESCR, string.format('Voc� n�o tem %d %s', tmpHunt.amount, ItemType(tmpHunt.itemId):getName()))
		return false
	end

	player:useDailyItem(Storage.exclusiveHunts)
	db.query(string.format('INSERT INTO `exclusive_hunts` (`hunt_id`, `bought_by`, `hunting`, `time`, `to_time`, `active`) VALUES (%d, %s, %s, %d, %d, %d)', id, db.escapeString(player:getName()), db.escapeString(monsterName), os.time(), os.time() + time * 60, 1))
	self:sendPlayerToHunt(cid, id)
end

function ExclusiveHunts.sendPlayerToHunt(self, cid, id)
	local player = Player(cid)
	if not player then
		return false
	end

	local getHunt = self:getHunt(cid)
	if not getHunt or type(getHunt) ~= 'table' then
		player:sendTextMessage(MESSAGE_INFO_DESCR, 'Voc� n�o possui nenhuma Exclusive Hunt no momento.')
		return false 
	end

	local tmpHunt = modalConfig[id]
	if not tmpHunt then
		return false
	end

	local spectators, spectator = Game.getSpectators(tmpHunt.area.centerPosition, false, false, tmpHunt.area.rangeX, tmpHunt.area.rangeX, tmpHunt.area.rangeY, tmpHunt.area.rangeY)
	for i = 1, #spectators do
		local spectator = spectators[i]
		if spectator:isMonster() then
			if CreatureSpawn and StoreSpawn then
				local creatureId = spectator:getId()
			    local spawnId = CreatureSpawn[creatureId]
			    Game.removeSpawn(spawnId)
			end
		end
	end

	local randomMonsters = math.random(50, 100)
	local count = 0
	while count < randomMonsters do
		Game.createSpawn(tmpHunt.name, 2 * 60 * 1000, getRandomSpawnPosition(tmpHunt.area.fromPosition, tmpHunt.area.toPosition))
		count = count + 1
	end

	local tmpHunt = modalConfig[id]
	if tmpHunt then
		player:teleportTo(tmpHunt.area.entrace)
		player:sendTextMessage(MESSAGE_INFO_DESCR, string.format('Voc� foi teletransportado para a sua hunt exclusiva de %s. Voc� ainda tem %s de acesso a essa �rea.', getHunt.hunting, showTimeLeft((getHunt.toTime) - os.time(), true)))
	end

	return true
end