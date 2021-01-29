function onUpdateDatabase()
	print("> Updating database to version 37 (Snake Game)")
	db.query("CREATE TABLE `snake_game` (`id` INT(11) NOT NULL AUTO_INCREMENT, `guid` INT(11) NOT NULL, `points` INT(11) NOT NULL, PRIMARY KEY (`id`)) ENGINE = InnoDB;")
	return true
end
