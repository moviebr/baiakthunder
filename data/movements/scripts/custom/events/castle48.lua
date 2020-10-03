function onStepIn(creature, item, position, fromPosition)

	local player = creature:getPlayer()
	if not player then
		return true
	end

	if not player:getGuild() then
		player:sendCancelMessage(Castle48H.msg.prefix .. Castle48H.msg.notGuild)
		player:teleportTo(fromPosition, true)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	if player:getLevel() < Castle48H.levelMin then
		player:sendCancelMessage(Castle48H.msg.prefix .. Castle48H.msg.levelMin:format(Castle48H.levelMin, " ou maior para entrar no castelo"))
		player:teleportTo(fromPosition, true)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	if item.actionid == Castle48H.actionIDEnter then
		if Game.getStorageValue(Castle48H.storageGlobal) ~= 1 then
			player:sendCancelMessage(Castle48H.msg.prefix .. Castle48H.msg.notOpen)
			player:teleportTo(fromPosition, true)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
		else
			Castle48H.insertPlayer(player:getId())
			return true
		end
	elseif item.actionid == Castle48H.actionIDExit then
		Castle48H.deletePlayer(player:getId())
		return true
	end

	return true
end
