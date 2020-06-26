local price_aol = 10000

function onSay(player, words, param)

    if player:removeMoney(price_aol) then
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
        player:say("[AOL]", TALKTYPE_MONSTER_SAY, true)
        player:addItem(2173, 1)    
		player:sendCancelMessage("Você comprou um AOL.")
    else
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        player:sendCancelMessage("Você não tem dinheiro suficiente.")
    end
    return false
end