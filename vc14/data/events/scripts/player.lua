function Player:onLook(thing, position, distance)
	local minDist = 5
	if (thing:isCreature() and thing:isNpc() and distance <= minDist) then
       self:say("hi", TALKTYPE_PRIVATE_PN, false, thing)
       self:say("trade", TALKTYPE_PRIVATE_PN, false, thing)
       return false
   end
	local description = "Você vê " .. thing:getDescription(distance)
	
	if LOOK_MARRIAGE_DESCR and thing:isCreature() then
        if thing:isPlayer() and not thing:getGroup():getAccess() then
            description =  description .. self:getMarriageDescription(thing)
        end
    end
	
	if self:getGroup():getAccess() then
		if thing:isItem() then
			description = string.format("%s\nItem ID: %d", description, thing:getId())

			local actionId = thing:getActionId()
			if actionId ~= 0 then
				description = string.format("%s, Action ID: %d", description, actionId)
			end

			local uniqueId = thing:getAttribute(ITEM_ATTRIBUTE_UNIQUEID)
			if uniqueId > 0 and uniqueId < 65536 then
				description = string.format("%s, Unique ID: %d", description, uniqueId)
			end

			local itemType = thing:getType()

			local transformEquipId = itemType:getTransformEquipId()
			local transformDeEquipId = itemType:getTransformDeEquipId()
			if transformEquipId ~= 0 then
				description = string.format("%s\nTransforma para: %d (onEquip)", description, transformEquipId)
			elseif transformDeEquipId ~= 0 then
				description = string.format("%s\nTransforma para: %d (onDeEquip)", description, transformDeEquipId)
			end

			local decayId = itemType:getDecayId()
			if decayId ~= -1 then
				description = string.format("%s\nDecai para: %d", description, decayId)
			end
		elseif thing:isCreature() then
			local str = "%s\nVida: %d / %d"
			if thing:isPlayer() and thing:getMaxMana() > 0 then
				str = string.format("%s, Mana: %d / %d", str, thing:getMana(), thing:getMaxMana())
			end
			description = string.format(str, description, thing:getHealth(), thing:getMaxHealth()) .. "."
		end

		local position = thing:getPosition()
		description = string.format(
			"%s\nPosição: %d, %d, %d",
			description, position.x, position.y, position.z
		)

		if thing:isCreature() then
			if thing:isPlayer() then
				description = string.format("%s\nIP: %s.", description, Game.convertIpToString(thing:getIp()))
			end
		end
	end
	if thing:isCreature() then
		if thing:isPlayer() and not thing:getGroup():getAccess() then
			description = string.format("%s\nTask Rank: "..getRankTask(thing), description)
		end
	end
	self:sendTextMessage(MESSAGE_INFO_DESCR, description)
	
	if thing:isPlayer() and not self:getGroup():getAccess() then
        thing:sendTextMessage(MESSAGE_STATUS_DEFAULT, self:getName() .. ' está olhando para você.')
    end
	
end

function Player:onLookInBattleList(creature, distance)
	local minDist = 5
	if (thing:isCreature() and thing:isNpc() and distance <= minDist) then
       self:say("hi", TALKTYPE_PRIVATE_PN, false, thing)
       self:say("trade", TALKTYPE_PRIVATE_PN, false, thing)
       return false   
   end
	local description = "Você vê " .. creature:getDescription(distance)
	if self:getGroup():getAccess() then
		local str = "%s\nVida: %d / %d"
		if creature:isPlayer() and creature:getMaxMana() > 0 then
			str = string.format("%s, Mana: %d / %d", str, creature:getMana(), creature:getMaxMana())
		end
		description = string.format(str, description, creature:getHealth(), creature:getMaxHealth()) .. "."

		local position = creature:getPosition()
		description = string.format(
			"%s\nPosição: %d, %d, %d",
			description, position.x, position.y, position.z
		)

		if creature:isPlayer() then
			description = string.format("%s\nIP: %s", description, Game.convertIpToString(creature:getIp()))
		end
	end
	if thing:isCreature() then
		if thing:isPlayer() and not thing:getGroup():getAccess() then
			description = string.format("%s\nTask Rank: "..getRankTask(thing), description)
		end
	end
	self:sendTextMessage(MESSAGE_INFO_DESCR, description)
	
	if creature:isPlayer() and not self:getGroup():getAccess() then
        creature:sendTextMessage(MESSAGE_STATUS_DEFAULT, self:getName() .. ' está olhando para você.')
    end
	
end

function Player:onLookInTrade(partner, item, distance)
	self:sendTextMessage(MESSAGE_INFO_DESCR, "Você vê " .. item:getDescription(distance))
	return true
end

function Player:onLookInShop(itemType, count)
	return true
end

function Player:onMoveItem(item, count, fromPosition, toPosition, fromCylinder, toCylinder)
	local antiTrash = true
    local antiTheft = true
    if antiTrash then
    local tile = Tile(toPosition)
        if tile and tile:hasFlag(TILESTATE_HOUSE) then
        local house = tile:getHouse()
            if house then
                local accessList = House.getAccessList
                local playerName = self:getName():lower()
                if house ~= self:getHouse() and (playerName ~= accessList(house, GUEST_LIST):lower() or playerName ~= accessList(house, SUBOWNER_LIST):lower()) then
                    self:sendTextMessage(MESSAGE_STATUS_SMALL, "Você não pode jogar itens nas casas dos jogadores, para os quais não está convidado.")
                    return false
                end
            end
        end
    end

    if antiTheft then
    	local tile = Tile(fromPosition)
        if tile and tile:hasFlag(TILESTATE_HOUSE) then
            local house = tile:getHouse()
            if house then
                if house ~= self:getHouse() and self:getName():lower() ~= house:getAccessList(SUBOWNER_LIST):lower() then
                    self:sendTextMessage(MESSAGE_STATUS_SMALL, "Você não pode mover itens da casa, dos quais você é apenas convidado.")
                    return false
                end
            end
        end
    end    
	return true
end

function Player:onItemMoved(item, count, fromPosition, toPosition, fromCylinder, toCylinder)

end

function Player:onMoveCreature(creature, fromPosition, toPosition)
	return true
end

local function hasPendingReport(name, targetName, reportType)
	local f = io.open(string.format("data/reports/players/%s-%s-%d.txt", name, targetName, reportType), "r")
	if f then
		io.close(f)
		return true
	else
		return false
	end
end

function Player:onReportRuleViolation(targetName, reportType, reportReason, comment, translation)
	local name = self:getName()
	if hasPendingReport(name, targetName, reportType) then
		self:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Seu report está sendo processado.")
		return
	end

	local file = io.open(string.format("data/reports/players/%s-%s-%d.txt", name, targetName, reportType), "a")
	if not file then
		self:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Ocorreu um erro ao processar seu report, entre em contato com um gamemaster.")
		return
	end

	io.output(file)
	io.write("------------------------------\n")
	io.write("Reportado por: " .. name .. "\n")
	io.write("Alvo: " .. targetName .. "\n")
	io.write("Tipo: " .. reportType .. "\n")
	io.write("Razão: " .. reportReason .. "\n")
	io.write("Comentário: " .. comment .. "\n")
	if reportType ~= REPORT_TYPE_BOT then
		io.write("Translation: " .. translation .. "\n")
	end
	io.write("------------------------------\n")
	io.close(file)
	self:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Obrigado pelo seu report, %s. Seu report será processado pela equipe o mais rápido possível.", targetName, configManager.getString(configKeys.SERVER_NAME)))
	return
end

function Player:onReportBug(message, position, category)
	if self:getAccountType() == ACCOUNT_TYPE_NORMAL then
		return false
	end

	local name = self:getName()
	local file = io.open("data/reports/bugs/" .. name .. " report.txt", "a")

	if not file then
		self:sendTextMessage(MESSAGE_EVENT_DEFAULT, "Ocorreu um erro ao processar seu report, entre em contato com um gamemaster.")
		return true
	end

	io.output(file)
	io.write("------------------------------\n")
	io.write("Nome: " .. name)
	if category == BUG_CATEGORY_MAP then
		io.write(" [Posição no mapa: " .. position.x .. ", " .. position.y .. ", " .. position.z .. "]")
	end
	local playerPosition = self:getPosition()
	io.write(" [Posição do Player: " .. playerPosition.x .. ", " .. playerPosition.y .. ", " .. playerPosition.z .. "]\n")
	io.write("Comentário: " .. message .. "\n")
	io.close(file)

	self:sendTextMessage(MESSAGE_EVENT_DEFAULT, "Seu report foi enviado para " .. configManager.getString(configKeys.SERVER_NAME) .. ".")
	return true
end

function Player:onTurn(direction)
	return true
end

function Player:onTradeRequest(target, item)
	local blockList = {7879, 7878, 7882, 8858, 7872, 12644, 8908, 2523} -- ID

	if isInArray(blockList, item:getId()) then
		self:sendCancelMessage("Você não pode trocar esse item.")
		self:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	return true
end

function Player:onTradeAccept(target, item, targetItem)
	return true
end

local soulCondition = Condition(CONDITION_SOUL, CONDITIONID_DEFAULT)
soulCondition:setTicks(4 * 60 * 1000)
soulCondition:setParameter(CONDITION_PARAM_SOULGAIN, 1)

local function useStamina(player)
	local staminaMinutes = player:getStamina()
	if staminaMinutes == 0 then
		return
	end

	local playerId = player:getId()
	local currentTime = os.time()
	local timePassed = currentTime - nextUseStaminaTime[playerId]
	if timePassed <= 0 then
		return
	end

	if timePassed > 60 then
		if staminaMinutes > 2 then
			staminaMinutes = staminaMinutes - 2
		else
			staminaMinutes = 0
		end
		nextUseStaminaTime[playerId] = currentTime + 120
	else
		staminaMinutes = staminaMinutes - 1
		nextUseStaminaTime[playerId] = currentTime + 60
	end
	player:setStamina(staminaMinutes)
end

function Player:onGainExperience(source, exp, rawExp)
	if not source or source:isPlayer() then
		return exp
	end

	-- Soul regeneration
	local vocation = self:getVocation()
	if self:getSoul() < vocation:getMaxSoul() and exp >= self:getLevel() then
		soulCondition:setParameter(CONDITION_PARAM_SOULTICKS, vocation:getSoulGainTicks() * 1000)
		self:addCondition(soulCondition)
	end

	-- Apply experience stage multiplier
	exp = exp * Game.getExperienceStage(self:getLevel())

	-- Stamina modifier
	if configManager.getBoolean(configKeys.STAMINA_SYSTEM) then
		useStamina(self)

		local staminaMinutes = self:getStamina()
		if staminaMinutes > 2400 and self:isPremium() then
			exp = exp * 1.5
		elseif staminaMinutes <= 840 then
			exp = exp * 0.5
		end
	end
	
	-- Premium
	if self:isPremium() then
		local expPremium = 1.2
		exp = exp * expPremium
	end
	
	-- Castle 24H
	local guild = self:getGuild()
	if not guild then
        return exp
    end
	
	if self:getGuild():getId() == getGuildIdFromCastle() then
		local expCastle = 1.2 -- 20% a mais de exp
		exp = exp * expCastle
	end

	return exp
end

function Player:onLoseExperience(exp)
	return exp
end

function Player:onGainSkillTries(skill, tries)
	if APPLY_SKILL_MULTIPLIER == false then
		return tries
	end

	if skill == SKILL_MAGLEVEL then
		return tries * configManager.getNumber(configKeys.RATE_MAGIC)
	end
	return tries * configManager.getNumber(configKeys.RATE_SKILL)
end
