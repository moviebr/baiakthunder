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
	period = 180000,
    periodPremium = 120000,
	bonus = 1,
    events = {},
    players = {},
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
            if player:isPremium() then
                player:setStamina(player:getStamina() + staminaBonus.bonus)
                staminaBonus.events[name] = addEvent(addStamina, staminaBonus.periodPremium, name)
            else
                player:setStamina(player:getStamina() + staminaBonus.bonus)
                staminaBonus.events[name] = addEvent(addStamina, staminaBonus.period, name)
            end
		end
	end
end

checkIp = function(name)
    local player = Player(name)
    if not player then
        ipPlayers[name] = nil
    else
        if player:getIp() == 0 then
            ipPlayers[name] = nil
            player:setTarget(nil)
            player:teleportTo(player:getTown():getTemplePosition())
            player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
            return
        end

        ipPlayers[name] = addEvent(checkIp, 30000, player:getName())
    end
end

function Creature:onTargetCombat(target)
    ipPlayers = {}

   if not self then
        return true
    end

    local name = self:getName()

    if (self:isPlayer() and target:isNpc()) then
        self:say("hi", TALKTYPE_PRIVATE_PN, false, target)
        self:say("trade", TALKTYPE_PRIVATE_PN, false, target)
        return RETURNVALUE_NOTPOSSIBLE   
    end

    if self:isPlayer() then
        if target and target:getName() == staminaBonus.target then
            if not ipPlayers[name] then
                ipPlayers[name] = addEvent(checkIp, 30000, name)
            end
            if not staminaBonus.events[name] then
                staminaBonus.events[name] = addEvent(addStamina, staminaBonus.period, name)
            end
		end
    end
	
end