function onUpdateDatabase()
	print("> Updating database to version 27 (Implementing Auction System)")
	db.query("CREATE TABLE `auction_system` (`id` int(11) NOT NULL AUTO_INCREMENT, `player_id` int(11) NOT NULL, `item_name` varchar(255) NOT NULL, `item_id` smallint(6) NOT NULL, `count` smallint(5) NOT NULL, `value` int(7) NOT NULL, `date` bigint(20) NOT NULL, PRIMARY KEY (`id`), FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8;")
	return true
end