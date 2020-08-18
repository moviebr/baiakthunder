function onThink(interval)
	if MONSTER_HUNT.days[os.date("%A")] then
		local hrs = tostring(os.date("%X")):sub(1, 5)
		if isInArray(MONSTER_HUNT.days[os.date("%A")], hrs) then
			MONSTER_HUNT:initEvent()
		end
	end
	return true
end

function onTime(interval)
	MONSTER_HUNT:endEvent()
	return true
end