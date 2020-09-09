local maxBless = 5

function onDeath(player, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)

    local playerBless = 0
    for i = 1, maxBless do
        if player:hasBlessing(i) then
            playerBless = playerBless + 1
            playerBless = playerBless * playerBless
        end
    end
    
    db.query("INSERT INTO `player_deaths` (`bless`) VALUES (" .. playerBless .. "")
	
	local amulet = player:getSlotItem(CONST_SLOT_NECKLACE)
	if amulet and amulet.itemid == ITEM_AMULETOFLOSS then
		db.query("INSERT INTO `player_deaths` (`aol`) VALUES ('true'")
	end

    return true
end