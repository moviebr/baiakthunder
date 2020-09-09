function onUpdateDatabase()
	print("> Updating database to version 33 (Log de AOL e Bless)")
	db.query("ALTER TABLE `player_deaths` ADD `bless` INT(11) NOT NULL DEFAULT '0';")
	db.query("ALTER TABLE `player_deaths` ADD `aol` INT(11) NOT NULL DEFAULT '0';")
	return true
end
