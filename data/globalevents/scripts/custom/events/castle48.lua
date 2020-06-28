function onThink(interval)
	if Castle48H.days[os.date("%A")] then
		local hrs = tostring(os.date("%X")):sub(1, 5)
		if isInArray(Castle48H.days[os.date("%A")], hrs) then
			Castle48H:open()
		end
	end
	return true
end
