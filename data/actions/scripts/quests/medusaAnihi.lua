local config = {
	oldPosition = {
		[1] = Position(945, 1410, 8),
		[2] = Position(944, 1410, 8),
		[3] = Position(943, 1410, 8),
		[4] = Position(942, 1410, 8),
		[5] = Position(941, 1410, 8),
	},
	newPosition = {
		[1] = Position(943, 1429, 8),
		[2] = Position(942, 1429, 8),
		[3] = Position(941, 1429, 8),
		[4] = Position(940, 1429, 8),
		[5] = Position(939, 1429, 8),
	},
	players = {},
	tempoCooldown = 4, -- Em horas
	storageTempo = 717141,
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	
	if Game.getStorageValue(config.storageTempo) >= os.time() then
		player:sendCancelMessage("O seu time precisa esperar ".. string.diff((os.time() - config.storageTempo), true) .. " para fazer essa quest.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	if item.itemid == 1945 then
		for i = 1, #config.oldPosition do
			local topPlayer = Tile(config.oldPosition[i]):getTopCreature()
			if not topPlayer or not topPlayer:isPlayer() then
				player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
				return false
			end
			config.players[#config.players + 1] = topPlayer
		end

		if #config.players < #config.oldPosition then
			player:sendCancelMessage("Seu time precisa de pelo menos ".. #config.oldPosition .. " players para fazer essa quest.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			for i = 1, #config.players do
				config.players[i] = nil
			end
			return true
		end

		for i, targetPlayer in ipairs(config.players) do
			Position(config.oldPosition[i]):sendMagicEffect(CONST_ME_POFF)
			targetPlayer:teleportTo(config.newPosition[i], false)
			targetPlayer:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		end

		Game.setStorageValue(config.storageTempo, config.tempoCooldown * 60 * 60)
		item:transform(1946)
		addEvent(function()
			item:transform(1945)
		end, 30 * 60 * 60 * 1000)

	elseif item.itemid == 1946 then
		player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
	end
	return true
end
