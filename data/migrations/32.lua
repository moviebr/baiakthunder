function onUpdateDatabase()
	print("> Updating database to version 33 (Log de AOL e Bless)")
	db.query("ALTER TABLE `player_deaths` ADD `bless` INT(11) NOT NULL DEFAULT '0';")
	db.query("ALTER TABLE `player_deaths` ADD `aol` VARCHAR(10) NOT NULL DEFAULT 'false';")
	return true
end
