local talk = TalkAction("!castle48")

function talk.onSay(player, words, param)

    if player:getStorageValue(Castle48H.playerStorageVote) >= os.time() then
        player:sendCancelMessage(Castle48H.msg.prefix .. "Você já votou!")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    if Game.getStorageValue(Castle48H.storageGlobal) ~= 0 then
        player:sendCancelMessage(Castle48H.msg.prefix .. "O castelo não está aceitando votações no momento.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    if not player:getGuild() then
        player:sendCancelMessage(Castle48H.msg.prefix .. "Você precisa fazer parte de uma guild para votar!")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    if player:getLevel() < Castle48H.levelMin then
        player:sendCancelMessage(Castle48H.msg.prefix .. Castle48H.msg.levelMin:format(Castle48H.levelMin, " ou maior para votar"))
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    if param == 1 then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, Castle48H.msg.prefix .. "Você votou para que o último dominante vença o castelo.")
        player:getPosition():sendMagicEffect(29)
        Game.setStorageValue(Castle48H.storageVoteOne, Game.getStorageValue(Castle48H.storageVoteOne) + 1)
    elseif param == 2 then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, Castle48H.msg.prefix .. "Você votou para que a guild dominante por mais tempo vença o castelo.")
        player:getPosition():sendMagicEffect(30)
        Game.setStorageValue(Castle48H.storageVoteTwo, Game.getStorageValue(Castle48H.storageVoteTwo) + 1)
    else
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, Castle48H.msg.prefix .. "Comando não reconhecido.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
    end

    player:setStorageValue(Castle48H.playerStorageVote, os.time() + 3600)
    return false
end

talk:separator(" ")
talk:register()
