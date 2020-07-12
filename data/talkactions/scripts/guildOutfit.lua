local tempo = 5 * 60 * 1000

function onSay(player, words, param)
    if not player:getGuild() then
        player:sendCancelMessage("Você não possui uma guild.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    if player:getStorageValue(98714) >= os.time() then
        player:sendCancelMessage("Você precisa esperar o cooldown acabar.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    if player:getGuildLevel() == 1 then
        player:sendCancelMessage("Você precisa ser um Vice-Líder ou Líder para trocar o outfit da guild.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    local guild = player:getGuild()
    local outfit = player:getOutfit()

    for _, members in ipairs(guild:getMembersOnline()) do
        local newOutfit = outfit
        if(not members:hasOutfit(outfit.lookType, outfit.lookAddons)) then
            local tmpOutfit = members:getOutfit()
            newOutfit.lookAddons = 0
            if(not members:hasOutfit(outfit.lookType, 0)) then
                newOutfit.lookType = tmpOutfit.lookType
            end
        end

        members:getPosition():sendMagicEffect(45)
		members:setOutfit(newOutfit)
        members:sendTextMessage(MESSAGE_STATUS_BLUE_LIGHT, "O player {".. player:getName().. "} trocou a outfit da guild.")
    end

    player:getPosition():sendMagicEffect(CONST_ME_FIREAREA)
    player:setStorageValue(98714, os.time() + tempo)
    return true
end