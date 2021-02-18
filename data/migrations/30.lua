function onUpdateDatabase()
	print("> Updating database to version 31 (Boost Creature)")
	db.query("CREATE TABLE IF NOT EXISTS `boost_creature` ( `name` VARCHAR(255) NOT NULL , `exp` INT(11) NOT NULL DEFAULT '0' , `loot` INT(11) NOT NULL DEFAULT '0' ) ENGINE = InnoDB;")
	db.query("INSERT INTO `boost_creature` (`name`, `exp`, `loot`) VALUES ('', '0', '0');")
	return true
end