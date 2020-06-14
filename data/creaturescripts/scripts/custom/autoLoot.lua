local function scanContainer(cid, position)
    local player = Player(cid)
    if not player then
        return
    end

    local corpse = Tile(position):getTopDownItem()
    if not corpse then
        return
    end

    if corpse:getType():isCorpse() and corpse:getAttribute(ITEM_ATTRIBUTE_CORPSEOWNER) == cid then
        for i = corpse:getSize() - 1, 0, -1 do
            local containerItem = corpse:getItem(i)
            if containerItem then
                if player:getStorageValue(AUTOLOOT_STORAGE_GOLD) == 1 and containerItem:getWorth() > 0 then
                    local itemMoney = containerItem:getWorth()
                    player:sendTextMessage(MESSAGE_STATUS_SMALL, "[Auto Loot System] Coletados: ".. itemMoney .." gold coins.")
                    player:setBankBalance(player:getBankBalance() + itemMoney)
                    containerItem:remove()
                else
                    for i = AUTOLOOT_STORAGE_START, AUTOLOOT_STORAGE_END do
                        if player:getStorageValue(i) == containerItem:getId() then
                            containerItem:moveTo(player)
                        end
                    end
                end
            end
        end
    end
end

function onKill(player, target)
    if not target:isMonster() then
        return true
    end

    addEvent(scanContainer, 100, player:getId(), target:getPosition())
    return true
end