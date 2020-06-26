if not Castle48H then Castle48H = {} end

Castle48H = {
	msg = {
		prefix = "[Castle48H] ",
		endEvent = "O evento acabou.",
	}
}

function Castle48H:open()

end

function Castle48H:enter(player)
	table.insert(Castle48H.players, player:getId())
end

function Castle48H:close()
	Game.broadcastMessage(Castle48H.msg.prefix .. Castle48H.msg.endEvent)
	for a, id in ipairs(Castle48H.players) do
		local player = Player(id)
		if player then
			player:teleportTo(player:getTown():getTemplePosition())
			Castle48H.players[a] = nil 
		end
	end
end


--[[
Castle48H = {
	players = {},
}
--]]