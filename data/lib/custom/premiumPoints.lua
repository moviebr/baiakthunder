function Player.getPremiumPoints(self)
    local resultId = db.storeQuery(string.format('SELECT premium_points FROM `accounts` WHERE `id` = %d', self:getAccountId()))
    if not resultId then
        return 0
    end

    local value = result.getNumber(resultId, "premium_points")
    result.free(resultId)
    return value
end

function Player.addPremiumPoints(self, amount)
    return db.query(string.format("UPDATE `accounts` SET `premium_points` = `premium_points` + %d WHERE `id` = %d", amount, self:getAccountId()))
end

function Player.removePremiumPoints(self, amount)
    if self:getPremiumPoints() >= amount then
        db.query(string.format("UPDATE `accounts` SET `premium_points` = `premium_points` - %d WHERE `id` = %d", amount, self:getAccountId()))
        return true
    else
        self:sendCancelMessage("Você não possui ".. amount .. " pontos para serem retirados.")
        self:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end
end

function Player.setPremiumPoints(self, amount)
	return db.query(string.format("UPDATE `accounts` SET `premium_points` = %d WHERE `id` = %d", amount, self:getAccountId()))
end