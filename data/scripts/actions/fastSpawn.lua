local fastSpawn = Action()

function fastSpawn.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local rate = Game.getSpawnRate()
	local text = "                     [Respawn Rápido]\n-----------------------------\nO respawn do servidor varia de acordo com o número de jogadores online para compensar a sua hunt.\n-----------------------------\nO respawn atual do servidor está "

	if rate == 1 then
		text = text .. "Normal!"
	else
		text = text .. rate .."x mais rápido!"
	end
	
	player:showTextDialog(item:getId(), text)
	return true
end

fastSpawn:uid(6214)
fastSpawn:register()