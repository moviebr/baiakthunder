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

function Creature:onTargetCombat(target)
   if not self then
        return true
    end

    if (self:isPlayer() and target:isNpc()) then
        self:say("hi", TALKTYPE_PRIVATE_PN, false, target)
        self:say("trade", TALKTYPE_PRIVATE_PN, false, target)
        return RETURNVALUE_NOTPOSSIBLE   
    end
	
    if(self:getPlayer() and self:getPlayer():getIp() == 0) then
        self:setTarget(nil)
    end
	
end