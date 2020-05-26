task_monsters = {
   [1] = {name = "Demon", mons_list = {""},  storage = 30000, amount = 6666, exp = 50000, pointsTask = {20, 1}, items = {{id = 2157, count = 1}, {id = 2160, count = 3}}},
   [2] = {name = "Rotworm", mons_list = {"Carrion Worm", "Rotworm Queen"}, storage = 30001, amount = 200, exp = 5000, pointsTask = {1, 1}, items = {{id = 10521, count = 1}, {id = 2160, count = 5}}},
   [3] = {name = "monster3", mons_list = {"", ""}, storage = 30002, amount = 10, exp = 18000, pointsTask = {1, 1}, items = {{id = 2195, count = 1}, {id = 2160, count = 8}}},
   [4] = {name = "monster4", mons_list = {"", ""}, storage = 30003, amount = 10, exp = 20000, pointsTask = {1, 1}, items = {{id = 2520, count = 1}, {id = 2160, count = 10}}}
}

task_daily = {
   [1] = {name = "monsterDay1", mons_list = {"monsterDay1_t2", "monsterDay1_t3"}, storage = 40000, amount = 10, exp = 5000, pointsTask = {1, 1}, items = {{id = 2157, count = 1}, {id = 2160, count = 3}}},
   [2] = {name = "monsterDay2", mons_list = {"", ""}, storage = 40001, amount = 10, exp = 10000, pointsTask = {1, 1}, items = {{id = 10521, count = 1}, {id = 2160, count = 5}}},
   [3] = {name = "monsterDay3", mons_list = {"", ""}, storage = 40002, amount = 10, exp = 18000, pointsTask = {1, 1}, items = {{id = 2195, count = 1}, {id = 2160, count = 8}}},
   [4] = {name = "monsterDay4", mons_list = {"", ""}, storage = 40003, amount = 10, exp = 20000, pointsTask = {1, 1}, items = {{id = 2520, count = 1}, {id = 2160, count = 10}}}
}

task_storage = 20020 -- storage que verifica se está fazendo alguma task e ver qual task é - task normal
task_points = 20021 -- storage que retorna a quantidade de pontos task que o player tem.
task_sto_time = 20022 -- storage de delay para não poder fazer a task novamente caso ela for abandonada.
task_time = 20 -- tempo em horas em que o player ficará sem fazer a task como punição
task_rank = 20023 -- storage do rank task
taskd_storage = 20024 -- storage que verifica se está fazendo alguma task e ver qual task é - task daily
time_daySto = 20025 -- storage do tempo da task daily, no caso para verificar e add 24 horas para fazer novamente a task daily


local ranks_task = {
	[{1, 50}] = "Novato", 
	[{51, 100}] = "Elite",
	[{101, 150}] = "Master",
	[{151, 200}] = "Destroyer",		
	[{201, math.huge}] = "Juggernaut"
}

local RankSequence = {
	["Novato"] = 1,
	["Elite"] = 2,
	["Master"] = 3,
	["Destroyer"] = 4,
	["Juggernaut"] = 5,
}

function rankIsEqualOrHigher(myRank, RankCheck)
	local ret_1 = RankSequence[myRank]
	local ret_2 = RankSequence[RankCheck]
	return ret_1 >= ret_2
end

function getTaskInfos(player)
	local player = Player(player)
	return task_monsters[player:getStorageValue(task_storage)] or false
end

function getTaskDailyInfo(player)
	local player = Player(player)
	return task_daily[player:getStorageValue(taskd_storage)] or false
end


function taskPoints_get(player)
	local player = Player(player)
	if player:getStorageValue(task_points) == -1 then
		return 0 
	end
	return player:getStorageValue(task_points)
end

function taskPoints_add(player, count)
	local player = Player(player)
	return player:setStorageValue(task_points, taskPoints_get(player) + count)
end

function taskPoints_remove(player, count)
	local player = Player(player)
	return player:setStorageValue(task_points, taskPoints_get(player) - count)
end

function taskRank_get(player)
	local player = Player(player)
	if player:getStorageValue(task_rank) == -1 then
		return 1 
	end
	return player:getStorageValue(task_rank)
end

function taskRank_add(player, count)
	local player = Player(player)
	return player:setStorageValue(task_rank, taskRank_get(player) + count)
end

function getRankTask(player)
	local pontos = taskRank_get(player)
	local ret
	for _, z in pairs(ranks_task) do
		if pontos >= _[1] and pontos <= _[2] then
			ret = z
		end
	end
	return ret
end

function getItemsFromTable(itemtable)
     local text = ""
     for v = 1, #itemtable do
         count, info = itemtable[v].count, ItemType(itemtable[v].id)
         local ret = ", "
         if v == 1 then
             ret = ""
         elseif v == #itemtable then
             ret = " - "
         end
         text = text .. ret
         text = text .. (count > 1 and count or info:getArticle()).." "..(count > 1 and info:getPluralName() or info:getName())
     end
     return text
end