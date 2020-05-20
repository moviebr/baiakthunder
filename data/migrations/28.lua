function onUpdateDatabase()
	print("> Updating database to version 29 (Online Time)")
	db.query("ALTER TABLE `players` ADD `online_time` int(11) NOT NULL DEFAULT 0")
	return true
end