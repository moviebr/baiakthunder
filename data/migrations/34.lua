function onUpdateDatabase()
	print("> Updating database to version 35 (Super UP)")
	db.query("CREATE TABLE `exclusive_hunts` (`hunt_id` int(2) NOT NULL, `guid_player` varchar(32) NOT NULL, `time` int(11) NOT NULL,`to_time` int(11) NOT NULL) ENGINE=MyISAM DEFAULT CHARSET=latin1;")
	db.query("INSERT INTO `exclusive_hunts` (`hunt_id`, `guid_player`, `time`, `to_time`) VALUES (20000, '0', 0, 0), (20001, '0', 0, 0);")
	return true
end
