local auto = TalkAction("!autoaddmovie")

function auto.onSay(player, words, param)

	if not player:getGroup():getAccess() then
		return true
	end

	player:addAutoLootItem(param)
	print("add autoloot:".. param)
	return true
end

auto:separator(" ")
auto:register()

local check = TalkAction("!autocheck")

function check.onSay(player, words, param)

	if not player:getGroup():getAccess() then
		return true
	end

	for _, a in pairs(player:getAutoLootList()) do
		print("-AutoLoot List-")
		print(a)
		print("---")
	end
	return true
end


local remove = TalkAction("!autoremove")

function remove.onSay(player, words, param)

	if not player:getGroup():getAccess() then
		return true
	end

	player:removeAutoLootItem(param)
	print("removido do autoloot".. param)
	return true
end

remove:separator(" ")