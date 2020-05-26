local effects = {
    {position = Position(986, 1216, 7), effect = 29},
    {position = Position(988, 1216, 7), effect = 29},
    {position = Position(987, 1217, 7), text = "[PREMIUM]", effect= 40},
    {position = Position(982, 1208, 7), text = "Arena", effect = 18},
    {position = Position(983, 1208, 7), text = "SuperUP", effect = 18},
    {position = Position(985, 1208, 7), text = "Trainers", effect = 18},
    {position = Position(986, 1208, 7), text = "Hunts", effect = 18},
    {position = Position(996, 1208, 7), text = "Quests", effect = 18},
    {position = Position(997, 1208, 7), text = "NPCs", effect = 18},
    {position = Position(999, 1208, 7), text = "Cidades", effect = 18},
    {position = Position(1000, 1208, 7), text = "Depot", effect = 18},
    {position = Position(980, 1215, 7), text = "Mining", effect = 45},
    {position = Position(996, 1217, 7), text = "Castle 24H", effect = 7},
    {position = Position(817, 1408, 7), text = "Wintermere", effect = 40},
    {position = Position(819, 1408, 7), text = "Shadow Wood", effect = 40},
    {position = Position(821, 1408, 7), text = "Akravi", effect = 40},
    {position = Position(825, 1408, 7), text = "Al Arar", effect = 40},
    {position = Position(827, 1408, 7), text = "Bhark", effect = 40},
    {position = Position(829, 1408, 7), text = "Jamila Island", effect = 40},
    {position = Position(823, 1415, 7), text = "Templo", effect = 40},
    {position = Position(1653, 1108, 8), text = "Voltar", effect = 45},
    {position = Position(1545, 1067, 4), text = "Saída", effect = 1},
    {position = Position(983, 1213, 8), text = "Free Addon", effect = 37},
    {position = Position(401, 1248, 7), text = "Templo", effect = 40},
    {position = Position(511, 1266, 7), text = "Templo", effect = 40},
    {position = Position(511, 1266, 6), text = "Templo", effect = 40},
    {position = Position(471, 1379, 6), text = "Hunts", effect = 49},
    {position = Position(472, 1379, 6), text = "Trainers", effect = 49},
    {position = Position(473, 1379, 6), text = "NPCs", effect = 49},
    {position = Position(477, 1379, 6), text = "Cidades", effect = 49},
    {position = Position(478, 1379, 6), text = "Bosses", effect = 49},
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