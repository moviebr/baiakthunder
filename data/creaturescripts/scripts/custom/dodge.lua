function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)

    if not creature:isPlayer() then 
    	return primaryDamage, primaryType, secondaryDamage, secondaryType 
    end

    if (creature:getDodgeLevel() * 3) >= math.random (0, 1000) and attacker:isCreature() then
        if isInArray({ORIGIN_MELEE, ORIGIN_RANGED, ORIGIN_SPELL}, origin) and primaryType ~= COMBAT_HEALING then
            primaryDamage = primaryDamage - math.ceil(primaryDamage * DODGE.PERCENT)
            creature:say("DODGE!", TALKTYPE_MONSTER_SAY)
            creature:getPosition():sendMagicEffect(CONST_ME_BLOCKHIT)
        end
    end
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end