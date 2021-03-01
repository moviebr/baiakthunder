function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)

    if (not attacker or not creature) then  
    	return primaryDamage, primaryType, secondaryDamage, secondaryType 
    end

    if primaryType == COMBAT_HEALING then
    	return primaryDamage, primaryType, secondaryDamage, secondaryType 
    end

    if ((creature:getDodgeLevel() * 3) >= math.random (0, 1000) and creature:isPlayer()) then
        primaryDamage = 0
        secondaryDamage = 0
        creature:say("DODGE!", TALKTYPE_MONSTER_SAY)
        creature:getPosition():sendMagicEffect(CONST_ME_BLOCKHIT)
    end

    if (attacker:isPlayer() and (attacker:getCriticalLevel() * 3) >= math.random (0, 1000)) then
		primaryDamage = primaryDamage + math.ceil(primaryDamage * CRITICAL.PERCENT)
		attacker:say("CRITICAL!", TALKTYPE_MONSTER_SAY)
		creature:getPosition():sendMagicEffect(CONST_ME_EXPLOSIONHIT)
	end

    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

function onManaChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    
    if (not attacker or not creature) then  
        return primaryDamage, primaryType, secondaryDamage, secondaryType 
    end
    
    if ((creature:getDodgeLevel() * 3) >= math.random (0, 1000) and creature:isPlayer())  then
        primaryDamage = 0
        secondaryDamage = 0
        creature:say("DODGE!", TALKTYPE_MONSTER_SAY)
        creature:getPosition():sendMagicEffect(CONST_ME_BLOCKHIT)
    end
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end