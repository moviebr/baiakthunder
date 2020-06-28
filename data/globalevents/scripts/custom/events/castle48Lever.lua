function onThink(interval)
	if Game.getStorageValue(Castle48H.storageGlobal) ~= -1 and Game.getStorageValue(Castle48H.storageGuildLever) ~= -1 then
		local id = Game.getStorageValue(Castle48H.storageGuildLever)
		-- local sqlTime = db.storeQuery("SELECT time FROM `castle_48` WHERE id =".. id)
		-- if not sqlTime then
		-- 	return false
		-- end
		-- local timeSelect = result.getDataLong(sqlTime, "time")
		local update = db.query("UPDATE `castle_48` SET `time` = `time` + 60 * 1000 WHERE guild_id = ".. id)
		if not update then
			local guild = db.query("INSERT INTO castle_48 (`guild_id`, `time`) VALUES (".. id ..", 60000)")
			return false
		end

	end
	return true
end
