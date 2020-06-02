-- ### CONFIG ###
-- message to player "type", if delivery of item debugs client, it can be because of undefinied type (type that does not exist in your server LUA)
SHOP_MSG_TYPE = MESSAGE_EVENT_ADVANCE
-- ### END OF CONFIG ###

function onThink(interval)
    local resultId = db.storeQuery("SELECT * FROM z_ots_comunication")
    if resultId ~= false then
        repeat
            local transactionId = tonumber(result.getDataInt(resultId, "id"))
            local player = Player(result.getDataString(resultId, "name"))

            if player then
                local itemId = result.getDataInt(resultId, "param1")
                local itemCount = result.getDataInt(resultId, "param2")
                local containerId = result.getDataInt(resultId, "param3")
                local containerItemsInsideCount = result.getDataInt(resultId, "param4")
                local shopOfferType = result.getDataString(resultId, "param5")
                local shopOfferName = result.getDataString(resultId, "param6")

-- DELIVER ITEM
                if shopOfferType == 'item' then
                    local newItemUID = player:addItem(itemId, itemCount)
                    --  item does not exist, wrong id OR count
                    if not newItemUID then
                        player:sendTextMessage(SHOP_MSG_TYPE, 'Website Shop bugged. Contact with administrator! Error is visible in server console.')
                        print('ERROR! Website Shop (' .. player:getName() .. ') - cannot create item - invalid item ID OR count - ITEM ID: ' .. itemId .. ', ITEM COUNT: ' .. itemCount)
                        return true
                    end
                    -- change item UniqueID to object of class Item
                    local newItem = Item(newItemUID)

                    -- add container with items to Store Inbox
                    receivedItemStatus = player:addItem(newItem)

                    if receivedItemStatus then
                        player:sendTextMessage(SHOP_MSG_TYPE, 'You received ' .. shopOfferName .. ' from Website Shop. You can find your item in STORE INBOX (under EQ).')
                        db.asyncQuery("DELETE FROM `z_ots_comunication` WHERE `id` = " .. transactionId)
                        db.asyncQuery("UPDATE `z_shop_history_item` SET `trans_state`= 'realized', `trans_real`=" .. os.time() .. " WHERE `id` = " .. transactionId)
                    else
                        player:sendTextMessage(SHOP_MSG_TYPE, 'Website Shop bugged. Contact with administrator! Error is visible in server console.')
                        print('ERROR! Website Shop (' .. player:getName() .. ') - cannot add item to STORE INBOX - unknown reason, is it\'s size limited and it is full? - ITEM ID: ' .. itemId .. ', ITEM COUNT: ' .. itemCount)
                    end

-- DELIVER CONTAINER
                elseif shopOfferType == 'container' then
                    -- create empty container
                    local newContainerUID = player:addItem(containerId, 1)
                    -- container item does not exist OR item is not Container
                    if not newContainerUID or not Container(newContainerUID) then
                        player:sendTextMessage(SHOP_MSG_TYPE, 'Website Shop bugged. Contact with administrator! Error is visible in server console.')
                        print('ERROR! Website Shop (' .. player:getName() .. ') - cannot create container - invalid container ID - CONTAINER ID:' .. containerId)
                        return true
                    end
                    -- change container UniqueID to object of class Container
                    local newContainer = Container(newContainerUID)

                    -- add items to container
                    for i = 1, containerItemsInsideCount do
                        -- create new item
                        local newItemUID = player:addItem(itemId, itemCount)
                        --  item does not exist, wrong id OR count
                        if not newItemUID then
                            player:sendTextMessage(SHOP_MSG_TYPE, 'Website Shop bugged. Contact with administrator! Error is visible in server console.')
                            print('ERROR! Website Shop (' .. player:getName() .. ') - cannot create item - invalid item ID OR count - ITEM ID: ' .. itemId .. ', ITEM COUNT: ' .. itemCount)
                            return true
                        end
                        -- change item UniqueID to object of class Item
                        local newItem = Item(newItemUID)

                        -- add item to container
                        local addItemToContainerResult = newContainer:addItemEx(newItem)
                        -- report error if it's not possible to add item to container
                        if addItemToContainerResult then
                            player:sendTextMessage(SHOP_MSG_TYPE, 'Website Shop bugged. Contact with administrator! Error is visible in server console.')
                            print('ERROR! Website Shop (' .. player:getName() .. ') - cannot add item to container - item is not pickable OR variable "RETURNVALUE_NOERROR" is not definied in LUA - ITEM ID: ' .. itemId .. ', ITEM COUNT: ' .. itemCount)
                            return true
                        end
                    end

                    -- add container with items to Store Inbox
                    receivedItemStatus = player:addItem(newContainer)

                    if receivedItemStatus then
                        player:sendTextMessage(SHOP_MSG_TYPE, 'You received ' .. shopOfferName .. ' from Website Shop. You can find your item in STORE INBOX (under EQ).')
                        db.asyncQuery("DELETE FROM `z_ots_comunication` WHERE `id` = " .. transactionId)
                        db.asyncQuery("UPDATE `z_shop_history_item` SET `trans_state`= 'realized', `trans_real`=" .. os.time() .. " WHERE `id` = " .. transactionId)
                    else
                        player:sendTextMessage(SHOP_MSG_TYPE, 'Website Shop bugged. Contact with administrator! Error is visible in server console.')
                        print('ERROR! Website Shop (' .. player:getName() .. ') - cannot add container with items to STORE INBOX - unknown reason, is it\'s size limited and it is full? - ITEM ID: ' .. itemId .. ', ITEM COUNT: ' .. itemCount .. ', CONTAINER ID:' .. containerId .. ', ITEMS IN CONTAINER COUNT:' .. containerItemsInsideCount)
                    end

-- DELIVER YOUR CUSTOM THINGS
                elseif shopOfferType == 'outfit' then
                    player:addOutfitAddon(itemId, 3)
                    player:getPosition():sendMagicEffect(CONST_ME_HOLYDAMAGE)
                    player:sendTextMessage(SHOP_MSG_TYPE, 'You received ' .. shopOfferName .. ' from Website Shop.')
                    db.asyncQuery("DELETE FROM `z_ots_comunication` WHERE `id` = " .. transactionId)
                    db.asyncQuery("UPDATE `z_shop_history_item` SET `trans_state`= 'realized', `trans_real`=" .. os.time() .. " WHERE `id` = " .. transactionId)
                end
            end
        until not result.next(resultId)
        result.free(resultId)
    end

    return true
end