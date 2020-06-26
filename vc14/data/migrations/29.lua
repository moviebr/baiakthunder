function onUpdateDatabase()
	print("> Updating database to version 30 (AutoLoot)")
	db.query("ALTER TABLE `players` ADD `autoloot` BLOB DEFAULT NULL")
	return true
end