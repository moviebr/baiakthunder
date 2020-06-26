function onThink(interval)
	if FSE.days[os.date("%A")] then
		local hrs = tostring(os.date("%X")):sub(1, 5)
		if isInArray(FSE.days[os.date("%A")], hrs) then
			FSE:Init()
		end
	end
	return true
end