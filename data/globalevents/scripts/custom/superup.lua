function onThink(interval)

    local ricardoViado = SUPERUP:freeCave()

    for _, b in pairs(ricardoViado) do
        if os.time() >= b[2] then
           db.query(string.format("UPDATE exclusive_hunts SET `guid_player` = %d, `time` = %s, `to_time` = %s WHERE `hunt_id` = %d", 0, 0, 0, b[1]))
        end
    end
    return true
end