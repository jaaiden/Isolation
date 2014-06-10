/*

Isolation Configuration File
----------------------------

Use this file to configure Isolation for your server environment. Each value will have a description next to it, so you know what it does.

You can view more in-depth documentation at http://docs.isolation.cf

*/

/* Game Server Configuration
===============================*/

-- Preparation time in seconds between each round. (Default: 15)
cPrepTime = 15
-- Adds experience to killer of NPC. (This will be multiplied by the round number; Default: 3)
cExperience = 2
-- Initial zombie count for first round. (Each consecutive round will increase this; Default: 8)
cInitZombies = 16
-- Maximum spawn time in seconds for zombie spawning. (Default: 3)
cMaxSpawnTime = 1
-- Starting health for zombies (Default: 5)
cZHealth = 5
-- Money per NPC kill (Default: 10)
cMoneyPerKill = 10
-- Minimum amount of players before starting the game (Multiplayer ONLY; Default: 2; Maximum: 8)
cMinPlayers = 2

/* Global Database Configuration:
---------------------------------
The Isolation Global Database is a central datacenter for holding global player stats.

Think of this like leaderboards. Any player who joins a server with the Global Database will be able to access
their stats from another Global Database server. This way they can keep the same level and skillpoints they earned from another server.

A good server owner would enable this for the best possible experience on their servers. However it requires the MySQLOO and libmysql modules to be installed,
so this option is disabled by default. (Especially for the Workshop edition of the gamemode.)

If you are running Windows for your server, use these links:
	MySQLOO: http://drakehawke-gmod.googlecode.com/svn/trunk/AndyVincentGMod/RELEASE/gmsv_mysqloo_win32.dll
	libmysql.dll: http://puu.sh/1fhWu

If you are running Linux for your server, use these instead:
	MySQLOO: http://drakehawke-gmod.googlecode.com/svn/trunk/AndyVincentGMod/RELEASE/gmsv_mysqloo_linux.dll
	libmysql.so: http://puu.sh/1ikIN

Place your MySQLOO.dll file in "your/server/path/garrysmod/lua/bin" (If the folder doesn't exist, create it)
Place your specific libmysql file in the root folder of your server (Where srcds.exe/srcds_run is)

If you would like to enable this feature (recommended) just change 'false' to 'true' below. */

enableDatabase = false

/* Player configuration
=======================*/

-- Initial weapon loadout
cInitLoadout = {
	"weapon_bo1_1911", "Pistol", 120
}
-- Amount of money to start with. (Default: 500)
cStartMoney = 500
-- Initial max experience. (Default: 400)
cMaxExp = 800
-- Initial max stamina.
cMaxStamina = 100
-- Initial walk speed
cInitWalk = 150
-- Initial sprint speed.
cInitSprint = 225