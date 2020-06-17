local rank = TalkAction("!rank")

local top = 10
local rankcolor = MESSAGE_STATUS_CONSOLE_ORANGE
local errorcolor = MESSAGE_STATUS_CONSOLE_BLUE
local popup = true -- set to false if you want it in local chat
local exhaustvalue = 78692 -- storage to avoid command spam
local exhausttime = 3 -- seconds before you may request rank again
local maxgroup = 1 -- set to 2 to include gms, 3 to include gods

local ranks = {
    ['level'] = 1,
    ['lvl'] = 1,
    ['exp'] = 1,
    ['xp'] = 1,
    ['magic'] = 2,
    ['ml'] = 2,
    ['bank'] = 3,
    ['balance'] = 3,
    ['cash'] = 3,
    ['money'] = 3,
    ['gp'] = 3,
    ['fist'] = 4,
    ['club'] = 5,
    ['sword'] = 6,
    ['axe'] = 7,
    ['distance'] = 8,
    ['dist'] = 8,
    ['shielding'] = 9,
    ['shield'] = 9,
    ['fishing'] = 10,
    ['fish'] = 10,
    ['frags'] = 11
}

local voc = {
    ['none'] = 0,
    ['sorcerer'] = {1, 5, 9},
    ['ms'] = {1, 5, 9},
    ['masterful'] = {1, 5, 9},
    ['druid'] = {2, 6, 10},
    ['ed'] = {2, 6, 10},
    ['ancient'] = {2, 6, 10},
    ['paladin'] = {3, 7, 11},
    ['rp'] = {3, 7, 11},
    ['glorious'] = {3, 7, 11},
    ['knight'] = {4, 8, 12},
    ['ek'] = {4, 8, 12},
    ['rageful'] = {4, 8, 12}
}

local stats = {
-- {"order by this", "show this first"}
    [1] = {"experience", "level"},
    [2] = {"manaspent", "maglevel"},
    [3] = {"balance"},
    [4] = {"skill_fist"},
    [5] = {"skill_club"},
    [6] = {"skill_sword"},
    [7] = {"skill_axe"},
    [8] = {"skill_dist"},
    [9] = {"skill_shielding"},
    [10] = {"skill_fishing"}
}

local stats_names = {
    [1] = {"exp", "level"},
    [2] = {"mana spent", "magic level"},
    [3] = {"account balance"},
    [4] = {"fist fighting"},
    [5] = {"club fighting"},
    [6] = {"sword fighting"},
    [7] = {"axe fighting"},
    [8] = {"distance fighting"},
    [9] = {"shielding"},
    [10] = {"fishing"},
    [11] = {"frags"}
}

local stats_short = {
    [1] = {"xp: ", ""},
    [2] = {"mana: ", ""},
    [3] = {""},
    [4] = {""},
    [5] = {""},
    [6] = {""},
    [7] = {""},
    [8] = {""},
    [9] = {""},
    [10] = {""},
    [11] = {""}
}

function table.find(table, value)
   for i, v in pairs(table) do
     if v == value then
       return i
     end
   end
   return nil
end

function getHighest(check, values)
   local highest = 0
   local highestVal = nil
   local highestI = nil
   for i = 1, #values do
     if check[values[i]] > highest then
       highest = check[values[i]]
       highestVal = values[i]
       highestI = i
     end
   end
   
   return {highest, highestVal, highestI}
end

function getTopFraggers(vocs)
    local fraggers = {}
    local resultId = db.storeQuery("SELECT `player_id`, `killed_by` FROM `player_deaths` WHERE `is_player` = 1")
    if resultId then
        repeat
            table.insert(fraggers, result.getDataString(resultId, "killed_by"))       
        until not result.next(resultId)
        result.free(resultId)
    end

    local fraggers_names = {}
    for i = 1, #fraggers do
        if not table.find(fraggers_names, fraggers[i]) then
            table.insert(fraggers_names, fraggers[i])
        end
    end

    local fraggers_total = {}
    for i = 1, #fraggers do
        for j = 1, #fraggers_names do
            if fraggers_names[j] == fraggers[i] then
            if not fraggers_total[fraggers_names[j]] then fraggers_total[fraggers_names[j]] = 0 end
                fraggers_total[fraggers_names[j]] = fraggers_total[fraggers_names[j]] + 1
            end
        end   
    end

    local place = 0
    local fraggers_top = {}
    repeat
        local v = getHighest(fraggers_total, fraggers_names)
        if not v[2] then
            break
        end
        
        if vocs then
            local resultId = db.storeQuery("SELECT `vocation` FROM `players` WHERE `name` = '" .. v[2] .. "' LIMIT 1")
            if isInArray(vocs, result.getDataInt(resultId, "vocation")) then
                place = place + 1
                table.insert(fraggers_top, {v[1], v[2]})
            end
        else
            place = place + 1
            table.insert(fraggers_top, {v[1], v[2]})
        end
        table.remove(fraggers_names, v[3])
    until (place == top) or (not v[3])
    
    local msg = ""
    for i = 1, #fraggers_top do
        if fraggers_top[i][2] then
            msg = msg .. "\n[" .. i .. "] [" .. fraggers_top[i][2] .. "] [" .. fraggers_top[i][1] .. "]"
        else
            break
        end
    end
return msg
end

function rank.onSay(player, words, param)
    if player:getStorageValue(exhaustvalue) >= os.time() then
        player:sendTextMessage(errorcolor, "Aguarde alguns segundos.")
        return false
    end

    player:setStorageValue(exhaustvalue, os.time() + exhausttime)

    local split = param:split(",")
    if #split == 0 then
        local ranks2 = {}
        for i = 1, #stats_names do
            table.insert(ranks2, stats_names[i][#stats_names[i]])
        end
        player:popupFYI("Exemplo: " .. words .. " balance, knight (opcional)\n\nRanks Disponíveis:\n\n" .. table.concat(ranks2, "\n"))
        return false
    end

    for i = 1, #split do
        split[i] = split[i]:gsub("^%s*(.-)%s*$", "%1")
    end
    
    if ranks[split[1]] then
        local msg = "Top jogadores, " .. stats_names[ranks[split[1]]][#stats_names[ranks[split[1]]]] .. (voc[split[2]] and (", " .. split[2]) or "") .. ":"
        
        if ranks[split[1]] == 11 then
            if popup then
                player:popupFYI(msg .. getTopFraggers(voc[split[2]]))
            else
                player:sendTextMessage(rankcolor, msg .. getTopFraggers(voc[split[2]]))
            end
            return false
        else
            local resultId = db.storeQuery("SELECT `name`, `" .. table.concat(stats[ranks[split[1]]], "`, `") .. "` FROM `players` WHERE `group_id` <= " .. maxgroup .. (voc[split[2]] and (" AND `vocation` IN (" .. table.concat(voc[split[2]], ",") .. ")") or "") .. " ORDER BY `" .. stats[ranks[split[1]]][#stats[ranks[split[1]]]] .. "` DESC LIMIT " .. top)
            local place = 0
            repeat
                place = place + 1
                msg = msg .. "\n[" .. place .. "] [" .. result.getDataString(resultId, "name") .. "] "
                
                for i = 1, #stats[ranks[split[1]]] do
                    local s = #stats[ranks[split[1]]] + 1 - i
                    msg = msg .. "[" .. stats_short[ranks[split[1]]][s] .. result.getDataInt(resultId, stats[ranks[split[1]]][s]) .. "]" .. (s > 1 and " " or "")
                end
            until not result.next(resultId)
            result.free(resultId)
            if popup then
                player:popupFYI(msg)
            else
                player:sendTextMessage(rankcolor, msg)
            end
        end
        return false
    end
    
    player:sendTextMessage(errorcolor, "Nome da lista incorreto. Execute o comando sem parâmetros para ver as listas disponíveis.")
    return false
end

rank:separator(" ")
rank:register()
