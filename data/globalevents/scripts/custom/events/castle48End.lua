function onTime(interval)
	Game.broadcastMessage(Castle48H.msg.prefix .. Castle48H.msg.endingEvent:format(5))
	addEvent(function()
		Castle48H:close()
	end, 5 * 60 * 1000)
	return true
end
