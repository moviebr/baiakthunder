--[[
    !hunted add, Player, item, nome do item
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
    local split = param:split(",")
    local comando = split[1]
    local target = Player(split[2])
    local config = split[3]
    local qnt = split[4]

    if not param then
        player:sendCancelMessage("[Hunted System] Faltam parâmetros.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    if comando ~= "add" or comando ~= "cancel" then
        player:sendCancelMessage("[Hunted System] Você precisa específicar o tipo da ação (add ou cancel).")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    if comando == "add" and not target then
        player:sendCancelMessage("[Hunted System] Esse jogador precisa estar online ou ele não existe.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    if comando == "add" and config ~= "item" or config ~= "pontos" or config ~= "gold" then
        player:sendCancelMessage("[Hunted System] Os tipos possíveis são item ou pontos ou gold.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end
    
    if comando == "add" and config ~= "item" and not tonumber(qnt) then
        player:sendCancelMessage("[Hunted System] Informe a quantidade em números.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    if comando == "add" and config == "item" and not ItemType(qnt) then
        player:sendCancelMessage("[Hunted System] O item com esse nome ou id não existe.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end
--[[
    if comando == "cancel" and not target then
        player:sendCancelMessage("[Hunted System] Esse jogador precisa estar online ou ele não existe.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end
--]]
    if comando == "cancel" and config or qnt then
        player:sendCancelMessage("[Hunted System] Excesso de parâmetros.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    if comando == "add" then
        if type == "item" then
            local item = ItemType(item)
            local slot = player:getSlotItem(CONST_SLOT_AMMO)
            if slot then
                if slot:getId() == item:getId() then
                    item:remove()
                    player:sendCancelMessage("[Hunted System] O player ".. target:getName() .." está hunted.")
                    player:getPosition():sendMagicEffect(14)
                    target:getPosition():sendMagicEffect(6)
                    db.query("INSERT INTO `hunted_system` (`player`, `target`, `type`, `count`) VALUES ('".. player:getName().. "', '".. target:getName() .."', '".. type .."', '".. tonumber(count).. "')")
                end
            end
        elseif type == "pontos" then
            if player:removePremiumPoints(tonumber(count)) then
                player:sendCancelMessage("[Hunted System] O player ".. target:getName() .." está hunted.")
                player:getPosition():sendMagicEffect(14)
                target:getPosition():sendMagicEffect(6)
                db.query("INSERT INTO `hunted_system` (`player`, `target`, `type`, `count`) VALUES ('".. player:getName().. "', '".. target:getName() .."', '".. type .."', '".. tonumber(count).. "')")
            end
        elseif type == "gold" then
            if player:removeMoney(tonumber(count)) then
                player:sendCancelMessage("[Hunted System] O player ".. target:getName() .." está hunted.")
                player:getPosition():sendMagicEffect(14)
                target:getPosition():sendMagicEffect(6)
                db.query("INSERT INTO `hunted_system` (`player`, `target`, `type`, `count`) VALUES ('".. player:getName().. "', '".. target:getName() .."', '".. type .."', '".. tonumber(count).. "')")
            end
        end
    elseif comando == "cancel" then
        local check = checkHunteds(target:getName())
        if not check then
            player:sendCancelMessage("[Hunted System] Não foi achado nenhum player no sistema.")
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end

        if check.type == "item" then
            local item = Game.createItem(ItemType(check.count), 1)
            local itemReceber = player:getInbox():addItemEx(item, INDEX_WHEREEVER, FLAG_NOLIMIT)
            if itemReceber == RETURNVALUE_NOERROR then
                player:sendCancelMessage("[Hunted System] O jogador ".. check.target .." foi retirado do sistema. O seu item chegou no mailbox.")
                player:getPosition():sendMagicEffect(14)
                db.query("DELETE FROM `hunted_system` WHERE target =".. check.target)
                return true
            end
        elseif check.type == "pontos" then
            if player:addPremiumPoints(tonumber(check.count)) then
                player:sendCancelMessage("[Hunted System] O jogador ".. check.target .." foi retirado do sistema. O seu item chegou no mailbox.")
                player:getPosition():sendMagicEffect(14)
                db.query("DELETE FROM `hunted_system` WHERE target =".. check.target)
                return true
            end
        elseif check.type == "gold" then
            if player:addMoney(tonumber(check.count)) then
                player:sendCancelMessage("[Hunted System] O jogador ".. check.target .." foi retirado do sistema. O seu item chegou no mailbox.")
                player:getPosition():sendMagicEffect(14)
                db.query("DELETE FROM `hunted_system` WHERE target =".. check.target)
                return true
            end
        end
    end
    return false
end

hunted:separator(" ")
hunted:register()