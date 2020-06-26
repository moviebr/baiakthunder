function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if player:getStorageValue(10109) > 0 and player:getStorageValue(10108) <= 30  then

        player:setStorageValue(10108, player:getStorageValue(10108) + SNOWBALL.muniQuant)
        player:setStorageValue(10109, player:getStorageValue(10109) - SNOWBALL.muniPreco)
        player:sendTextMessage(29, SNOWBALL.prefixo .. (SNOWBALL.mensagemComprou):format(SNOWBALL.muniQuant, SNOWBALL.muniPreco, player:getStorageValue(10108), player:getStorageValue(10109)))
    elseif player:getStorageValue(10109) < 1 then

        player:sendCancelMessage(SNOWBALL.prefixo .. (SNOWBALL.mensagemComprou):format(SNOWBALL.muniPreco))
    elseif getStorageValue(10108) > 30 then

        player:sendCancelMessage(SNOWBALL.prefixo .. SNOWBALL.mensagemMinComprar)
    end
    return true
end