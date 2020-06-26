function onDeath(player, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
local gameid = player:getStorageValue(currentgameid)
if gameid > 0 then
if killer and killer:isPlayer() then
for _, gamer in pairs(gameplayers[gameid]) do
Player(gamer):sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, player:getName() .. " has been killed by " .. killer:getName() .. " with "..player:getStorageValue(killstreak).." kills | Tributes still alive: " .. #gameplayers[gameid])
end
killer:setStorageValue(killstreak, killer:getStorageValue(killstreak)+1)
else
for  _, gamer in pairs(gameplayers[gameid]) do
Player(gamer):sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, player:getName() .. " has died with "..player:getStorageValue(killstreak).." kills | Tributes still alive: " .. #gameplayers[gameid])
end
end
player:setStorageValue(killstreak, 0)
player:setStorageValue(currentgameid, -1)
player:getBackItems()
for k,v in pairs(gameplayers[gameid]) do
if v == player:getName() then
table.remove(gameplayers[gameid],k)
end
end
if #gameplayers[gameid] == 1 then
Game.broadcastMessage(MESSAGE_EVENT_ADVANCE,Player(gameplayers[gameid][1]):getName() .." has won The Hunger Games in ".. game[gameid].name .." with ".. Player(gameplayers[gameid][1]):getStorageValue(killstreak) .." Kill Streaks! Congratulations!")
Player(gameplayers[gameid][1]):teleportTo((Player(gameplayers[gameid][1]):getTown()):getTemplePosition())
Player(gameplayers[gameid][1]):setStorageValue(killstreak, 0)
Player(gameplayers[gameid][1]):setStorageValue(currentgameid, -1)
Player(gameplayers[gameid][1]):getBackItems()
for _, item in pairs(prize) do
Player(gameplayers[gameid][1]):addItem(item[1],item[2])
end
for k,v in pairs(gameplayers[gameid]) do
if v == gameplayers[gameid][1] then
table.remove(gameplayers[gameid],i)
end
end
table.insert(availablearenas, gameid)
end
end
return true
end 