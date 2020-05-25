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