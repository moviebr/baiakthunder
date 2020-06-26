local outfits = {
    ["citizen"] = {136, 128},
    ["hunter"] = {137, 129},
    ["knight"] = {139, 131},
    ["noblewoman"] = {140, 132},
    ["summoner"] = {141, 133},
    ["warrior"] = {142, 134},
    ["barbarian"] = {147, 143},
    ["druid"] = {148, 144},
    ["wizard"] = {149, 145},
    ["oriental"] = {150, 146},
    ["pirate"] = {155, 151},
    ["assassin"] = {156, 152},
    ["beggar"] = {157, 153},
    ["shaman"] = {158, 154},
    ["norsewoman"] = {252, 251},
    ["nightmare"] = {269, 268},
    ["jester"] = {270, 273},
    ["brotherhood"] = {279, 278},
    ["demonhunter"] = {288, 289},
    ["yalaharian"] = {324, 325},
    ["warmaster"] = {336, 335},
    ["wayfarer"] = {366, 367},
}

local storage = 32943
function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if player:getStorageValue(storage) > 0 then
        player:sendCancelMessage("Você já tem todos os addons.")
        return true
    end

    for a, b in pairs(outfits) do
        player:addOutfitAddon(b[1], 3)
        player:addOutfitAddon(b[2], 3)
    end
    
	player:addOutfitAddon(130, 1)
	player:addOutfitAddon(138, 1)
    player:sendCancelMessage("Você recebeu todos os addons.")
    player:getPosition():sendMagicEffect(12)
	player:setStorageValue(storage, 1)
	item:remove(1)
    return true
end