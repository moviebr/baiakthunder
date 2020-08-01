local bless = TalkAction("!bless")

local config = {
	bless = 5, -- Quantidade de blessing existentes
	precoPorLevel = 750, -- 500 gps a cada level
	msg = {
		msgDinheiro = "Você não possui %d gold coins para comprar as blesses.",
		msgBlessed = "Você foi abençoado!",
		msgTemBless = "Você já possui todas as blesses.",
	},

}

function bless.onSay(player, words, param)
	local precoReal = player:getLevel() * config.precoPorLevel
	
	for i = 1, config.bless do
		if player:hasBlessing(i) then
			player:sendCancelMessage(config.msg.msgTemBless)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end
	end

	if player:removeMoney(precoReal) then
		for i = 1, config.bless do
			player:addBlessing(i)
		end
		player:sendCancelMessage(config.msg.msgBlessed)
		player:getPosition():sendMagicEffect(50)
		player:say("[BLESS]", TALKTYPE_MONSTER_SAY)
	else
		player:sendCancelMessage(config.msg.msgDinheiro:format(precoReal))
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
	end
		
	return false
end

bless:register()