local effects = {
    {position = Position(986, 1216, 7), effect = 29},
    {position = Position(988, 1216, 7), effect = 29},
    {position = Position(987, 1217, 7), text = "[PREMIUM]"},
    {position = Position(982, 1208, 7), text = "Castle24H", effect = 18},
    {position = Position(983, 1208, 7), text = "SuperUP", effect = 18},
    {position = Position(985, 1208, 7), text = "Trainers", effect = 18},
    {position = Position(986, 1208, 7), text = "Hunts", effect = 18},
    {position = Position(996, 1208, 7), text = "Quests", effect = 18},
    {position = Position(997, 1208, 7), text = "NPCs", effect = 18},
    {position = Position(999, 1208, 7), text = "Cidades", effect = 18},
    {position = Position(1000, 1208, 7), text = "Depot", effect = 18},
    {position = Position(980, 1215, 7), text = "Mining", effect = 45},
}

function onThink(interval)
    for i = 1, #effects do
        local settings = effects[i]
        local spectators = Game.getSpectators(settings.position, false, true, 7, 7, 5, 5)
        if #spectators > 0 then
            if settings.text then
                for i = 1, #spectators do
                    spectators[i]:say(settings.text, TALKTYPE_MONSTER_SAY, false, spectators[i], settings.position)
                end
            end
            if settings.effect then
                settings.position:sendMagicEffect(settings.effect)
            end
        end
    end
   return true
end