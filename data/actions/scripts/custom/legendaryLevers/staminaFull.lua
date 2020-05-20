local lever = {

	{itemid = 8851, amount = 1, chance = 5, broadcast = true},
	{itemid = 8300, amount = 1, chance = 12, broadcast = false},
	{itemid = 9971, amount = 50, chance = 25, broadcast = false},
	{itemid = 7253, amount = 1, chance = 65, broadcast = false},
}

lever.onlypremium = false
lever.coust = 10000


function onUse(player, item) 
	return randomitems:random(player, lever, 2, item)
end