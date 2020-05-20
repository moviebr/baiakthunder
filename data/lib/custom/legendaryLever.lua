if not randomitems then
	
	randomitems = {}	
	
	function randomitems:saveLog(...)
		local message = '[%s] %s has found %s %s\n'		
		local file = io.open('data/logs/randomitems/' .. ... .. '.log', 'a')
		
		if not file then
			return
		end

		io.output(file)
		io.write(message:format(os.date('%d/%m/%Y %H:%M'), ...))
		io.close(file)
	end
	
	function randomitems:random(p, obj, exhaust, item)
		if not rawequal(type(obj), 'table') then
			return error('table of items not found.')
		end
				
		if not p:getGroup():getAccess() then
			
			-- double-click protect
			if obj.exhaust and obj.exhaust > os.time() then
				return p:getMoney() >= obj.coust and p:sendCancelMessage('Alavanca exausta por ' .. obj.exhaust - os.time() ..' segundos.') or true
			end	
			
			-- the exhaust of x object is global for all players
			obj.exhaust = os.time() + (not exhaust and 2 or exhaust)
			
			if obj.onlypremium and not p:isPremium() then
				return p:say('Desculpe, apenas jogadores premium podem usar esta alavanca.', TALKTYPE_MONSTER_SAY)
			end
			
			if not p:removeMoney(obj.coust) then		
				return p:say('Falha no pagamento, você precisa de ' .. obj.coust .. ' gold coins.', TALKTYPE_MONSTER_SAY)
			end
			
			if exhaust > 1 then
				item:transform(item.itemid + 1)
				
				addEvent(function()
					item:transform(item.itemid - 1)
				end, ((obj.exhaust - os.time())-1) * 1000)
			end
			
		end
		
		-- this function is necessary to repeat the loop if the result was nil
		local function randomize()
		
			for _, it in ipairs(obj) do
				if it.chance>=100-(math.random()*100) then
					local item = p:addItem(it.itemid, it.amount)
					local name = not rawequal(type(item), 'table') and item:getName() or item[1]:getName()
					
					self:saveLog(p:getName(), it.amount, name)
					p:save() -- [security] save player	
					
					if it.broadcast then
						local msg = '[Legendary Levers] %s has found %s %s.'
						
						if not p:getGroup():getAccess() then	
						
							Game.broadcastMessage(msg:format(p:getName(), rawequal(it.amount, 1) and 'a' or it.amount, name .. '' .. (it.amount > 1 and 's' or '')), MESSAGE_EVENT_ADVANCE)
						end
					end	 
					
					p:sendTextMessage(MESSAGE_INFO_DESCR, 'Congratulations, you have found ' .. (rawequal(it.amount, 1) and 'a' or it.amount) .. ' ' .. name .. '' .. (it.amount > 1 and 's.' or '.'))									
					return not p:isInGhostMode() and p:getPosition():sendMagicEffect(it.broadcast and 7 or 15)
				end
			end
			
			-- repeat
			randomize()
		end
		
		-- called by self:random(...)
		randomize()
		
		return true
	end

else
	
	error('>> randomitems/lib.lua loading failed.')
end