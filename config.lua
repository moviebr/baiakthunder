GMFullLightOnEquipItem = true
closedWorld = false
showMonsterExiva = true
antiBot = true
guildLeaderSquare = true
pvpBalance = true
pushCruzado = true

monsterBonusHealth = 0.5
monsterBonusSpeed = 0.02
monsterBonusDamage = 0.02

worldType = "pvp"
hotkeyAimbotEnabled = true
protectionLevel = 50
killsToRedSkull = 100
killsToBlackSkull = 150
pzLocked = 30000
removeChargesFromRunes = false
removeChargesFromPotions = false
removeWeaponAmmunition = false
removeWeaponCharges = false
timeToDecreaseFrags = 24 * 60 * 60 * 1000
whiteSkullTime = 30 * 1000
stairJumpExhaustion = 1000
experienceByKillingPlayers = false
expFromPlayersLevelRange = 100

spoofEnabled = false
spoofDailyMinPlayers = 1
spoofDailyMaxPlayers = 2050
spoofNoiseInterval = 1000
spoofNoise = 0
spoofTimezone = -1
spoofInterval = 1
spoofChangeChance = 70
spoofIncrementChange = 100

ip = "127.0.0.1"
bindOnlyGlobalAddress = false
loginProtocolPort = 7171
gameProtocolPort = 7172
statusProtocolPort = 7171
maxPlayers = 1900
motd = "Bem-vindo ao Baiak Thundera!"
onePlayerOnlinePerAccount = true
allowClones = false
allowWalkthrough = true
serverName = "Baiak Thunder"
statusTimeout = 5000
replaceKickOnLogin = true
maxPacketsPerSecond = 475
packetCompression = true

deathLosePercent = -1

housePriceEachSQM = 1000
houseRentPeriod = "weekly"

timeBetweenActions = 200
timeBetweenExActions = 1000

mapName = "real02"
mapAuthor = "Felipe"

marketOfferDuration = 30 * 24 * 60 * 60
premiumToCreateMarketOffer = true
checkExpiredMarketOffersEachMinutes = 60
maxMarketOffersAtATimePerPlayer = 100

mysqlHost = "127.0.0.1"
mysqlUser = "root"
mysqlPass = ""
mysqlDatabase = "gesior_downgrade"
mysqlPort = 3306
mysqlSock = ""
passwordType = "sha1"
sqlType = "mysql"

allowChangeOutfit = true
freePremium = false
kickIdlePlayerAfterMinutes = 15
maxMessageBuffer = 4
emoteSpells = true
classicEquipmentSlots = false
classicAttackSpeed = false
showScriptsLogInConsole = false
showOnlineStatusInCharlist = false

serverSaveNotifyMessage = true
serverSaveNotifyDuration = 5
serverSaveCleanMap = false
serverSaveClose = false
serverSaveShutdown = true

experienceStages = {
	{ minlevel = 1, maxlevel = 100, multiplier = 400 },
	{ minlevel = 101, maxlevel = 200, multiplier = 300 },
	{ minlevel = 201, maxlevel = 250, multiplier = 150 },
	{ minlevel = 251, maxlevel = 320, multiplier = 75 },
	{ minlevel = 321, maxlevel = 390, multiplier = 35 },
	{ minlevel = 391, maxlevel = 420, multiplier = 15 },
	{ minlevel = 421, maxlevel = 480, multiplier = 4 },
	{ minlevel = 481, maxlevel = 500, multiplier = 2 },
	{ minlevel = 501, maxlevel = 550, multiplier = 1 },
	{ minlevel = 551, maxlevel = 600, multiplier = 0.5 },
	{ minlevel = 601, maxlevel = 670, multiplier = 0.1 },
	{ minlevel = 671, multiplier = 0.05 },
}

rateExp = 5
rateSkill = 3
rateLoot = 2
rateMagic = 3
rateSpawn = 2
spawnMultiplier = 1

-- removeOnDespawn will remove the monster if true or teleport it back to its spawn position if false
deSpawnRange = 2
deSpawnRadius = 50
removeOnDespawn = true

staminaSystem = true

warnUnsafeScripts = true
convertUnsafeScripts = true

defaultPriority = "high"
startupDatabaseOptimization = false

ownerName = "Movie, Felipe & Crypter"
ownerEmail = ""
url = ""
location = "Brazil"
