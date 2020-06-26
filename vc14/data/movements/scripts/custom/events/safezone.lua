function onStepIn(creature, item, position, fromPosition)
    local player = creature:getPlayer()
    if not player then
        return true
    end

    if player:getGroup():getAccess() then
        player:teleportTo(SAFEZONE.positionEnterEvent)
        return true
    end

    if player:getLevel() < SAFEZONE.levelMin then
        player:sendCancelMessage(SAFEZONE.messages.prefix .."Você precisa ser level " .. SAFEZONE.levelMin .. "ou maior para entrar no evento.")
        player:teleportTo(fromPosition, true)
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return true
    end

    if player:getItemCount(2165) >= 1 then
        player:sendCancelMessage(SAFEZONE.messages.prefix .."Você não pode entrar com um stealth ring no evento.")
        player:teleportTo(fromPosition, true)
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return true
    end

    local ring = player:getSlotItem(CONST_SLOT_RING)
    if ring then
        if ring:getId() == 2202 then
            player:sendCancelMessage(SAFEZONE.messages.prefix .." Você não pode entrar no evento com um stealth ring.")
            player:teleportTo(fromPosition, true)
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return true
        end
    end

    for _, check in ipairs(Game.getPlayers()) do
        if player:getIp() == check:getIp() and check:getStorageValue(STORAGEVALUE_EVENTS) > 0 then
            player:sendCancelMessage(SAFEZONE.messages.prefix .. "Você já possui um outro player dentro do evento.")
            player:teleportTo(fromPosition, true)
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return true
        end
    end

    if safezoneTotalPlayers() >= SAFEZONE.maxPlayers then
        player:sendCancelMessage(SAFEZONE.messages.prefix .. "O evento já atingiu o número máximo de participantes.")
        player:teleportTo(fromPosition, true)
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return true
    end

    local outfit = player:getSex() == 0 and 136 or 128
    local treeLifeColor = SAFEZONE.lifeColor[3]
    player:setOutfit({lookType = outfit, lookHead = treeLifeColor, lookBody = treeLifeColor, lookLegs = treeLifeColor, lookFeet = treeLifeColor})

    player:sendTextMessage(MESSAGE_INFO_DESCR, SAFEZONE.messages.prefix .."Você entrou no evento. Boa sorte!")
    player:teleportTo(SAFEZONE.positionEnterEvent)
    player:setStorageValue(STORAGEVALUE_EVENTS, 1)
    player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
    player:setStorageValue(SAFEZONE.storage, 3)

    return true
end
