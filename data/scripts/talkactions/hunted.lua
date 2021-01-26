--[[
    !hunted add, Player, item, nome ou id do item
    !hunted add, Player, points, 10
    !hunted add, Player, gold, 10000000
    !hunted delete, Player
    !hunted check, Player
--]]

local HuntedSystem = {
    messages = {
        prefix = "[Hunted System] ",
        notParam = "Aprenda os comandos do sistema no nosso site.",
        levelMin = "Você precisa de level %d+ para usar esse sistema.",
        enoughParam = "Faltam parâmetros.",
        noComand = "Esse comando não existe.",
        noTarget = "Esse jogador não existe ou não está online.",
        noType = "Você precisa informar o tipo de pagamento (gold, points ou item).",
        noQnt = "Você precisa informar %s.",
        notNumber = "Você precisa informar apenas números.",
        noItem = "Esse item não existe.",
        hunted = "O jogador %s agora está hunted.",
        isHunted = "O jogador está na lista de hunted.",
        notHunted = "O jogador não está na lista de hunted.",
        noGold = "Você não possui dinheiro suficiente.",
        target = "Sua morte foi colocada em jogo. Boa sorte.",
        sameId = "Você não pode se colocar na lista de hunted.",
        removedList = "O jogador foi removido da lista de hunted.",
        maxGolds = "O máximo que você pode informar é %s %s.",
        blockItem = "Esse item não pode ser fornecido.",
        limit = "Você não pode colocar mais jogadores na lista. Seu limite é de %d jogadores."
    },
    maxGold = 5000,
    maxPoints = 50,
    minLevel = 1,
    storageLimit = {
        value = 52371,
        free = 3,
        premium = 5,
    },
    blockItems = {2160},
}

function checkHunteds(targetGuid)

    local resultId = db.storeQuery(string.format('SELECT * FROM `hunted_system` WHERE `targetGuid` = %d', targetGuid))
    if not resultId then
        return false
    end

    local playerGuid = result.getString(resultId, "playerGuid")
    local targetGuid = result.getString(resultId, "targetGuid")
    local type = result.getString(resultId, "type")
    local count = result.getDataLong(resultId, "count")
    result.free(resultId)
    return {playerGuid = playerGuid, targetGuid = targetGuid, type = type, count = count}
end

local hunted = TalkAction("!hunted")

function hunted.onSay(player, words, param)

    if not player:getStorageValue(HuntedSystem.storageLimit.value) or player:getStorageValue(HuntedSystem.storageLimit.value) == -1 then
        player:setStorageValue(HuntedSystem.storageLimit.value, 0)
    end

    if player:getLevel() < HuntedSystem.minLevel then
        player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.levelMin:format(HuntedSystem.minLevel))
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    if not param or param == "" then
        player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.notParam)
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    param = param:lower()
    local split = param:splitTrimmed(",")
    local comando = split[1]
    local target = split[2]
    local tipo = split[3]
    local qnt = split[4]

    if not comando then
        player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.enoughParam)
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    elseif not target then
        player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.enoughParam)
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    if comando == "add" then
        if not tipo or not qnt then
            player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.enoughParam)
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end

        if player:isPremium() and player:getStorageValue(HuntedSystem.storageLimit.value) >= HuntedSystem.storageLimit.premium then
            player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.limit:format(HuntedSystem.storageLimit.premium))
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        elseif not player:isPremium() and player:getStorageValue(HuntedSystem.storageLimit.value) >= HuntedSystem.storageLimit.free then
            player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.limit:format(HuntedSystem.storageLimit.free))
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end

        target = Player(target)

        if not target then
            player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.noTarget)
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end

        if player:getId() == target:getId() then
            player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.sameId)
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end

        local search = checkHunteds(target:getGuid())

        if search and tonumber(search.targetGuid) == tonumber(target:getGuid()) then
            player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.isHunted)
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end

        if tipo == "item" then
            if not qnt then
                player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.noQnt:format("o nome do item ou seu id"))
                player:getPosition():sendMagicEffect(CONST_ME_POFF)
                return false
            end

            qnt = tonumber(qnt) or tostring(qnt)

            item = player:getItemById(qnt, true)
            if not item then
                player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.noItem)
                player:getPosition():sendMagicEffect(CONST_ME_POFF)
                return false
            end

            itemInfo = ItemType(item:getId())

            if isInArray(HuntedSystem.blockItems, item:getId()) then
                player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.blockItem)
                player:getPosition():sendMagicEffect(CONST_ME_POFF)
                return false
            end

            if item:remove() then
                db.query("INSERT INTO `hunted_system` (`playerGuid`, `targetGuid`, `type`, `count`) VALUES ('".. player:getGuid().. "', '".. target:getGuid() .."', '".. tipo .."', '".. item:getId() .. "')")
                player:getPosition():sendMagicEffect(14)
                target:getPosition():sendMagicEffect(6)
                player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.hunted:format(target:getName()))
                target:sendTextMessage(MESSAGE_EVENT_ADVANCE, HuntedSystem.messages.prefix .. HuntedSystem.messages.target)
                return false
            end

        elseif tipo == "gold" then

            if not qnt then
                player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.noQnt:format("a quantidade de golds."))
                player:getPosition():sendMagicEffect(CONST_ME_POFF)
                return false
            end

            if not tonumber(qnt) then
                player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.notNumber)
                player:getPosition():sendMagicEffect(CONST_ME_POFF)
                return false
            end

            if tonumber(qnt) > HuntedSystem.maxGold then
                player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.maxGolds:format(HuntedSystem.maxGold, "golds"))
                player:getPosition():sendMagicEffect(CONST_ME_POFF)
                return false
            end

            if player:getMoney() < tonumber(qnt) then
                player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.noGold)
                player:getPosition():sendMagicEffect(CONST_ME_POFF)
                return false
            end

            if player:removeMoney(tonumber(qnt)) then
                db.query("INSERT INTO `hunted_system` (`playerGuid`, `targetGuid`, `type`, `count`) VALUES ('".. player:getGuid().. "', '".. target:getGuid() .."', '".. tipo .."', '".. tonumber(qnt).. "')")
                player:getPosition():sendMagicEffect(14)
                target:getPosition():sendMagicEffect(6)
                player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.hunted:format(target:getName()))
                target:sendTextMessage(MESSAGE_EVENT_ADVANCE, HuntedSystem.messages.prefix .. HuntedSystem.messages.target)
                return false
            end

        elseif tipo == "points" then
            if not qnt then
                player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.noQnt:format("a quantidade de pontos."))
                player:getPosition():sendMagicEffect(CONST_ME_POFF)
                return false
            end

            if not tonumber(qnt) then
                player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.notNumber)
                player:getPosition():sendMagicEffect(CONST_ME_POFF)
                return false
            end

            if tonumber(qnt) > HuntedSystem.maxPoints then
                player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.maxGolds:format(HuntedSystem.maxPoints, "pontos"))
                player:getPosition():sendMagicEffect(CONST_ME_POFF)
                return false
            end

            if player:removePremiumPoints(tonumber(qnt)) then
                db.query("INSERT INTO `hunted_system` (`playerGuid`, `targetGuid`, `type`, `count`) VALUES ('".. player:getGuid().. "', '".. target:getGuid() .."', '".. tipo .."', '".. tonumber(qnt).. "')")
                player:getPosition():sendMagicEffect(14)
                target:getPosition():sendMagicEffect(6)
                player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.hunted:format(target:getName()))
                target:sendTextMessage(MESSAGE_EVENT_ADVANCE, HuntedSystem.messages.prefix .. HuntedSystem.messages.target)
                return false
            end
        end
    elseif comando == "delete" then

        targetPlayer = Player(target)
        targetPlayerGuid = targetPlayer:getGuid()
            
        if not targetPlayer then
            targetPlayer = Player(target, true)
                
            if not targetPlayer then
                return false
            end

            targetPlayerGuid = targetPlayer:getGuid()
            targetPlayer:delete()
        end

        local tabela = checkHunteds(targetPlayerGuid)

        if tabela then
            if tonumber(tabela.playerGuid) == tonumber(player:getGuid()) and targetPlayerGuid == tonumber(tabela.targetGuid) then
                if tabela.type == "item" then
                    sendMailbox(player:getId(), tabela.count, 1)
                elseif tabela.type == "gold" then
                    player:addMoney(tonumber(tabela.count))
                elseif tabela.type == "points" then
                    player:addPremiumPoints(tonumber(tabela.count))
                end
                db.query(string.format("DELETE FROM `hunted_system` WHERE playerGuid = %d AND targetGuid = %d", player:getGuid(), targetPlayerGuid))
                player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.removedList)
                player:getPosition():sendMagicEffect(30)
                return false
            end
        end
    elseif comando == "check" then

        targetPlayer = Player(target)
        if targetPlayer then
            targetPlayerGuid = targetPlayer:getGuid()
        end
            
        if not targetPlayer then
            targetPlayer = Player(target, true)
                
            if not targetPlayer then
                return false
            end

            targetPlayerGuid = targetPlayer:getGuid()
            targetPlayer:delete()
        end

        if not checkHunteds(targetPlayerGuid) then
            player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.notHunted)
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end

        player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.isHunted)
        player:getPosition():sendMagicEffect(6)
    end

    return false
end

hunted:separator(" ")
hunted:register()