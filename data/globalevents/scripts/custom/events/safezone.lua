function onThink(interval)
	if SAFEZONE.days[os.date("%A")] then
		local hrs = tostring(os.date("%X")):sub(1, 5)
		if isInArray(SAFEZONE.days[os.date("%A")], hrs) then
			SAFEZONE:teleportCheck()
		end
	end
	return true
end