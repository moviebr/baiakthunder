local talk = TalkAction("!autoloot")

function talk.onSay(player, words, param)
    local split = param:split(",")

    local action = split[1]
    if action == "add" then
        local item = split[2]:gsub("%s+", "", 1)
        local itemType = ItemType(item)
        if itemType:getId() == 0 then
            itemType = ItemType(tonumber(item))
            if itemType:getId() == 0 then
                player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Não tem item com esse id ou nome.")
                return false
            end
        end

        local itemName = tonumber(split[2]) and itemType:getName() or item
        local size = 0
        for i = AUTOLOOT_STORAGE_START, AUTOLOOT_STORAGE_END do
            local storage = player:getStorageValue(i)
            if size == AUTO_LOOT_MAX_ITEMS then
                player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Sua lista está cheia, remova algum para adicionar um novo.")
                break
            end

            if storage == itemType:getId() then
                player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, itemName .." já está na sua lista.")
                break
            end

            if storage <= 0 then
                player:setStorageValue(i, itemType:getId())
                player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, itemName .." foi adicionado à sua lista.")
                break
            end

            size = size + 1
        end
    elseif action == "remove" then
        local item = split[2]:gsub("%s+", "", 1)
        local itemType = ItemType(item)
        if itemType:getId() == 0 then
            itemType = ItemType(tonumber(item))
            if itemType:getId() == 0 then
                player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Não existe um item com esse id ou nome.")
                return false
            end
        end

        local itemName = tonumber(split[2]) and itemType:getName() or item
        for i = AUTOLOOT_STORAGE_START, AUTOLOOT_STORAGE_END do
            if player:getStorageValue(i) == itemType:getId() then
                player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, itemName .." foi removido da sua lista.")
                player:setStorageValue(i, 0)
                return false
            end
        end

        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, itemName .." não foi achado na sua lista.")
    elseif action == "list" then
        local text = "-- Auto Loot List --\n"
        local count = 1
        for i = AUTOLOOT_STORAGE_START, AUTOLOOT_STORAGE_END do
            local storage = player:getStorageValue(i)
            if storage > 0 then
                text = string.format("%s%d. %s\n", text, count, ItemType(storage):getName())
                count = count + 1
            end
        end

        if text == "" then
            text = "Empty"
        end
   
        player:showTextDialog(1950, text, false)
    elseif action == "clear" then
        for i = AUTOLOOT_STORAGE_START, AUTOLOOT_STORAGE_END do
            player:setStorageValue(i, 0)
        end

        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "A lista de autoloot foi limpa.")
    elseif action == "gold" then
        if player:getStorageValue(AUTOLOOT_STORAGE_GOLD) == 1 then
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "O autoloot de gold foi desativado.")
            player:setStorageValue(AUTOLOOT_STORAGE_GOLD, -1)
        else
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "O autoloot de gold foi ativado.")
            player:setStorageValue(AUTOLOOT_STORAGE_GOLD, 1)
        end
    else
        player:popupFYI("Veja abaixo os comandos disponíveis do Auto Loot:\n\n!autoloot gold\n!autoloot list\n!autoloot add, itemname\n!autoloot remove, itemname\n!autoloot clear")
    end

    return false
end

talk:separator(" ")
talk:register()
