local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)            npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)        npcHandler:onCreatureDisappear(cid)            end
function onCreatureSay(cid, type, msg)    npcHandler:onCreatureSay(cid, type, msg)    end
function onThink()                        npcHandler:onThink()                        end

local function greetCallback(cid)
    local player = Player(cid)
    local msg = 'Seja Bem-Vindo, ' .. player:getName() .. '.'
   
    local playerStatus = getPlayerMarriageStatus(player:getGuid())
    local playerSpouse = getPlayerSpouse(player:getGuid())
    if (playerStatus == MARRIED_STATUS) then
        msg = msg .. ' Eu vejo que você é tem um casamento feliz. O que te traz aqui? Procurando um {divorce} ou {divorcio}?'
    elseif (playerStatus == PROPOSED_STATUS) then
        msg = msg .. ' Você ainda está aguardando a proposta de casamento que fez para {' .. (getPlayerNameById(playerSpouse)) .. '}. Você gostaria de {remove} ou {remover} isso?'
    else
        msg = msg .. ' O que te traz aqui? Gostaria de se {casar} ou {marry} com alguém?'
    end
    npcHandler:say(msg,cid)
    npcHandler:addFocus(cid)
    return false
end

local function tryEngage(cid, message, keywords, parameters, node)
    if(not npcHandler:isFocused(cid)) then
        return false
    end
   
    local player = Player(cid)
   
    local playerStatus = getPlayerMarriageStatus(player:getGuid())
    local playerSpouse = getPlayerSpouse(player:getGuid())
    if playerStatus == MARRIED_STATUS then
        npcHandler:say('Você já é casado com {' .. getPlayerNameById(playerSpouse) .. '}.', cid)
    elseif playerStatus == PROPOSED_STATUS then
        npcHandler:say('Você já fez uma proposta de casamento para {' .. getPlayerNameById(playerSpouse) .. '}. Você sempre pode remover a proposta dizendo {remove} ou {remover}.', cid)
    else
        local candidate = getPlayerGUIDByName(message)
        if candidate == 0 then
            npcHandler:say('Player com esse nome não existe.', cid)
        elseif candidate == player:getGuid() then
            npcHandler:say('Você não pode casar com você mesmo.', cid)
        else
            if player:getItemCount(ITEM_WEDDING_RING) == 0 then
                npcHandler:say('Como eu disse, você precisa de uma aliança para se casar.', cid)
            else
                local candidateStatus = getPlayerMarriageStatus(candidate)
                local candidateSpouse = getPlayerSpouse(candidate)
                if candidateStatus == MARRIED_STATUS then
                    npcHandler:say('{' .. getPlayerNameById(candidate) .. '} já é casado com {' .. getPlayerNameById(candidateSpouse) .. '}.', cid)
                elseif candidateStatus == PROPOSED_STATUS then
                    if candidateSpouse == player:getGuid() then
                        npcHandler:say('Já que as duas jovens almas estão dispostas a se casar, eu declaro que você e {' .. getPlayerNameById(candidate) .. '} estão casados. {' .. player:getName() .. '}, pegue esses dois anéis de casamento gravados e dê um deles ao seu cônjuge.', cid)
                        player:removeItem(ITEM_WEDDING_RING,1)
                        local item1 = Item(doPlayerAddItem(cid,ITEM_ENGRAVED_WEDDING_RING,1))
                        local item2 = Item(doPlayerAddItem(cid,ITEM_ENGRAVED_WEDDING_RING,1))
                        item1:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, player:getName() .. ' & ' .. getPlayerNameById(candidate) .. ' para sempre - casados em ' .. os.date('%B %d, %Y.'))
                        item2:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, player:getName() .. ' & ' .. getPlayerNameById(candidate) .. ' para sempre - casados em ' .. os.date('%B %d, %Y.'))
                        setPlayerMarriageStatus(player:getGuid(), MARRIED_STATUS)
                        setPlayerMarriageStatus(candidate, MARRIED_STATUS)
                        setPlayerSpouse(player:getGuid(), candidate)
                    else
                        npcHandler:say('{' .. getPlayerNameById(candidate) .. '} já fez uma proposta de casamento para {' .. getPlayerNameById(candidateSpouse) .. '}.', cid)
                    end
                else
                    npcHandler:say('Ok, agora vamos esperar e ver se {' ..  getPlayerNameById(candidate) .. '} aceita sua proposta. Devolverei seu anel de casamento assim que {' ..  getPlayerNameById(candidate) .. '} aceitar sua proposta ou você {remove} ou {remover} ela.', cid)
                    player:removeItem(ITEM_WEDDING_RING,1)
                    setPlayerMarriageStatus(player:getGuid(), PROPOSED_STATUS)
                    setPlayerSpouse(player:getGuid(), candidate)
                end
            end
        end
    end
    keywordHandler:moveUp(3)
    return true
end

local function confirmRemoveEngage(cid, message, keywords, parameters, node)
    if(not npcHandler:isFocused(cid)) then
        return false
    end
   
    local player = Player(cid)
    local playerStatus = getPlayerMarriageStatus(player:getGuid())
    local playerSpouse = getPlayerSpouse(player:getGuid())
    if playerStatus == PROPOSED_STATUS then
        npcHandler:say('Tem certeza de que deseja remover sua proposta de casamento com {' .. getPlayerNameById(playerSpouse) .. '}?', cid)
		node:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, moveup = 3, text = 'Ok, vamos mantê-lo então.'})
		node:addChildKeyword({'nao'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, moveup = 3, text = 'Ok, vamos mantê-lo então.'})
		node:addChildKeyword({'não'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, moveup = 3, text = 'Ok, vamos mantê-lo então.'})
       
        local function removeEngage(cid, message, keywords, parameters, node)
            doPlayerAddItem(cid,ITEM_WEDDING_RING,1)
            setPlayerMarriageStatus(player:getGuid(), 0)
            setPlayerSpouse(player:getGuid(), -1)
            npcHandler:say(parameters.text, cid)
            keywordHandler:moveUp(parameters.moveup)
        end
        node:addChildKeyword({'yes'}, removeEngage, {moveup = 3, text = 'Ok, sua proposta de casamento para {' .. getPlayerNameById(playerSpouse) .. '} foi removido. Leve seu anel de casamento de volta.'})
		node:addChildKeyword({'sim'}, removeEngage, {moveup = 3, text = 'Ok, sua proposta de casamento para {' .. getPlayerNameById(playerSpouse) .. '} foi removido. Leve seu anel de casamento de volta.'})
	else
        npcHandler:say('Você não tem nenhuma proposta pendente a ser removida.', cid)
        keywordHandler:moveUp(2)
    end
    return true
end

local function confirmDivorce(cid, message, keywords, parameters, node)
    if(not npcHandler:isFocused(cid)) then
        return false
    end
   
    local player = Player(cid)
    local playerStatus = getPlayerMarriageStatus(player:getGuid())
    local playerSpouse = getPlayerSpouse(player:getGuid())
    if playerStatus == MARRIED_STATUS then
        npcHandler:say('Tem certeza de que deseja se divorciar de {' .. getPlayerNameById(playerSpouse) .. '}?', cid)
		node:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, moveup = 3, text = 'Ótimo! Casamentos devem ser um compromisso eterno.'})
		node:addChildKeyword({'nao'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, moveup = 3, text = 'Ótimo! Casamentos devem ser um compromisso eterno.'})
		node:addChildKeyword({'não'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, moveup = 3, text = 'Ótimo! Casamentos devem ser um compromisso eterno.'})
       
        local function divorce(cid, message, keywords, parameters, node)
            local player = Player(cid)
            local spouse = getPlayerSpouse(player:getGuid())
            setPlayerMarriageStatus(player:getGuid(), 0)
            setPlayerSpouse(player:getGuid(), -1)
            setPlayerMarriageStatus(spouse, 0)
            setPlayerSpouse(spouse, -1)
            npcHandler:say(parameters.text, cid)
            keywordHandler:moveUp(parameters.moveup)
        end
		node:addChildKeyword({'yes'}, divorce, {moveup = 3, text = 'Ok, agora você é divorciado de {' .. getPlayerNameById(playerSpouse) .. '}. Pense melhor na próxima vez depois de se casar com alguém.'})
		node:addChildKeyword({'sim'}, divorce, {moveup = 3, text = 'Ok, agora você é divorciado de {' .. getPlayerNameById(playerSpouse) .. '}. Pense melhor na próxima vez depois de se casar com alguém.'})
    else
        npcHandler:say('Você não é casado para se divorciar.', cid)
        keywordHandler:moveUp(2)
    end
    return true
end

local node1 = keywordHandler:addKeyword({'marry'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Você gostaria de se casar? Certifique-se de ter um anel de casamento com você.'})
local node1 = keywordHandler:addKeyword({'casa'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Você gostaria de se casar? Certifique-se de ter um anel de casamento com você.'})
node1:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, moveup = 1, text = 'Isso é bom.'})
node1:addChildKeyword({'nao'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, moveup = 1, text = 'Isso é bom.'})
node1:addChildKeyword({'não'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, moveup = 1, text = 'Isso é bom.'})
local node2 = node1:addChildKeyword({'yes'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'E com quem você gostaria de se casar?'})
local node2 = node1:addChildKeyword({'sim'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'E com quem você gostaria de se casar?'})
node2:addChildKeyword({'[%w]'}, tryEngage, {})

keywordHandler:addKeyword({'remove'}, confirmRemoveEngage, {})

keywordHandler:addKeyword({'divorc'}, confirmDivorce, {})

npcHandler:setCallback(CALLBACK_GREET, greetCallback)

npcHandler:addModule(FocusModule:new())