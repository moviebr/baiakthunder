function onStepIn(creature, item, position, fromPosition)
    local player = creature:getPlayer()

    if SNOWBALL.level.active and player:getLevel() < SNOWBALL.level.levelMin then
        player:sendCancelMessage(SNOWBALL.prefixo .."Você precisa ter level " .. SNOWBALL.level.levelMin .. " ou maior para entrar no evento.")
        player:teleportTo(fromPosition, true)
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return true
    end

    if player:getItemCount(2165) >= 1 then
        player:sendCancelMessage(SNOWBALL.prefixo .."Você não pode entrar no evento com um stealth ring.")
        player:teleportTo(fromPosition, true)
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return true
    end

    local ring = player:getSlotItem(CONST_SLOT_RING)
    if ring then
        if ring:getId() == 2202 then
            player:sendCancelMessage(SNOWBALL.prefixo .."Você não pode entrar no evento usando um stealth ring.")
            player:teleportTo(fromPosition, true)
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return true
        end
    end

    for _, check in ipairs(Game.getPlayers()) do
        if player:getIp() == check:getIp() and check:getStorageValue(STORAGEVALUE_EVENTS) > 0 then
            player:sendCancelMessage(SNOWBALL.prefixo .. "Você já possui um outro player dentro do evento.")
            player:teleportTo(fromPosition, true)
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return true
        end
    end

    if #CACHE_GAMEPLAYERS >= SNOWBALL.maxPlayers then
        player:sendCancelMessage(SNOWBALL.prefixo .."O evento já atingiu o máximo de participantes.")
        player:teleportTo(fromPosition, true)
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return true
    end

    table.insert(CACHE_GAMEPLAYERS, player:getId())
    player:teleportTo(SNOWBALL.posEspera)
    player:setStorageValue(STORAGEVALUE_EVENTS, 1)
    return true
end
