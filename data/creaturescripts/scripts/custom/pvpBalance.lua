function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not configManager.getBoolean(configKeys.PVP_BALANCE) then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	
	if not creature or not attacker or creature == attacker then
	  return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
   
	if creature:isPlayer() and creature:getParty() and attacker:isPlayer() and attacker:getParty() then
	  if creature:getParty() == attacker:getParty() then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	  end
	end
	  if creature:isPlayer() and attacker:isPlayer() then
				  primaryDamage = math.floor(primaryDamage - (primaryDamage * 20 / 100))
				  secondaryDamage = math.floor(secondaryDamage - (secondaryDamage * 20 / 100))
		  local damage = (primaryDamage + secondaryDamage)
		  if damage < 0 then
			   damage = damage * -1
		  end
	  end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
  end
  
  function onManaChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not configManager.getBoolean(configKeys.PVP_BALANCE) then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	if not creature or not attacker or creature == attacker then
	  return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
  
	if creature:isPlayer() and creature:getParty() and attacker:isPlayer() and attacker:getParty() then
	  if creature:getParty() == attacker:getParty() then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	  end
	end
	  if creature:isPlayer() and attacker:isPlayer() then
	  if creature:getVocation():getId() == 3 or creature:getVocation():getId() == 7 or creature:getVocation():getId() == 11 then
		   primaryDamage = math.floor(primaryDamage - (primaryDamage * 12 / 100))
		   secondaryDamage = math.floor(secondaryDamage - (secondaryDamage * 12 / 100))
		 else
		  primaryDamage = math.floor(primaryDamage - (primaryDamage * 65 / 100))
		  secondaryDamage = math.floor(secondaryDamage - (secondaryDamage * 65 / 100))
		 end
	  local damage = (primaryDamage + secondaryDamage)
	  if damage < 0 then
		damage = damage * -1
	  end
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
  end