local config = {
    min = 20000,        -- Valor Minimo da Aposta
    max = 100000000,     -- Valor Máximo da Aposta
    multiplyby = 2,    -- Quanto o valor será multiplicado caso o jogador ganhe
    automatic = true,  -- O NPC irá falar com o player automáticamente
    delay = 2,         -- Tempo em segundos em que o player poderá falar com o NPC novamente 
    position = {
        player = Position(422, 195, 7),  -- Posição que o player deve estar
        money = Position(423, 196, 7),   -- Posição do dinheiro
        dice = Position(424, 196, 7)     -- Posição de onde estará o dado
    },
    effects = {
        win = CONST_ME_SOUND_RED, -- Efeito no player caso ele ganhe
        lose = CONST_ME_POFF      -- Efeito no player caso ele perca
    },
    direction = {
        talking = DIRECTION_WEST,  -- Posição na qual estara o NPC caso esteja conversando
        stopped = DIRECTION_SOUTH  -- Posição na qual estara o NPC caso esteja parado
    }
}

local dices = {
    [1] = 5792, -- Dado com número 1
    [2] = 5793, -- Dado com número 2
    [3] = 5794, -- Dado com número 3
    [4] = 5795, -- Dado com número 4
    [5] = 5796, -- Dado com número 5
    [6] = 5797  -- Dado com número 6
}

local coins = {
    [2148] = 1,    -- Gold coin
    [2152] = 100,  -- Platinum coin
    [2160] = 10000, -- Crystal coin
    [9971] = 1000000
}

local player = nil
local money = 0
local npc = nil
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)              npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)           npcHandler:onCreatureDisappear(cid)         end
function onCreatureSay(cid, type, msg)      npcHandler:onCreatureSay(cid, type, msg)    end
function onThink(cid)                       npcHandler:onThink(cid)                        end

local function greetCallback(cid)
    local player = Player(cid)

    if not playerIsInPosition(player) then
        return false
    end

    return true
end

local function creatureSayCallback(cid, type, msg)
    if not player then
        player = Player(cid)
    end

    if not npcHandler:isFocused(cid) or player:getStorageValue(7239) >= os.time() then
        return false
    end
    
    player:setStorageValue(7239, os.time() + 2)

    local sorted = math.random(1, 6)
    local tile = Tile(config.position.dice)
    local status = false

    if msg:lower() == "l" or msg:lower() == "low" then
        status = (sorted < 4 and true or false)
    elseif msg:lower() == "h" or msg:lower() == "high" then
        status = (sorted > 3 and true or false)
    else
        return false
    end

    if not removeMoney() then
        return false
    end

    if player then 
        npcHandler:say((status and "VOCÊ GANHOU!" or "VOCÊ PERDEU!"), cid)
    end

    for i = 1, 6 do
        if tile:getItemById(dices[i]) then
            local dice = tile:getItemById(dices[i])
            dice:transform(dices[sorted])
            config.position.dice:sendMagicEffect(CONST_ME_CRAPS)
            break
        end
    end

    addEvent(function()
        sendRolledMsg(sorted)
    end, 800)

    addEvent(function()
        if status then 
            addMoney()
            config.position.player:sendMagicEffect(config.effects.win)
        else
            config.position.player:sendMagicEffect(config.effects.lose)
        end
    end, 1000)

end

local function onAddFocus(cid)
    npc = Creature(getNpcCid())
    npc:setDirection(config.direction.talking)
end

local function onReleaseFocus(cid)
    npc:setDirection(config.direction.stopped)
    player = nil
    npc = nil
end

function onThink()
    if config.automatic and not player then
        players = Tile(config.position.player):getCreatures()

        for i = 1, #players do
            if players[i]:isPlayer() then
                npcHandler:addFocus(players[i].uid)
                npcHandler:greet(players[i].uid)
                player = players[i]
                break
            end
        end
    end

    if player then
        if not playerIsInPosition(player) then
            npcHandler:say("Adeus, " .. player:getName() ..".", player.uid)
            npcHandler:releaseFocus(player.uid)
            player = nil
            return true
        end
    end
end

function playerIsInPosition(player)
    local pos1 = player:getPosition()
    local pos2 = config.position.player
    
    if (pos1.x == pos2.x) and (pos1.y == pos2.y) and (pos1.z == pos2.z) then
        return true
    end

    return false
end

function removeMoney()
    money = 0
    local tile = Tile(config.position.money)
    local items = tile:getItems()
    local torvm = {}

    for i = 1, #items do
        if coins[items[i]:getId()] then
            local coin = items[i]
            money = money + (coins[coin:getId()] * coin:getCount())
        end
    end

    if money < config.min then
        npcHandler:say("Você precisa de " .. config.min .. " gold coins para usar o cassino.", player.uid)
        return false
    elseif money > config.max then
        npcHandler:say("Você só pode usar " .. config.max .. " gold coins no cassino.", player.uid)
        return false
    end

    for i = 1, #items do
        if coins[items[i]:getId()] then
            items[i]:remove()
        end
    end

    return true
end

function addMoney()
    local moneywin = money * config.multiplyby
    local gingot = 0
    local ccoin = 0
    local pcoin = 0
    local gcoin = 0

    while moneywin > 0 do
    	if (moneywin >= 1000000) then
            gingot = moneywin / 1000000;
            moneywin = moneywin - 1000000 * math.floor(gingot);
        end
        if (moneywin >= 10000) then
            ccoin = moneywin / 10000;
            moneywin = moneywin - 10000 * math.floor(ccoin);
        end
        if (moneywin >= 100) then
            pcoin = moneywin / 100;
            moneywin = moneywin - 100 * math.floor(pcoin);
        end
        if (moneywin >= 1) then
            gcoin = moneywin / 1;
            moneywin = moneywin - 1 * math.floor(gcoin);
        end
    end

    while gcoin > 0 do
        if gcoin >= 100 then
            Game.createItem(2148, 100, config.position.money)
            gcoin = gcoin - 100
        else
            Game.createItem(2148, math.floor(gcoin), config.position.money)
            gcoin = 0
        end
    end

    while pcoin > 0 do
        if pcoin >= 100 then
            Game.createItem(2152, 100, config.position.money)
            pcoin = pcoin - 100
        else
            Game.createItem(2152, math.floor(pcoin), config.position.money)
            pcoin = 0
        end
    end

    while ccoin > 0 do
        if ccoin >= 100 then
            Game.createItem(2160, 100, config.position.money)
            ccoin = ccoin - 100
        else
            Game.createItem(2160, math.floor(ccoin), config.position.money)
            ccoin = 0
        end
    end

    while gingot > 0 do
        if gingot >= 100 then
            Game.createItem(9971, 100, config.position.money)
            gingot = gingot - 100
        else
            Game.createItem(9971, math.floor(gingot), config.position.money)
            gingot = 0
        end
    end
end

function sendRolledMsg(sorted)
    local spectators = Game.getSpectators(config.position.dice, false, true, 3, 3)
    for _, spectator in ipairs(spectators) do
        npc:say("Tirou o número " .. sorted .. ".", TALKTYPE_MONSTER_SAY, false, spectator, config.position.dice)
    end
end

npcHandler:setMessage(MESSAGE_GREET, 'Olá |PLAYERNAME|, você quer apostar no cassino? Diga L para 1-3, H para 4-6.')
npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_ONADDFOCUS, onAddFocus)
npcHandler:setCallback(CALLBACK_ONRELEASEFOCUS, onReleaseFocus)
npcHandler:addModule(FocusModule:new())