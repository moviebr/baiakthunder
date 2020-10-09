--[[
    !hunted add, Player, item, nome ou id do item
    !hunted add, Player, points, 10
    !hunted add, Player, gold, 10000000
    !hunted cancel, Player
--]]

--[[
CREATE TABLE `hunted_system` ( 
    `player` VARCHAR(255) NOT NULL ,
    `target` VARCHAR(255) NOT NULL,
    `type` VARCHAR(255) NOT NULL,
    `count` INT(11) NOT NULL
) ENGINE = InnoDB;")
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
        target = "Sua morte foi colocada em jogo. Boa sorte.",
        maxGolds = "O máximo que você pode informar é %s.",
        blockItem = "Esse item não pode ser fornecido.",
    },
    maxGold = 5000000,
    maxPoints = 500,
    minLevel = 150,
    storageLimit = {
        value = 52371,
        free = 3,
        premium = 5,
    },
    blockItems = {2160},
}

local function checkHunteds(targetName)
    local resultId = db.storeQuery(string.format('SELECT * FROM `hunted_system` WHERE `target` = %s', targetName))
    if not resultId then
        return false
    end

    local player = result.getString(resultId, "player")
    local target = result.getString(resultId, "target")
    local type = result.getString(resultId, "type")
    local count = result.getDataLong(resultId, "count")
    result.free(resultId)
    return {player = player, target = target, type = type, count = count}
end

local hunted = TalkAction("!hunted")

function hunted.onSay(player, words, param)

    if player:getLevel < HuntedSystem.minLevel then
        player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.levelMin:format(HuntedSystem.minLevel))
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    if not param then
        player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.notParam)
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    param = param:lower()
    local split = param:split(",")
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
    elseif comando ~= "add" or comando ~= "cancel" then
        player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.noComand)
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    if comando == "add" then
        if not tipo or not qnt then
            player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.enoughParam)
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
        
        if tipo ~= "item" or tipo ~= "gold" or tipo ~= "points" then
            player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.enoughParam)
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end

        target = Player(target)

        if not target then
            player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.noTarget)
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end

        if tipo == "item" then
            if not qnt then
                player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.noQnt:format("o nome do item ou seu id"))
                player:getPosition():sendMagicEffect(CONST_ME_POFF)
                return false
            end

            local item = ItemType(qnt)
            if not item then
                player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.noItem)
                player:getPosition():sendMagicEffect(CONST_ME_POFF)
                return false
            end

            if isInArray(HuntedSystem.blockItems, item:getId()) then
                player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.blockItem)
                player:getPosition():sendMagicEffect(CONST_ME_POFF)
                return false
            end

            local sql = db.query("INSERT INTO `hunted_system` (`player`, `target`, `type`, `count`) VALUES ('".. player:getName().. "', '".. target:getName() .."', '".. tipo .."', '".. item:getId() .. "')")
            if sql == RETURNVALUE_NOERROR and item:remove() then
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
                player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.maxGolds:format(HuntedSystem.maxGold))
                player:getPosition():sendMagicEffect(CONST_ME_POFF)
                return false
            end

            local sql = db.query("INSERT INTO `hunted_system` (`player`, `target`, `type`, `count`) VALUES ('".. player:getName().. "', '".. target:getName() .."', '".. tipo .."', '".. tonumber(qnt).. "')")
            if sql == RETURNVALUE_NOERROR and player:removeMoney(tonumber(qnt)) then
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
                player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.maxGolds:format(HuntedSystem.maxPoints))
                player:getPosition():sendMagicEffect(CONST_ME_POFF)
                return false
            end

            local sql = db.query("INSERT INTO `hunted_system` (`player`, `target`, `type`, `count`) VALUES ('".. player:getName().. "', '".. target:getName() .."', '".. tipo .."', '".. tonumber(qnt).. "')")
            if sql == RETURNVALUE_NOERROR and player:removePremiumPoints(tonumber(qnt)) then
                player:getPosition():sendMagicEffect(14)
                target:getPosition():sendMagicEffect(6)
                player:sendCancelMessage(HuntedSystem.messages.prefix .. HuntedSystem.messages.hunted:format(target:getName()))
                target:sendTextMessage(MESSAGE_EVENT_ADVANCE, HuntedSystem.messages.prefix .. HuntedSystem.messages.target)
                return false
            end
        end
    elseif comando == "cancel" then
        
    end

    return false
end

hunted:separator(" ")
hunted:register()