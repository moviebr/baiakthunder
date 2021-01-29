SNAKE = {
	itemid=1860,
	premio = 9020,
	freeglobalstorage=28103,
	itemFood=2674,
	controlpos= {x = 1656, y = 992, z = 6},
	exitpos = {x = 1655, y = 983, z = 7},
	centerpos= {x = 1655, y = 991, z = 7},
	wallID = 1486,
	interval = 300,
	timer =
		function(player,n,pos_)
		local player = Player(player)
		local pos_ = pos_ or {{SNAKE.centerpos}}
		Game.setStorageValue(SNAKE.freeglobalstorage, 1)
			if not player:isPlayer() then
				SNAKE.clean()
				return
			end
			for i,pos in pairs(pos_) do
			SNAKE.find_and_delete(pos[1])
				if i == 1 then
					pos[2] = SNAKE.copypos(pos[1])
					if player:getDirection() == 0 then
						pos[1] = {x=pos[1].x,y=pos[1].y - 1,z=pos[1].z,stackpos=255}
					elseif player:getDirection() == 1 then
						pos[1] = {x=pos[1].x + 1,y=pos[1].y,z=pos[1].z,stackpos=255}
					elseif player:getDirection() == 2 then
						pos[1] = {x=pos[1].x,y=pos[1].y + 1,z=pos[1].z,stackpos=255}
					elseif player:getDirection() == 3 then
						pos[1] = {x=pos[1].x - 1,y=pos[1].y,z=pos[1].z,stackpos=255}
					end
				else
					pos[2] = SNAKE.copypos(pos[1])
					pos[1] = pos_[i-1][2]
				end
			local ret,p,walk = SNAKE.check(pos[1])
				if ret == 1 or ret == 3 then
					player:teleportTo(SNAKE.exitpos, false)
					player:getPosition():sendMagicEffect(11)
					player:say('Pontos: '..(#pos_-1)..'.', TALKTYPE_MONSTER_SAY)

					if not player:getStorageValue(97814) or player:getStorageValue(97814) == -1 then
						player:setStorageValue(97814, 0)
					end

					if #pos_-1 > player:getStorageValue(97814) then
						player:setStorageValue(97814, #pos_-1)
						SNAKE:setPlayerPoints(player:getGuid(), tonumber(#pos_-1))
					end

					if #pos_-1 >= 20 and #pos_-1 < 30 then
						player:addItem(SNAKE.premio, 1)
					elseif #pos_-1 >= 30 and #pos_-1 < 40 then
						player:addItem(SNAKE.premio, 2)
					elseif #pos_-1 >= 40 and #pos_-1 < 50 then
						player:addItem(SNAKE.premio, 3)
					elseif #pos_-1 >= 50 then
						player:addItem(SNAKE.premio, 4)
					end 
					SNAKE.clean()
					Game.setStorageValue(SNAKE.freeglobalstorage,0)
					return
				end
				if ret == 2 then
					p:remove()
						if p then
							pos_[#pos_+1] = {pos[2],pos[2]}
									local tile = Tile(pos[1])
									tile:getPosition():sendMagicEffect(CONST_ME_FIREWORK_RED)
							player:say(''..(#pos_-1)..'', TALKTYPE_MONSTER_SAY, false, player, pos[1])
							SNAKE.generateFood()
						end
				end
				Game.createItem(SNAKE.itemid,1,pos[1])
	
			end
	 
		local plpos = player:getPosition()
	
		local generated = {
		{x = 1656, y = 991, z = 6},
		{x = 1655, y = 992, z = 6},
		{x = 1656, y = 993, z = 6},
		{x = 1657, y = 992, z = 6}
		}
			for i,pos in pairs(generated) do
					if SNAKE.samepos(plpos,pos) then
	
						player:teleportTo(SNAKE.controlpos,false)
					end
				local tile = Tile(pos)
				tile:getPosition():sendMagicEffect(CONST_ME_TUTORIALSQUARE)
			end
		addEvent(SNAKE.timer,SNAKE.interval,player.uid,n,pos_)
		end,
	
	copypos =
		function(p)
		return {x=p.x,y=p.y,z=p.z,stackpos=p.stackpos}
		end,
	
	samepos =
		function(p1,p2)
			if p1.x == p2.x and p1.y == p2.y then
				return true
			end
		return false
		end,
	
	generateFood =
		function()
			local pp = {x=SNAKE.centerpos.x+math.random(-6,6),y=SNAKE.centerpos.y+math.random(-4,4),z=SNAKE.centerpos.z}
			local tile = Tile(pp)
			tile:getPosition():sendMagicEffect(CONST_ME_FIREWORK_BLUE)
			Game.createItem(SNAKE.itemFood,1,pp)
		end,
	
	clean = function()
		 for y=-4,4 do
		   for x=-6,6 do
		   local pp = {x=SNAKE.centerpos.x+x,y=SNAKE.centerpos.y+y,z=SNAKE.centerpos.z}
			 for i=250,255 do
			 pp.stackpos = i
			 local tile = Tile(pp)
			   if tile then
				 local items = tile:getItems()
				 if #items > 0 then
				   for i =1,#items do
					 items[i]:remove()
				   end
				   tile:getPosition():sendMagicEffect(CONST_ME_HITBYFIRE)
				 end
			   end
			 end
		   end
		 end
	   end,
	 
	check =
		function(pos)
			for i=1,10 do
			pos.stackpos = i
			local tile = Tile(pos)
			local cake = tile:getItemById(SNAKE.itemid)
			local p = tile:getItemById(SNAKE.itemFood)
			local wall = tile:getItemById(SNAKE.wallID)
				if cake then
					return 1,cake,true
				elseif wall then
					return 1,wall,true
				elseif p then
					return 2,p
				end
			end
		return false
		end,
	
	find_and_delete =
		function(pos)
			for i=0,255 do
			pos.stackpos = 255-i
				local tile1 = Tile(pos)
				local p = tile1 and tile1:getItemById(SNAKE.itemid) or false
				if p then
					return p:remove()
				end
			end
		end,
	
	isWalkable =
		function(pos, creature, proj, pz)
		local position = {x = pos.x, y = pos.y, z = pos.z, stackpos = 0}
		local tile2 = Tile(position)
		if tile2:getThing().itemid == 0 then return false end
		if tile2:getCreatureCount() > 0 then return false end
		if tile2:hasFlag(TILESTATE_PROTECTIONZONE) then return false, true end
		local n = not proj and 3 or 2
			for i = 0, 255 do
			pos.stackpos = i
			local tile = Tile(pos)
			local tile3 = tile:getItemById()
				if tile3.itemid ~= 0 and not tile3:isCreature() then
					if hasItemProperty(tile3.uid, n) or hasItemProperty(tile3.uid, 7) then
						return false
					end
				end
			end
		return true
		end
	}

function SNAKE:setPlayerPoints(guid, amount)
	if SNAKE:getPlayerPoints(guid) >= 0 then
		db.query(string.format("UPDATE `snake_game` SET `points` = %d WHERE `guid` = %d", amount, guid))
	else
		db.query(string.format("INSERT INTO `snake_game` (`id`, `guid`, `points`) VALUES ('', '%d', '%d')", guid, amount))
	end
end

function SNAKE:getPlayerPoints(guid)
    local resultId = db.storeQuery(string.format('SELECT points FROM `snake_game` WHERE `guid` = %d', guid))
    if not resultId then
        return -1
    end

    local value = result.getNumber(resultId, "points")
    result.free(resultId)
    return true and value
end