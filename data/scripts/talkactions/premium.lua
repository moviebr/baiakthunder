local premium = TalkAction("!sellpoints")

function premium.onSay(player, words, param)
    local var = "[Sell Points System] Este documento vale %d points para você usar no site."
    local points = player:getPremiumPoints()
    local min,max = 5, 100
    if param == "" or not tonumber(param) then
        player:sendCancelMessage("Desculpe, use somente numeros.") 
        return false
    elseif tonumber(param) < min or tonumber(param) > max then
        player:sendCancelMessage("Desculpe, mínimo de "..min.." e máximo de "..max.." points.") 
        return false
    elseif points < tonumber(param) then
        player:sendCancelMessage("Desculpe, mas você só possui "..points.." Premium Points.") 
        return false
    end

    local item = player:addItem(7702)
    item:setCustomAttribute("premiumPoints", tonumber(param))
    player:addPremiumPoints(- tonumber(param))
    player:sendCancelMessage("[Sell Points System] Você recebeu um documento com "..param.." Premium Points.")
    return false
end

premium:separator(" ")
premium:register()
