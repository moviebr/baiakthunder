function onKill(player, target)
    if not target:isMonster() then
        return true
    end

    if not player or not target then
        return true
    end

    local playerId = player:getId()

    tabelaExiva[playerId] = {target:getName(), os.time()}
    return true
end