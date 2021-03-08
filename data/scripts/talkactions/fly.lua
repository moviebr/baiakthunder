local talk = TalkAction("!fly")

local config = {
    places = {
        ["templo"] = Position(991, 1210, 7),
        ["depot"] = Position(961, 1211, 7),
    },
    onlyPz = true,
    storage = {
        active = true,
        storage = 89154,
        time = 5, -- in seconds
    },
}

function talk.onSay(player, words, param)

    if not param or param == "" then
        message = "Você pode ir para os seguintes locais:\n\n"
        locais = ""
        for a in pairs(config.places) do
            locais = locais .. a .. "\n"
        end

        message = message .. locais
        player:popupFYI(message)
    end

    if config.storage.active and player:getStorageValue(config.storage.storage) > os.time() then
        player:sendCancelMessage("Você precisa esperar " .. string.diff(player:getStorageValue(config.storage.storage) - os.time(), true) .. " para usar esse comando novamente.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    param = param:lower():trim()
    local choose = config.places[param]

    if not choose then
        player:sendCancelMessage("Local não encontrado.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    if config.onlyPz and not Tile(player:getPosition()):hasFlag(TILESTATE_PROTECTIONZONE) then
        player:sendCancelMessage("Você precisa estar em pz para usar esse comando.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    player:getPosition():sendMagicEffect(CONST_ME_POFF)
    player:teleportTo(choose)
    player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
    player:sendTextMessage(MESSAGE_STATUS_BLUE_LIGHT, "Você foi para o {" .. param .. "}.")

    if config.storage.active then
        player:setStorageValue(config.storage.storage, os.time() + config.storage.time)
    end

    return false
end

talk:separator(" ")
talk:register()
