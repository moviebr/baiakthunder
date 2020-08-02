function onThink(interval)
	if BATTLEFIELD.days[os.date("%A")] then
		local hrs = tostring(os.date("%X")):sub(1, 5)
		if isInArray(BATTLEFIELD.days[os.date("%A")], hrs) then
			BATTLEFIELD:checkTeleport()
		end
	end
	return true
end