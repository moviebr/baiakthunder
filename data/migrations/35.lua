function onUpdateDatabase()
	print("> Updating database to version 36 (Hunted System)")
	db.query("CREATE TABLE `hunted_system` ( `playerGuid` VARCHAR(255) NOT NULL , `targetGuid` VARCHAR(255) NOT NULL, `type` VARCHAR(255) NOT NULL, `count` INT(11) NOT NULL) ENGINE = InnoDB;")
	return true
end
