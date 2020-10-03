function onUpdateDatabase()
	print("> Updating database to version 34 (Castle 48H)")
	db.query("CREATE TABLE `castle_48` (`guild_id` int(3) NOT NULL) ENGINE=MyISAM DEFAULT CHARSET=latin1")
	return true
end
