local config = {
    storage = 84151,
    vida = 5000,
    vidaAdd = 20000,
    tempoStorage = 5, -- Em segundos
}

function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)

    if attacker then
        if (creature:getHealth() <= config.vida) and Game.getStorageValue(config.storage) ~= 1 then
            creature:say("EU SOU IMORTAL!", TALKTYPE_MONSTER_SAY)
            creature:addHealth(config.vidaAdd)
            creature:getPosition():sendMagicEffect(18)
            Game.setStorageValue(config.storage, 1)
            addEvent(Game.setStorageValue, config.tempoStorage * 1000, config.storage, 0)
        end
    end

    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

function onDeath(player, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)

	local creature = player
	if creature then
		creature:say("EU IREI RETORNAR!", TALKTYPE_MONSTER_SAY)
	end
	killer:say("[LAST HIT]", TALKTYPE_MONSTER_SAY)
end
