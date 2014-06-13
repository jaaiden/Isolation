zombieSpawnsEnabled = {}
zombieSpawns = {}
maxZombies = 0
experience = 3
preperationTime = 15
timeLeft = 15
minSpawnTime = 3
maxSpawnTime = 15
preperation = true
zombies = 0
round = 0
health = 5
moneyPerKill = 10

function FindZombieSpawns()
    for _, v in pairs(ents.GetAll()) do
        local sep = string.Explode(" ", v:GetName())
        if sep[1] == "ZombieSpawn" then
            table.insert(zombieSpawns, v)
        end
        if not table.HasValue(tonumber(sep[2])) then
        		table.insert(zombieSpawnsEnabled, tonumber(sep[2]))
        	if tonumber(sep[2]) == 0 then
        		table.insert(zombieSpawnsEnabled, true)
        	else
        		table.insert(zombieSpawnsEnabled, false)
        	end
        end
    end
    if #zombieSpawns == 0 then
    	print("\tIsolation: This map has no zombie spawns!")
    end
end

function UpdatePlayers()
	for _,p in pairs(player.GetAll()) do
		p:SetNWInt("Zombies", zombies)
		p:SetNWInt("Round", round)
		p:SetNWBool("Preperation", preperation)
		if timer.Exists("Preperation") then
			p:SetNWInt("TimeLeft", timer.RepsLeft("Preperation"))
		else
			p:SetNWInt("TimeLeft", 0)
		end
	end
end

function ClosestPlayer(npc)
	closest = 0
	ply = table.Random(player.GetAll())
	for _, p in pairs(player.GetAll()) do
		dis = npc:GetPos():Distance(p:GetPos())
		if closest > dis then
			closest = dis
			ply = p
		end
	end
	return ply
end

function NextRound(inc)
	sound.Play("RoundStart", Vector(0, 0, 0))
	round = round + 1
	maxZombies = maxZombies + inc
	zombies = maxZombies
	UpdatePlayers()
	for _, p in pairs(player.GetAll()) do
		if p:Health() > 0 then
			if !p:HasWeapon("weapon_frag") then
				p:Give("weapon_frag")
				p:SetAmmo(0, "Grenade")
			end
			if p:GetAmmoCount(p:GetWeapon("weapon_frag"):GetPrimaryAmmoType()) < 3 then
				p:GiveAmmo(2, "Grenade")
			elseif p:GetAmmoCount(p:GetWeapon("weapon_frag"):GetPrimaryAmmoType()) < 4 then
				p:GiveAmmo(1, "Grenade")
			end
		end
	end
	timer.Create("ZombieSpawn", cMaxSpawnTime, maxZombies, function ()
		zombie = ents.Create("npc_fastzombie")
		zombie:SetHealth(health * round)
		zSpawn = zombieSpawns[math.random(1, #zombieSpawns)]
		zombie:SetPos(zSpawn:GetPos())
		zombie:Spawn()
		ply = ClosestPlayer(zombie)
		zombie:SetLastPosition(ply:GetPos())
		zombie:SetEnemy(ply)
		zombie:UpdateEnemyMemory(ply, ply:GetPos())
		zombie:SetSchedule(SCHED_CHASE_ENEMY)
	end)
end

function InitGame(prepTime, exp, initZombies, minSpwnTime, maxSpwnTime, zHealth, mPK)
	for _,p in pairs(player.GetAll()) do
		p:ChatPrint("Game initialized, starting in " .. preperationTime .. " seconds!")
	end
	preperationTime = prepTime
	experience = exp
	minSpawnTime = minSpwnTime
	maxSpawnTime = maxSpwnTime
	health = zHealth
	moneyPerKill = mPK
	maxZombies = 0
	zombies = 0
	zombieSpawns = ents.FindByName("ZombieSpawn 00")
	preperation = true
	timer.Create("Preperation", 1, preperationTime, function()
		UpdatePlayers()
		if timer.RepsLeft("Preperation") == 0 then
			preperation = false
			UpdatePlayers()
			for _,p in pairs(player.GetAll()) do
				p:ChatPrint("Game has now started!")
			end
			NextRound(initZombies)
		end
	end)
end

function EndGame()
	for _, z in pairs(ents.FindByClass("npc_fastzombie")) do
		z:Remove()
	end
	for _, p in pairs(player.GetAll()) do
		p:SetNWInt("Cash", cStartMoney)
	    p:SetNWInt("Kills", 0)
	    p:SetNWInt("Downs", 0)
	end
	umsg.Start("isolation_pregame", nil)
	umsg.End()
	InitGame(
		cPrepTime,
		cExperience,
		cInitZombies,
		cMinSpwnTime,
		cMaxSpawnTime,
		cZHealth,
		cMoneyPerKill
	)
end

hook.Add("OnNPCKilled", "Zombie Update", function (npc, attacker, inflictor)
	if npc:GetClass() == "npc_fastzombie" then
		zombies = zombies - 1
		if attacker:IsPlayer() then
			attacker:SetNWInt("Kills", attacker:GetNWInt("Kills") + 1)
			attacker:SetNWInt("Exp", attacker:GetNWInt("Exp") + (experience * round))
			if attacker:GetNWInt("Exp") >= attacker:GetNWInt("MaxExp") then
				attacker:SetNWInt("Exp", attacker:GetNWInt("Exp") % attacker:GetNWInt("MaxExp"))
				LevelUp(attacker)
			end
		end
		if zombies == 0 then
			sound.Play("RoundEnd", Vector(0, 0, 0))
			preperation = true
			timer.Create("Preperation", 1, preperationTime, function()
				UpdatePlayers()
				if timer.RepsLeft("Preperation") == 0 then
					preperation = false
					UpdatePlayers()
					NextRound(math.Round(maxZombies / 4))
				end
			end)
		end
		for _, h in pairs(ents.FindByClass("npc_headcrab_fast")) do
			h:Remove()
		end
		UpdatePlayers()
	end
end)

hook.Add("EntityTakeDamage", "Cash", function (target, dmginfo)
	if !target:IsPlayer() then
		dmginfo:GetAttacker():SetNWInt("Cash", dmginfo:GetAttacker():GetNWInt("Cash") + moneyPerKill)
	end
end)

timer.Create("ZombieSpawn", 15, 0, function ()
	for _, z in pairs(ents.FindByClass("npc_zombie")) do
		ply = ClosestPlayer(z)
		z:SetLastPosition(ply)
		z:SetEnemy(ply)
		z:UpdateEnemyMemory(ply, ply:GetPos())
		z:SetSchedule(SCHED_CHASE_ENEMY)
	end
end)