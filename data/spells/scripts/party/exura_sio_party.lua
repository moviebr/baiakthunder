function onCastSpell(creature, var)

    local baseMana = 140
    local additionalTargetMana = 40
    local healerPos = creature:getPosition()
    local healerId = creature:getId()
    local party = creature:getParty()
    local membersList = {}


    if party then
        membersList = party:getMembers()
        table.insert(membersList, party:getLeader())
        if membersList == nil then
            creature:sendTextMessage(MESSAGE_STATUS_SMALL, "Não há membros do grupo no alcance com perca de vida.")
            healerPos:sendMagicEffect(CONST_ME_POFF)
            return false
        end
    else
        creature:sendTextMessage(MESSAGE_STATUS_SMALL, "Você não está em um grupo.")
        return false
    end

    local affectedList = {}
    for _, partyMember in ipairs(membersList) do
        local partyMemberId = partyMember:getId()
        if partyMemberId ~= creature:getId() then
            local partyMemberPos = partyMember:getPosition()
            local distanceX = math.abs(partyMemberPos.x - healerPos.x)
            local distanceY = math.abs(partyMemberPos.y - healerPos.y)
            if distanceX <= 7 and distanceY <= 5 and partyMemberPos.z == healerPos.z and partyMemberPos:isSightClear(healerPos, true) and partyMember:getHealth() < partyMember:getMaxHealth() then
                table.insert(affectedList, partyMember)
            end
        end
    end

    local tmp = 0
    if affectedList ~= nil then
        tmp = #affectedList
    end
    if tmp < 1 then
        creature:sendTextMessage(MESSAGE_STATUS_SMALL, "Não há membros do grupo no alcance com perca de vida.")
        healerPos:sendMagicEffect(CONST_ME_POFF)
        return false
    end

    local mana = baseMana + (additionalTargetMana * (tmp - 1))
    if(creature:getMana() < mana) then
        creature:sendCancelMessage(RETURNVALUE_NOTENOUGHMANA)
        healerPos:sendMagicEffect(CONST_ME_POFF)
        return false
    end
 
    creature:addMana(-(mana - baseMana), FALSE)
    creature:addManaSpent((mana - baseMana))
 
    local level = creature:getLevel()
    local magiclevel = creature:getMagicLevel()
    local min = (level / 5) + (magiclevel * 6.3) + 45
    local max = (level / 5) + (magiclevel * 14.4) + 90
 
    healerPos:sendMagicEffect(CONST_ME_MAGIC_GREEN)
 
    for _, partyMember in ipairs(affectedList) do
        local healAmount = math.random(min,max)
        partyMember:addHealth(healAmount)
        partyMember:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    end

    return true
end