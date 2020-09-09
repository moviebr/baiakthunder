config = {
        quests = {
            [7172] = { -- ActionID que será colocado no baú
                name = "dos Crystal Coins", -- Nome da quest
                rewards = {
                    {id = 2160, count = 100}, -- Prêmio: ID - Count
                },
                level = {
                    active = true, -- Level minimo para pegar?
                    min = 150, -- Se true, qual o minimo
                },
                storage = {
                    active = true, -- Player poderá pegar somente uma vez?
                    key = 91143, -- Apenas uma key por quest
                },
                effectWin = 30, -- Efeito que vai aparecer quando fizer a quest
            },
            [7171] = { -- ActionID que será colocado no baú
                name = "dos Coins", -- Nome da quest
                rewards = {
                    {id = 2160, count = 100}, -- Prêmio: ID - Count
                    {id = 2152, count = 100}, -- Prêmio: ID - Count
                },
                level = {
                    active = true, -- Level minimo para pegar?
                    min = 150, -- Se true, qual o minimo
                },
                storage = {
                    active = true, -- Player poderá pegar somente uma vez?
                    key = 91140, -- Apenas uma key por quest
                },
                effectWin = 29, -- Efeito que vai aparecer quando fizer a quest
            },
        },
    messages = {
        notExist = "Essa quest não existe.",
        win = "Você fez a quest %s.",
        notWin = "Você já fez a quest %s.",
        level = "Você precisa de level %d ou maior para fazer a quest %s.",
    },
}

function onUse(cid, item, fromPosition, target, toPosition, isHotkey)
    local player = Player(cid)
    local choose = config.quests[item.actionid]

    if not choose then
        player:sendCancelMessage(config.messages.notExist)
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return true
    end

    if choose.level.active and player:getLevel() < choose.level.min then
        player:sendCancelMessage(config.messages.level:format(choose.level.min, choose.name))
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return true
    end

    if choose.storage.active and player:getStorageValue(choose.storage.key) >= 0 then
        player:sendCancelMessage(config.messages.notWin:format(choose.name))
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return true
    end

    for i = 1, #choose.rewards do
        player:addItem(choose.rewards[i].id, choose.rewards[i].count)
    end

    player:setStorageValue(choose.storage.key, 1)
    player:sendCancelMessage(config.messages.win:format(choose.name))
    player:getPosition():sendMagicEffect(choose.effectWin)

    return true
end