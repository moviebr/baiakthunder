function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	local steps = tonumber(param)

	local position = player:getPosition()
	position:getNextPosition(player:getDirection(), steps)

	position = player:getClosestFreePosition(position, false)
	if position.x == 0 then
		player:sendCancelMessage("You cannot teleport there.")
		return false
	end

	player:teleportTo(position, true)
	return false
end
