function Player.getOnlineTime(self)
    local resultId = db.storeQuery(string.format('SELECT online_time FROM `players` WHERE `id` = %d', self:getGuid()))
    if not resultId then
        return 0
    end

    local value = result.getNumber(resultId, "online_time")
    result.free(resultId)
    return value
end

function Player.addOnlineTime(self, amount)
    db.query(string.format("UPDATE `players` SET `online_time` = `online_time` + %d WHERE `id` = %d", amount, self:getGuid()))
end