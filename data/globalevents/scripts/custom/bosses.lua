dofile('data/lib/custom/bosses.lua')
function onThink(interval)
	verificarDiaeHorario()
	return true
end