local monstro = configManager.getBoolean(configKeys.SHOW_MONSTER_EXIVA)
local LEVEL_LOWER = 1
local LEVEL_SAME = 2
local LEVEL_HIGHER = 3

local DISTANCE_BESIDE = 1
local DISTANCE_CLOSE = 2
local DISTANCE_FAR = 3
local DISTANCE_VERYFAR = 4

local directions = {
	[DIRECTION_NORTH] = "norte",
	[DIRECTION_SOUTH] = "sul",
	[DIRECTION_EAST] = "leste",
	[DIRECTION_WEST] = "oeste",
	[DIRECTION_NORTHEAST] = "nordeste",
	[DIRECTION_NORTHWEST] = "noroeste",
	[DIRECTION_SOUTHEAST] = "sudeste",
	[DIRECTION_SOUTHWEST] = "sudoeste"
}

local messages = {
	[DISTANCE_BESIDE] = {
		[LEVEL_LOWER] = "está abaixo de você",
		[LEVEL_SAME] = "está de pé ao seu lado",
		[LEVEL_HIGHER] = "está acima de você"
	},
	[DISTANCE_CLOSE] = {
		[LEVEL_LOWER] = "está em um nível inferior a",
		[LEVEL_SAME] = "está para o",
		[LEVEL_HIGHER] = "está em um nível superior a"
	},
	[DISTANCE_FAR] = "está longe do",
	[DISTANCE_VERYFAR] = "é muito longe do"
}

function onCastSpell(creature, variant)
	local target = Player(variant:getString())
	if not target or target:getGroup():getAccess() and not creature:getGroup():getAccess() then
		creature:sendCancelMessage(RETURNVALUE_PLAYERWITHTHISNAMEISNOTONLINE)
		creature:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local targetPosition = target:getPosition()
	local creaturePosition = creature:getPosition()
	local positionDifference = {
		x = creaturePosition.x - targetPosition.x,
		y = creaturePosition.y - targetPosition.y,
		z = creaturePosition.z - targetPosition.z
	}

	local maxPositionDifference, direction = math.max(math.abs(positionDifference.x), math.abs(positionDifference.y))
	if maxPositionDifference >= 5 then
		local positionTangent = positionDifference.x ~= 0 and positionDifference.y / positionDifference.x or 10
		if math.abs(positionTangent) < 0.4142 then
			direction = positionDifference.x > 0 and DIRECTION_WEST or DIRECTION_EAST
		elseif math.abs(positionTangent) < 2.4142 then
			direction = positionTangent > 0 and (positionDifference.y > 0 and DIRECTION_NORTHWEST or DIRECTION_SOUTHEAST) or positionDifference.x > 0 and DIRECTION_SOUTHWEST or DIRECTION_NORTHEAST
		else
			direction = positionDifference.y > 0 and DIRECTION_NORTH or DIRECTION_SOUTH
		end
	end

	local level = positionDifference.z > 0 and LEVEL_HIGHER or positionDifference.z < 0 and LEVEL_LOWER or LEVEL_SAME
	local distance = maxPositionDifference < 5 and DISTANCE_BESIDE or maxPositionDifference < 101 and DISTANCE_CLOSE or maxPositionDifference < 275 and DISTANCE_FAR or DISTANCE_VERYFAR
	local message = messages[distance][level] or messages[distance]
	if distance ~= DISTANCE_BESIDE then
		message = message .. " " .. directions[direction]
	end

	local targetId = target:getId()
	local tabela = tabelaExiva[targetId]
	if tabela and monstro then
		message = message .. ".\nO último monstro morto por ".. target:getName() .. " foi " .. tabelaExiva[targetId][1] .." " .. string.diff((os.time() - tabelaExiva[targetId][2]), true) .. " atrás"
	end

	creature:sendTextMessage(MESSAGE_INFO_DESCR, target:getName() .. " " .. message .. ".")
	creaturePosition:sendMagicEffect(CONST_ME_MAGIC_BLUE)
	return true
end
