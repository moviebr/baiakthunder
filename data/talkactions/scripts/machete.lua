local price = 500

function onSay(player, words, param)

    if player:removeMoney(price) then
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
        player:addItem(2420, 1)    
		player:sendCancelMessage("Você comprou uma machete.")
    else
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        player:sendCancelMessage("Você não tem dinheiro suficiente.")
    end

    return false
end