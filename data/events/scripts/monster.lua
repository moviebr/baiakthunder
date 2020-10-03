function Monster:onDropLoot(corpse)

	local mType = self:getType()
	if mType:isRewardBoss() then
		corpse:registerReward()
		return
	end

	if configManager.getNumber(configKeys.RATE_LOOT) == 0 then
		return
	end

	local player = Player(corpse:getCorpseOwner())
	local mType = self:getType()
	if not player or player:getStamina() > 840 then
		local monsterLoot = mType:getLoot()

		-- Boost Loot
		local percentLoot = 0
		if player:getStorageValue(STORAGEVALUE_LOOT_TEMPO) > os.time() then
			local potion = lootPotion[player:getStorageValue(STORAGEVALUE_LOOT_ID)]
			if potion then
				percentLoot = (potion.exp / 100)
			end
		end

		-- Boost Creature
		local percent = 0
		if (mType:getName():lower() == boostCreature[1].name) then
			percent = (boostCreature[1].loot / 100)
		end

		for i = 1, #monsterLoot do
			monsterLoot[i].chance = monsterLoot[i].chance + (monsterLoot[i].chance * percent) + (monsterLoot[i].chance * percentLoot)
			local item = corpse:createLootItem(monsterLoot[i])
			if not item then
				print('[Warning] DropLoot:', 'Could not add loot item to corpse.')
			end
		end

		if player then
			local text = ("Loot de %s: %s"):format(mType:getNameDescription(), corpse:getContentDescription())
			local party = player:getParty()
			if party then
				party:broadcastPartyLoot(text)
			else
				if player:getStorageValue(STORAGEVALUE_LOOT) == 1 then
					sendChannelMessage(11, TALKTYPE_CHANNEL_O, text)
				else
					player:sendTextMessage(MESSAGE_INFO_DESCR, text)
				end
			end
		end
	else
		local text = ("Loot de %s: nada (devivo à baixa stamina)"):format(mType:getNameDescription())
		local party = player:getParty()
		if party then
			party:broadcastPartyLoot(text)
		else
			if player:getStorageValue(STORAGEVALUE_LOOT) == 1 then
				sendChannelMessage(11, TALKTYPE_CHANNEL_O, text)
			else
				player:sendTextMessage(MESSAGE_INFO_DESCR, text)
			end
		end
	end
end
