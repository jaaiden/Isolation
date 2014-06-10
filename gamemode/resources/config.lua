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