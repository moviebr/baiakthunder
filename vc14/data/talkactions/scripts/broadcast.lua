function onSay(player, words, param)
	player:addAutoLootItem(param)
	for _, a in pairs(player:getAutoLootList()) do
		print(a)
	end
	return false
end
