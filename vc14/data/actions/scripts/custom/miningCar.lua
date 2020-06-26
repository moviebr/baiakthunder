local teleport = Position(1652, 1108, 8)
local teleportBack = Position(981, 1214, 7)
local miningUm = Position(980, 1215, 7)

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item:getPosition() == miningUm then
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendCancelMessage("Você foi teletransportado para a área de mining.")
		player:teleportTo(teleport)
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	else
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendCancelMessage("Você foi teletransportado de volta.")
		player:teleportTo(teleportBack)
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	end

	return true
end