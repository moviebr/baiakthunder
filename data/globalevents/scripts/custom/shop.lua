function onThink(interval)
    local resultId = db.storeQuery("SELECT * FROM z_ots_comunication")
    if resultId ~= false then
        repeat
            local transactionId = tonumber(result.getDataInt(resultId, "id"))
            local player = Player(result.getDataString(resultId, "name"))

            if player then
                local itemId = result.getDataInt(resultId, "param1")
                local itemCount = result.getDataInt(resultId, "param2")
                local outfitParam = (result.getDataString(resultId, "param3")):lower()
                local containerItemsInsideCount = result.getDataInt(resultId, "param4")
                local shopOfferType = result.getDataString(resultId, "param5")
                local shopOfferName = result.getDataString(resultId, "param6")

-- DELIVER ITEM
                if shopOfferType == 'item' then
                    local item = Game.createItem(tonumber(itemId), tonumber(itemCount))
                    local itemReceber = player:getInbox():addItemEx(item, INDEX_WHEREEVER, FLAG_NOLIMIT)
                    if itemReceber == RETURNVALUE_NOERROR then
                        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você recebeu o item ".. ItemType(itemId):getName() .." no seu mailbox.")
                        player:getPosition():sendMagicEffect(31)
                        db.asyncQuery("DELETE FROM `z_ots_comunication` WHERE `id` = " .. transactionId)
                        db.asyncQuery("UPDATE `z_shop_history_item` SET `trans_state`= 'realized', `trans_real`=" .. os.time() .. " WHERE `id` = " .. transactionId)
                    else
                        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Houve algum erro ao tentar entregar um item do shopping. Entre em contato com os administradores")
                        player:getPosition():sendMagicEffect(CONST_ME_POFF)
                        print("[SHOP] Erro ao tentar entregar o ".. ItemType(itemId):getName() .." para o ".. player:getName() .."." )
                    end

-- DELIVER YOUR CUSTOM THINGS
                elseif shopOfferType == 'outfit' then
                    local abc = OUTFIT_LIST[outfitParam]
                    if abc then
                        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você recebeu o outfit ".. outfitParam ..".")
                        player:addOutfitAddon(abc[1], 3)
                        player:addOutfitAddon(abc[2], 3)
                        player:getPosition():sendMagicEffect(31)
                        db.asyncQuery("DELETE FROM `z_ots_comunication` WHERE `id` = " .. transactionId)
                        db.asyncQuery("UPDATE `z_shop_history_item` SET `trans_state`= 'realized', `trans_real`=" .. os.time() .. " WHERE `id` = " .. transactionId)  
                    end
                end
            end
        until not result.next(resultId)
        result.free(resultId)
    end

    return true
end