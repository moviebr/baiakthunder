local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)              npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)           npcHandler:onCreatureDisappear(cid)         end
function onCreatureSay(cid, type, msg)      npcHandler:onCreatureSay(cid, type, msg)    end
function onThink()                          npcHandler:onThink()                        end

local voices = { {text = "Runas, varinhas, poções de vida e de mana com um preço especial! Venha dar uma olhada!"} }
npcHandler:addModule(VoiceModule:new(voices))

local shopModule = ShopModule:new()
npcHandler:addModule(shopModule)

shopModule:addBuyableItem({'spellbook'}, 2175, 135, 'spellbook')
shopModule:addBuyableItem({'magic lightwand'}, 2163, 360, 'magic lightwand')

shopModule:addBuyableItem({'small health'}, 8704, 18, 1, 'small health potion')
shopModule:addBuyableItem({'health potion'}, 7618, 40, 1, 'health potion')
shopModule:addBuyableItem({'mana potion'}, 7620, 45, 1, 'mana potion')
shopModule:addBuyableItem({'strong health'}, 7588, 90, 1, 'strong health potion')
shopModule:addBuyableItem({'strong mana'}, 7589, 72, 1, 'strong mana potion')
shopModule:addBuyableItem({'great health'}, 7591, 171, 1, 'great health potion')
shopModule:addBuyableItem({'great mana'}, 7590, 108, 1, 'great mana potion')
shopModule:addBuyableItem({'great spirit'}, 8472, 171, 1, 'great spirit potion')
shopModule:addBuyableItem({'ultimate health'}, 8473, 279, 1, 'ultimate health potion')
shopModule:addBuyableItem({'antidote potion'}, 8474, 45, 1, 'antidote potion')

shopModule:addSellableItem({'normal potion flask', 'normal flask'}, 7636, 5, 'empty small potion flask')
shopModule:addSellableItem({'strong potion flask', 'strong flask'}, 7634, 11, 'empty strong potion flask')
shopModule:addSellableItem({'great potion flask', 'great flask'}, 7635, 17, 'empty great potion flask')

shopModule:addBuyableItem({'instense healing'}, 2265, 85, 1, 'intense healing rune')
shopModule:addBuyableItem({'ultimate healing'}, 2273, 157, 1, 'ultimate healing rune')
shopModule:addBuyableItem({'magic wall'}, 2293, 315, 3, 'magic wall rune')
shopModule:addBuyableItem({'destroy field'}, 2261, 40, 3, 'destroy field rune')
shopModule:addBuyableItem({'light magic missile'}, 2287, 36, 10, 'light magic missile rune')
shopModule:addBuyableItem({'heavy magic missile'}, 2311, 108, 10, 'heavy magic missile rune')
shopModule:addBuyableItem({'great fireball'}, 2304, 162, 4, 'great fireball rune')
shopModule:addBuyableItem({'explosion'}, 2313, 225, 6, 'explosion rune')
shopModule:addBuyableItem({'sudden death'}, 2268, 315, 3, 'sudden death rune')
shopModule:addBuyableItem({'death arrow'}, 2263, 270, 3, 'death arrow rune')
shopModule:addBuyableItem({'paralyze'}, 2278, 630, 1, 'paralyze rune')
shopModule:addBuyableItem({'animate dead'}, 2316, 337, 1, 'animate dead rune')
shopModule:addBuyableItem({'convince creature'}, 2290, 72, 1, 'convince creature rune')
shopModule:addBuyableItem({'chameleon'}, 2291, 189, 1, 'chameleon rune')
shopModule:addBuyableItem({'desintegrate'}, 2310, 72, 3, 'desintegreate rune')

--[[
shopModule:addBuyableItemContainer({'bp ap'}, 2002, 8378, 2000, 1, 'backpack of antidote potions')
shopModule:addBuyableItemContainer({'bp slhp'}, 2000, 8610, 400, 1, 'backpack of small health potions')
shopModule:addBuyableItemContainer({'bp hp'}, 2000, 7618, 900, 1, 'backpack of health potions')
shopModule:addBuyableItemContainer({'bp mp'}, 2001, 7620, 1000, 1, 'backpack of mana potions')
shopModule:addBuyableItemContainer({'bp shp'}, 2000, 7588, 2000, 1, 'backpack of strong health potions')
shopModule:addBuyableItemContainer({'bp smp'}, 2001, 7589, 1600, 1, 'backpack of strong mana potions')
shopModule:addBuyableItemContainer({'bp ghp'}, 2000, 7591, 3800, 1, 'backpack of great health potions')
shopModule:addBuyableItemContainer({'bp gmp'}, 2001, 7590, 2400, 1, 'backpack of great mana potions')
shopModule:addBuyableItemContainer({'bp gsp'}, 1999, 8376, 3800, 1, 'backpack of great spirit potions')
shopModule:addBuyableItemContainer({'bp uhp'}, 2000, 8377, 6200, 1, 'backpack of ultimate health potions')
--]]

shopModule:addBuyableItem({'wand of vortex', 'vortex'}, 2190, 450, 'wand of vortex')
shopModule:addBuyableItem({'wand of dragonbreath', 'dragonbreath'}, 2191, 900, 'wand of dragonbreath')
shopModule:addBuyableItem({'wand of decay', 'decay'}, 2188, 4500, 'wand of decay')
shopModule:addBuyableItem({'wand of draconia', 'draconia'}, 8921, 6750, 'wand of draconia')
shopModule:addBuyableItem({'wand of cosmic energy', 'cosmic energy'}, 2189, 9000, 'wand of cosmic energy')
shopModule:addBuyableItem({'wand of inferno', 'inferno'}, 2187, 13500, 'wand of inferno')
shopModule:addBuyableItem({'wand of starstorm', 'starstorm'}, 8920, 16200, 'wand of starstorm')
shopModule:addBuyableItem({'wand of voodoo', 'voodoo'}, 8922, 19800, 'wand of voodoo')

shopModule:addBuyableItem({'snakebite rod', 'snakebite'}, 2182, 450, 'snakebite rod')
shopModule:addBuyableItem({'moonlight rod', 'moonlight'}, 2186, 900, 'moonlight rod')
shopModule:addBuyableItem({'necrotic rod', 'necrotic'}, 2185, 4500, 'necrotic rod')
shopModule:addBuyableItem({'northwind rod', 'northwind'}, 8911, 6750, 'northwind rod')
shopModule:addBuyableItem({'terra rod', 'terra'}, 2181, 9000, 'terra rod')
shopModule:addBuyableItem({'hailstorm rod', 'hailstorm'}, 2183, 13500, 'hailstorm rod')
shopModule:addBuyableItem({'springsprout rod', 'springsprout'}, 8912, 16200, 'springsprout rod')
shopModule:addBuyableItem({'underworld rod', 'underworld'}, 8910, 19800, 'underworld rod')

shopModule:addSellableItem({'wand of vortex', 'vortex'}, 2190, 225, 'wand of vortex')
shopModule:addSellableItem({'wand of dragonbreath', 'dragonbreath'}, 2191, 450, 'wand of dragonbreath')
shopModule:addSellableItem({'wand of decay', 'decay'}, 2188, 2250, 'wand of decay')
shopModule:addSellableItem({'wand of draconia', 'draconia'}, 8921, 3375, 'wand of draconia')
shopModule:addSellableItem({'wand of cosmic energy', 'cosmic energy'}, 2189, 4500, 'wand of cosmic energy')
shopModule:addSellableItem({'wand of inferno', 'inferno'},2187, 6750, 'wand of inferno')
shopModule:addSellableItem({'wand of starstorm', 'starstorm'}, 8920, 8100, 'wand of starstorm')
shopModule:addSellableItem({'wand of voodoo', 'voodoo'}, 8922, 11000, 'wand of voodoo')

shopModule:addSellableItem({'snakebite rod', 'snakebite'}, 2182, 225,'snakebite rod')
shopModule:addSellableItem({'moonlight rod', 'moonlight'}, 2186, 450, 'moonlight rod')
shopModule:addSellableItem({'necrotic rod', 'necrotic'}, 2185, 2250, 'necrotic rod')
shopModule:addSellableItem({'northwind rod', 'northwind'}, 8911, 3375, 'northwind rod')
shopModule:addSellableItem({'terra rod', 'terra'}, 2181, 4500, 'terra rod')
shopModule:addSellableItem({'hailstorm rod', 'hailstorm'}, 2183, 6750, 'hailstorm rod')
shopModule:addSellableItem({'springsprout rod', 'springsprout'}, 8912, 8100, 'springsprout rod')
shopModule:addSellableItem({'underworld rod', 'underworld'}, 8910, 9900, 'underworld rod')


function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	local player = Player(cid)
	local vocationId = player:getVocation():getId()
	local items = {
		[1] = 2190,
		[2] = 2182,
		[5] = 2190,
		[6] = 2182
	}

	if msgcontains(msg, 'first rod') or msgcontains(msg, 'first wand') then
		if table.contains({1, 2, 5, 6}, vocationId) then
			if player:getStorageValue(30002) == -1 then
				selfSay('So you ask me for a {' .. ItemType(items[vocationId]):getName() .. '} to begin your advanture?', cid)
				npcHandler.topic[cid] = 1
			else
				selfSay('What? I have already gave you one {' .. ItemType(items[vocationId]):getName() .. '}!', cid)
			end
		else
			selfSay('Sorry, you aren\'t a druid either a sorcerer.', cid)
		end
	elseif msgcontains(msg, 'yes') then
		if npcHandler.topic[cid] == 1 then
			player:addItem(items[vocationId], 1)
			selfSay('Here you are young adept, take care yourself.', cid)
			player:setStorageValue(30002, 1)
		end
		npcHandler.topic[cid] = 0
	elseif msgcontains(msg, 'no') and npcHandler.topic[cid] == 1 then
		selfSay('Ok then.', cid)
		npcHandler.topic[cid] = 0
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
