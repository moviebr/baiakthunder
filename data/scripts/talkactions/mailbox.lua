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
        player:sendCancelMessage("Falta parâmetros.")
    end

    if not tonumber(id) or not tonumber(count) then
        player:sendCancelMessage("Informe apenas números.")
    end

    local resultId = db.storeQuery("SELECT `id` FROM `players` WHERE `name` = '" .. name.. "'")
    if not resultId then
        result.free(resultId)
        return false
    end

    local targetPlayerId = result.getDataInt(resultId, "id")
    result.free(resultId)

    if not Player(name) then
        db.query("INSERT INTO `player_inboxitems` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES ("..targetPlayerId..", 0, 0, "..id..", "..count..")")
        player:sendCancelMessage("Enviado com sucesso.")
        return false
    end

    return false
end

talk:separator(" ")
talk:register()
