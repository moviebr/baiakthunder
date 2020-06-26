-- Por Movie
function onSay(player, words, param)
	local skill = player:getOnlineTime(player)
	local message = "--------[+]------- [Online Bonus System] -------[+]--------\n\nGanhe um online token a cada hora que você passa online sem deslogar.\n\n---------------------------------------------------\n                                                            Total\n             Desde o server save você já ganhou " .. skill .. " online tokens."
	doPlayerPopupFYI(player, message)
end

-- <talkaction words="!onlinebonus" script="onlineBonus.lua"/>