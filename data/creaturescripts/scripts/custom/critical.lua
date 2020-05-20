function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	
	if not isPlayer(attacker) then
		return false
	end
	
		if (attacker:getCriticalLevel() * 3) >= math.random (0, 1000) then
			if isInArray({ORIGIN_MELEE, ORIGIN_RANGED, ORIGIN_SPELL}, origin) and primaryType ~= COMBAT_HEALING then
				primaryDamage = primaryDamage + math.ceil(primaryDamage * CRITICAL.PERCENT)
				attacker:say("CRITICAL!", TALKTYPE_MONSTER_SAY)
				creature:getPosition():sendMagicEffect(CONST_ME_EXPLOSIONHIT)
			end
		end
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end