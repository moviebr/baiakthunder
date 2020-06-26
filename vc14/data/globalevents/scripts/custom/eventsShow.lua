local EventsList = {
    ["Sunday"] = {
		{name = "SnowBall", time = "10:00"},
		{name = "Battlefield", time = "15:00"},
		{name = "SafeZone", time = "20:00"},
    },
    ["Monday"] = {
		{name = "SnowBall", time = "10:00"},
		{name = "Battlefield", time = "15:00"},
		{name = "SafeZone", time = "20:00"},
    },
    ["Tuesday"] = {
		{name = "SnowBall", time = "10:00"},
		{name = "Battlefield", time = "15:00"},
		{name = "SafeZone", time = "20:00"},
    },
    ["Wednesday"] = {
		{name = "SnowBall", time = "10:00"},
		{name = "Battlefield", time = "15:00"},
		{name = "SafeZone", time = "20:00"},
    },
    ["Thursday"] = {
		{name = "SnowBall", time = "10:00"},
		{name = "Battlefield", time = "15:00"},
		{name = "SafeZone", time = "20:00"},
    },
    ["Friday"] = {
		{name = "SnowBall", time = "10:00"},
		{name = "Battlefield", time = "15:00"},
		{name = "SafeZone", time = "20:00"},
    },
}

local position = Position(1003, 1217, 7)

function onThink(interval, lastExecution)
	local spectators = Game.getSpectators(position, false, true, 7, 7, 5, 5)
	local event = EventsList[os.date("%A")]
	for a, b in pairs(event) do
		local eventTime = b.time
		local realTime = (os.date("%H:%M:%S"))
		if eventTime >= realTime then
	    	if #spectators > 0 then
        		for i = 1, #spectators do
        			local tile = Tile(position)
        			if tile then
        				local item = tile:getItemById(1387)
        				if item then
        					spectators[i]:say("Participe agora\ndo evento!", TALKTYPE_MONSTER_SAY, false, spectators[i], position)
        					position:sendMagicEffect(56)
        					position:sendMagicEffect(57)
        				else
        					spectators[i]:say("Próximo evento:\n"..b.name.." às "..b.time..".", TALKTYPE_MONSTER_SAY, false, spectators[i], position)
        					position:sendMagicEffect(40)
        				end
        			end
                end
        	end
	    end
	    break
 	end
	return true
end