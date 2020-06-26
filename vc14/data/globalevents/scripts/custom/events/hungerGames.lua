currentgameid = 201
killstreak = 60013
depotbox= {x = 422, y = 196, z = 7} --location of a depot box, recommended to be accessible by players incase of bugs or crashes
game = {{name="Hunger Games Arena", cheststartid=60100, minplayers=8, maxplayers=16, chests=299, startpos={
    {x = 1548, y = 1371, z = 7},
    {x = 1545, y = 1372, z = 7},
    {x = 1543, y = 1373, z = 7},
    {x = 1542, y = 1375, z = 7},
    {x = 1541, y = 1378, z = 7},
    {x = 1542, y = 1381, z = 7},
    {x = 1543, y = 1383, z = 7},
    {x = 1545, y = 1384, z = 7},
    {x = 1548, y = 1385, z = 7},
    {x = 1551, y = 1384, z = 7},
    {x = 1553, y = 1383, z = 7},
    {x = 1554, y = 1381, z = 7},
    {x = 1555, y = 1378, z = 7},
    {x = 1554, y = 1375, z = 7},
    {x = 1553, y = 1373, z = 7},
    {x = 1551, y = 1372, z = 7}
    }
    }
    }

    availablearenas = {1} -- script starts with all arenas as "available"
    gameplayers = {}
    prize = {{2160,1},{5097,10},{2128,1}}

function Player:removeAllItems() -- function to clear the player's inventory
    local depotpos = Tile(Position(depotbox.x, depotbox.y, depotbox.z)):getItemByType(ITEM_TYPE_DEPOT)
    local depotid = getDepotId(depotpos:getUniqueId())
    local depot = self:getDepotChest(depotid,true)
    local box = depot:addItem(1988)
    box:setAttribute(ITEM_ATTRIBUTE_NAME,"player gear box")
    for i=1,10 do
        local item = self:getSlotItem(i)
        if item then
            item:moveTo(box)
        end
    end
end

function Player:getBackItems() -- function to clear the player's inventory
    local depotpos = Tile(Position(depotbox.x, depotbox.y, depotbox.z)):getItemByType(ITEM_TYPE_DEPOT)
    local depotid = getDepotId(depotpos:getUniqueId())
    local depot = self:getDepotChest(depotid,true)
    local box = depot:getItem(0)
    for i= box:getSize()-1, 0, -1 do
        local item = box:getItem(i)
        if item then
            item:moveTo(self)
        end
    end
    --box:remove()
end

local function teleportThing(seconds)
    if seconds <= 0 and #queue >= 1 then
    local looparenas = availablearenas -- preventing possible conflicts with looping
        for a,b in pairs(looparenas) do
            if #queue >= game[looparenas[a]].minplayers then
                local p = 1
                while p < game[looparenas[a]].maxplayers do
                    for i, pname in pairs(queue) do
                        local player = Player(pname)
                        if player then
                            player:setStorageValue(currentgameid, looparenas[a])
                            local pos = Position(game[looparenas[a]].startpos[p].x, game[looparenas[a]].startpos[p].y, game[looparenas[a]].startpos[p].z)
                            player:teleportTo(pos)
                            player:removeAllItems()
                            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Welcome to The Hunger Games, Your objective is to loot, kill and be the last man standing, Good luck!")
                            if gameplayers[looparenas[a]] == nil then
                                gameplayers[looparenas[a]] = {}
                            end
                            table.insert(gameplayers[looparenas[a]], player:getName())
                            table.remove(queue,i)
                        end
                    end
                    p = p+1
                end
                for i = game[looparenas[a]].cheststartid, game[looparenas[a]].cheststartid+game[looparenas[a]].chests do
                    Game.setStorageValue(i, -1)
                end
                Game.broadcastMessage(MESSAGE_EVENT_ADVANCE,"Hunger Games started in " ..game[looparenas[a]].name.."!")
                for k,v in pairs(availablearenas) do
                    if v == r then
                        table.remove(availablearenas,i)
                    end
                end
            else
                for _, player in pairs(queue) do
                    Player(player):sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Sorry, There is not enough players to start "..game[availablearenas[a]].name)
                end
            end
        end
    return true
    end
    if seconds == 60 then
        for _, player in pairs(queue) do
            Player(player):sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "The Hunger Games will begin in " .. seconds/60 .. " minute, Get Ready!")
        end
    elseif seconds % 60 == 0 and seconds ~= 60 and seconds ~= 300 and seconds < 300 then
        for _, player in pairs(queue) do
            Player(player):sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "The Hunger Games will begin in " .. seconds/60 .. " minutes!")
        end
    elseif seconds == 300 then
        Game.broadcastMessage(MESSAGE_EVENT_ADVANCE,"The Hunger Games will begin in " .. seconds/60 .. " minutes! To join say /join hunger games")
    end
    if seconds ~= 0 then
        addEvent(teleportThing, 60000, seconds - 60)
    end
    return true
end

function onStartup()
    teleportThing(60)
    return true
end 