local talk = TalkAction("!mailbox")

function talk.onSay(player, words, param)

    if not player:getGroup():getAccess() then
        return false
    end

    if player:getAccountType() < ACCOUNT_TYPE_GOD then
        return false
    end

    local split = param:split(",")
    local name = split[1]
    local id = split[2]
    local count = split[3]

    if not name or not id or not count then
        player:sendCancelMessage("Falta parametros.")
    end

    if not tonumber(id) or not tonumber(count) then
        player:sendCancelMessage("Informe apenas números.")
    end

    local targetPlayer = Player(name)
    if targetPlayer then
      local item = Game.createItem(tonumber(id), tonumber(count))
      item:moveTo(targetPlayer:getInbox())
      return
    end

    local resultId = db.storeQuery("SELECT `id` FROM `players` WHERE `name` = '" .. name.. "'")
    if not resultId then
        result.free(resultId)
        return false
    end

    local targetPlayerGUID = result.getDataInt(resultId, "id")
    result.free(resultId)

    targetPlayer = Player(targetPlayerGUID, true) -- load from db
    if not targetPlayer then
      return false
    end

    local item = Game.createItem(tonumber(id), tonumber(count))
    item:moveTo(targetPlayer:getInbox())
    targetPlayer:delete()
    return false
end

talk:separator(" ")
talk:register()
