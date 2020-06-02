function Creature:onChangeOutfit(outfit)
    if self:getStorageValue(STORAGEVALUE_EVENTS) >= 1 then
        self:sendTextMessage(MESSAGE_INFO_DESCR, "Você não pode trocar de outfit enquanto estiver dentro de um evento.")
        return false
    end

	return true
end

function Creature:onAreaCombat(tile, isAggressive)
	return RETURNVALUE_NOERROR
end

local staminaBonus = {
	target = 'Trainer',
	period = 600000, -- time on miliseconds
	bonus = 5, -- gain stamina
	events = {}
}

local function addStamina(name)
	local player = Player(name)
	if not player then
		staminaBonus.events[name] = nil
	else
		local target = player:getTarget()
		if not target or target:getName() ~= staminaBonus.target then
			staminaBonus.events[name] = nil
		else
			player:setStamina(player:getStamina() + staminaBonus.bonus)
			staminaBonus.events[name] = addEvent(addStamina, staminaBonus.period, name)
		end
	end
end

function Creature:onTargetCombat(target)
   if not self then
        return true
    end

    if (self:isPlayer() and target:isNpc()) then
        self:say("hi", TALKTYPE_PRIVATE_PN, false, target)
        self:say("trade", TALKTYPE_PRIVATE_PN, false, target)
        return RETURNVALUE_NOTPOSSIBLE   
    end

    -- Battlefield
    if Game.getStorageValue(BATTLEFIELD.storageEventStatus) == 1 then
    	if self:getStorageValue(BATTLEFIELD.storageTeam) == target:getStorageValue(BATTLEFIELD.storageTeam) then
    		return RETURNVALUE_NOTPOSSIBLE
    	end
    end

    if self:isPlayer() then
        if target and target:getName() == staminaBonus.target then
            local name = self:getName()
            if not staminaBonus.events[name] then
                staminaBonus.events[name] = addEvent(addStamina, staminaBonus.period, name)
            end
		end
	end
	
    if(self:getPlayer() and self:getPlayer():getIp() == 0) then
        self:setTarget(nil)
    end
	
end