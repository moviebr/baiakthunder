local keywordHandler = KeywordHandler:new() 
local npcHandler = NpcHandler:new(keywordHandler) 
NpcSystem.parseParameters(npcHandler) 
local talkState = {}
function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end 
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end 
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end 
function onThink() npcHandler:onThink() end 
function creatureSayCallback(cid, type, msg) 
if(not npcHandler:isFocused(cid)) then 
return false 
end 
local talkState = {}
local talkUser = NPCHANDLER_CONVbehavior == CONVERSATION_DEFAULT and 0 or cid
local shopWindow = {}
local moeda = 12543
local t = {
      [12396] = {price = 400},
      [12575] = {price = 400},
      [7440] = {price = 200},
      [7443] = {price = 400},
      [8981] = {price = 600},
      [5468] = {price = 250},    
      [2346] = {price = 200}
    }
      
local onBuy = function(cid, item, subType, amount, ignoreCap, inBackpacks)
  local player = Player(cid)

    if  t[item] and not player:removeItem(moeda, t[item].price) then
          selfSay("Você não tem "..t[item].price.." online tokens.", cid)
             else
        player:addItem(item)
        selfSay("Aqui está.", cid)
       end
    return true
end
if (msgcontains(msg, 'trade') or msgcontains(msg, 'TRADE') or msgcontains(msg, 'troca') or msgcontains(msg, 'TROCA'))then
            for var, ret in pairs(t) do
                local itemType = ItemType(var)
                local itemName = itemType:getName()
                    table.insert(shopWindow, {id = var, subType = 0, buy = ret.price, sell = 0, name = itemName})
                end
            openShopWindow(cid, shopWindow, onBuy, onSell)
            end
return true
end
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback) 
npcHandler:addModule(FocusModule:new())