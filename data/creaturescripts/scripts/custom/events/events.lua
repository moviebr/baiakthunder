function onPrepareDeath(player, killer)
	local getTeamRed = Game.getStorageValue(BATTLEFIELD.storageTeamRed)
	local getTeamBlue = Game.getStorageValue(BATTLEFIELD.storageTeamBlue)
	if player:getStorageValue(BATTLEFIELD.storageTeam) == 1 then
		Game.setStorageValue(BATTLEFIELD.storageTeamBlue, (getTeamBlue - 1))
	elseif player:getStorageValue(BATTLEFIELD.storageTeam) == 2 then
		Game.setStorageValue(BATTLEFIELD.storageTeamRed, (getTeamRed - 1))
	end
	player:setStorageValue(STORAGEVALUE_EVENTS, 0)
	player:setStorageValue(BATTLEFIELD.storageTeam, 0)
	return true
end