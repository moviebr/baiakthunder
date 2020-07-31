local square = TalkAction("!alvo")

squareGuild = {}

function repetirSquare(id, color)
    if not squareGuild[id] then
        return false
    end

    squareId = Player(squareGuild[id].alvo)

    if not squareId then
        return false
    end

    espectator = Game.getSpectators(squareId:getPosition(), true, true, 0, 7, 0, 7)
    for _, viewers in ipairs(espectator) do
        if viewers:getGuild() and viewers:getGuild():getId() == id then
            viewers:sendCreatureSquare(squareId, squareGuild[id].color)
        end
    end

    addEvent(repetirSquare, 500, id, color)
end

local config = {
    ["dourado"] = 204,
    ["azul"] = 5,
}

function square.onSay(player, words, param)

    if player:getStorageValue(984145) > os.time() then
        player:sendCancelMessage("Você precisa esperar o cooldown.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    if not param then
        player:sendCancelMessage("Você precisa informar o jogador e a cor do square (dourado ou azul)")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    local split = param:split(",")

    if not split[1] then
        player:sendCancelMessage("Você precisa informar o jogador.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    if not split[2] or not config[split[2]] then
        split[2] = "dourado"
    end


    local target = Player(split[1])
    if not target then
        player:sendCancelMessage("Esse player não existe ou não está online.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    local guild = player:getGuild()
    
    if not guild then
        player:sendCancelMessage("Você precisa fazer parte de alguma guild para usar esse comando.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    if player:getGuildLevel() < 2 then
        player:sendCancelMessage("Você precisa ser um líder ou vice-líder para usar esse comando.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    squareGuild[guild:getId()] = {alvo = split[1], color = config[split[2]]}
    repetirSquare(guild:getId(), config[split[2]])
    player:setStorageValue(984145, os.time() + 10 * 60)
    player:sendCancelMessage("O jogador ".. target:getName() .. " foi colocado em destaque até ele deslogar.")
    target:sendCancelMessage("Você foi colocado em destaque pela guild ".. guild:getName() ..".")
    target:getPosition():sendMagicEffect(7)

    return false
end

square:separator(" ")
square:register()