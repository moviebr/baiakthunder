function onStartup()
	BoostedCreature:start()
	if BoostedCreature.db then
		db.query(string.format("UPDATE `boost_creature` SET `name` = '%s', `exp` = %d, `loot` = %d", firstToUpper(boostCreature[1].name), boostCreature[1].exp, boostCreature[1].loot))
	end
	return true
end

function onThink(interval)
	Game.broadcastMessage(string.format(BoostedCreature.msg.showBoost, firstToUpper(boostCreature[1].name), boostCreature[1].loot, boostCreature[1].exp))
	return true
end