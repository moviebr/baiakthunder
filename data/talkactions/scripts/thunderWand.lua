local info = [[Troque elementos usando:
!staff holy
!staff ice
!staff fire
!staff energy
!staff earth]]

function onSay(player, words, param)
    param = param:lower()
    if param == '' then
        player:showTextDialog(7879, info)
        return false
    end

    local index = 0
    if param == 'holy' then index = 1
    elseif param == 'ice' then index = 2
    elseif param == 'fire' then index = 3
    elseif param == 'energy' then index = 4
    elseif param == 'earth' then index = 5
    else
        player:sendCancelMessage('Elemento não encontrado.')
        return false
    end

    local item = player:getSlotItem(CONST_SLOT_LEFT)
    if item and item:getId() == 7879 then
        if player:getStorageValue(STORAGEVALUE_THUNDER_WAND) == index then
            player:sendCancelMessage('A sua Thunder Staff já está com esse elemento.')
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end

        player:setStorageValue(STORAGEVALUE_THUNDER_WAND, index)
        player:sendTextMessage(MESSAGE_INFO_DESCR, 'Elemento trocado para: ' .. param)
        player:save()
    else
        player:sendCancelMessage('Você não está usando uma Thunder Staff.')
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
    end
end 