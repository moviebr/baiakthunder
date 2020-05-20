local gamename = {
    "hunger games"
}
queue = {}

function onSay(player, words, param)
    local id = 0
    for i=1, #gamename do
        if param == gamename[i] then
            id = i
        end
    end
    local currentgame = player:getStorageValue(currentgameid)
    if (id ~= 0) then
        if currentgame <= 0 then
            for _, playerid in pairs(queue) do
                if player:getName() == playerid then
                player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You are already queue for this game.")
                return player:getPosition():sendMagicEffect(CONST_ME_POFF)
                end
            end
            table.insert(queue, player:getName())
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have queued up for "..gamename[id].." with "..#queue.." total players")
            return player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
        else
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You are already in a game.")
            return player:getPosition():sendMagicEffect(CONST_ME_POFF)
        end
    else
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "!join hunger games")
        return player:getPosition():sendMagicEffect(CONST_ME_POFF)
    end
end 