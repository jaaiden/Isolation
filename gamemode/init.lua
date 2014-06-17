AddCSLuaFile("cl_init.lua")
AddCSLuaFile("client/lobby.lua")
AddCSLuaFile("client/concommands.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
include("resources/config.lua")
include("server/admin/extra.lua");
include("server/admin/commands.lua")
include("server/rounds.lua")
include("server/shop_system.lua")
include("server/player.lua")
include("resources/playerdata.lua")

started = false

function GM:PlayerConnect( name, ip )
	for _,plyr in pairs(player.GetAll()) do
		plyr:ChatPrint(name.." joined the game.")
	end
end

function GM:PlayerDisconnected(ply)
	ply:SaveData()
end

function GM:PlayerInitialSpawn( ply )
	print(ply:Nick() .. "<"..ply:SteamID()..">("..ply:IPAddress()..") spawned.")
	
	ply:SetModel("models/player/urban.mdl")

	InitValues(ply)
	UpdatePlayers()

	if ply:GetNWBool("Preperation") and started == true then ply:Spawn() end
end

function GM:PlayerAuthed( ply, steamID, uniqueID )
	if !started then
		started = true
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
end

function GM:PlayerSay(ply, msg, team)
	if msg:sub(1, 1) == "/" then
		for i = 1, table.getn(getCommands()) do
			if getRankByNum(ply) <= getCommands()[i][1] then
				args = getArgs(msg);
				if table.getn(args) == getCommands()[i][2] then
					cmd = string.lower(string.sub(string.Split(msg, " ")[1], 2));
					if cmd == getCommands()[i][3] then
						getCommands()[i][4](ply, args, msg);
						return "";
					end
				end
			end
		end
		return msg;
	end
	return msg;
end

-- Gamemode UI Binds (F1-F4)

function GM:ShowHelp(ply)
	umsg.Start("isolation_options", ply)
	umsg.End()
end

function GM:ShowTeam(ply)
	umsg.Start("isolation_pregame", ply)
	umsg.End()
end

/*function GM:ShowSpare2(ply)
	if ply:IsSuperAdmin() then
		for _,v in pairs(player.GetAll()) do
			v:ChatPrint(ply:Nick() .. " has reset your stats!")
			v:SetDefaults()
		end
	end
end*/

hook.Add("PlayerNoClip", "FeelFreeToTurnItOff", function(ply, desiredState)
	/*if desiredState then
		if ply:IsSuperAdmin() then
			return true
		else
			return false
		end
	else
		return true
	end*/
	return false
end)