DODGE = {
	LEVEL_MAX = 100, -- máximo de dodge level que o player pode alcançar
	PERCENT = 0.2 -- porcentagem que irá defender o ataque [padrão 50% = 0.5]
}

CRITICAL = {
	LEVEL_MAX = 100, -- máximo de critical level que o player pode alcançar
	PERCENT = 0.2 -- porcentagem que irá aumentar o ataque [padrão 50% = 0.5]
}

function Player.getDodgeLevel(self)
	return self:getStorageValue(STORAGEVALUE_DODGE)
end

function Player.setDodgeLevel(self, value)
	return self:setStorageValue(STORAGEVALUE_DODGE, value)
end

function Player.getCriticalLevel(self)
	return self:getStorageValue(STORAGEVALUE_CRITICAL)
end

function Player.setCriticalLevel(self, value)
	return self:setStorageValue(STORAGEVALUE_CRITICAL, value)
end