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

    return true
end

--[[ COMANDO SQL

ALTER TABLE `player_deaths` ADD `bless` INT(11) NOT NULL DEFAULT '0';

TAG Creaturescript

<event type="death" name="BlessLog" script="blessLog.lua" />

--]]