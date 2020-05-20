function onUpdateDatabase()
	print("> Updating database to version 26 (Implementing Castle 24H)")
	db.query("CREATE TABLE IF NOT EXISTS `castle` (`name` varchar(255) NOT NULL, `guild_id` int(11) NOT NULL DEFAULT '0') ENGINE=InnoDB DEFAULT CHARSET=utf8;")
	db.query("INSERT INTO `castle` (`name`, `guild_id`) VALUES ('Guild', '-1');")
	return true
end