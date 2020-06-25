if not boostCreature then boostCreature = {} end

BoostedCreature = {
	monsters = {"Rotworm", "Demon", "Frost Dragon", "Grim Reaper"},
	db = true,
	exp = {3, 15},
	loot = {3, 15},
	position = Position(987, 1214, 8),
	msg = {
		showBoost = "[Boosted Creature] A criatura %s foi a escolhida, adicionado +%d% de loot e +%d% de experiência.",
	}
}

function BoostedCreature:start()
	local rand = math.random
	local monsterRand = BoostedCreature.monsters[rand(#BoostedCreature.monsters)]
	local expRand = rand(BoostedCreature.exp[1], BoostedCreature.exp[2])
	local lootRand = rand(BoostedCreature.loot[1], BoostedCreature.loot[2])
	table.insert(boostCreature, {name = monsterRand:lower(), exp = expRand, loot = lootRand})
	local monster = Game.createMonster(boostCreature[1].name, BoostedCreature.position, false, true)
	monster:setDirection(WEST)
end