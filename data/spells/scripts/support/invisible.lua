local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

local condition = Condition(CONDITION_INVISIBLE)
condition:setParameter(CONDITION_PARAM_TICKS, 200000)
combat:addCondition(condition)

function onCastSpell(creature, variant)
	if creature:isPlayer() and creature:getStorageValue(STORAGEVALUE_EVENTS) >= 1 then
		creature:sendTextMessage(MESSAGE_INFO_DESCR, "Você não usar essa magia enquanto estiver dentro de um evento.")
		return false
	end

	return combat:execute(creature, variant)
end
