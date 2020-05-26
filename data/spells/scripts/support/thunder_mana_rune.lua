local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, FALSE)

function onCastSpell(creature, variant)
	local player = Creature(variant.number)
	if not player:isPlayer() then
		return combat:execute(creature, variant)
	end
	local random = math.random(230, 320)
	player:addMana(random, true)
	player:say("Aaaah...", TALKTYPE_MONSTER_SAY)
	player:getPosition():sendMagicEffect(58)
	return combat:execute(creature, variant)
end