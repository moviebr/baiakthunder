function onUpdateDatabase()
	print("> Updating database to version 32 (Boss Room)")
	db.query("CREATE TABLE `boss_room` (`room_id` int(2) NOT NULL, `guid_player` VARCHAR(32) NOT NULL, `time` int(11) NOT NULL, `to_time` int(11) NOT NULL) ENGINE=MyISAM DEFAULT CHARSET=latin1")
	return true
end
