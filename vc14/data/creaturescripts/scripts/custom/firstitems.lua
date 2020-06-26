local config = {
	[1] = {
		items = {{2457, 1}, {2463, 1}, {2647, 1}, {2195, 1}, {2516, 1}, {2184,1}, {2173, 1}, {2124, 1}},
		container = {{2789, 50}, {2160, 5}, {7620, 1}, {7618, 1}, {2554, 1}, {2120, 1}}
	},
	[2] = {
		items = {{2457, 1}, {2463, 1}, {2647, 1}, {2195, 1}, {2516, 1}, {2184,1}, {2173, 1}, {2124, 1}},
		container = {{2789, 50}, {2160, 5}, {7620, 1}, {7618, 1}, {2554, 1}, {2120, 1}}
	},
	[3] = {
		items = {{2457, 1}, {2463, 1}, {2647, 1}, {2195, 1}, {2516, 1}, {2399, 1}, {2173, 1}, {2124, 1}},
		container = {{2789, 50}, {2160, 5}, {7620, 1}, {7618, 1}, {2554, 1}, {2120, 1}}
	},
	[4] = {
		items = {{2457, 1}, {2463, 1}, {2647, 1}, {2195, 1}, {2516, 1}, {7449, 1}, {2173, 1}, {2124, 1}},
		container = {{2789, 50}, {2160, 5}, {7620, 1}, {7618, 1}, {2554, 1}, {2120, 1}}
	}
}

function onLogin(player)
	local targetVocation = config[player:getVocation():getId()]
	if not targetVocation then
		return true
	end

	if player:getLastLoginSaved() ~= 0 then
		return true
	end

	if (player:getSlotItem(CONST_SLOT_LEFT)) then
		return true
	end

	for i = 1, #targetVocation.items do
		player:addItem(targetVocation.items[i][1], targetVocation.items[i][2])
	end

	local backpack = player:getVocation():getId() == 0 and player:addItem(1987) or player:addItem(1988)
	if not backpack then
		return true
	end

	for i = 1, #targetVocation.container do
		backpack:addItem(targetVocation.container[i][1], targetVocation.container[i][2])
	end
	return true
end
