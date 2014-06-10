-- Require MySQLOO Module
require("mysqloo")

-- Get Player information
local ply = FindMetaTable("Player")

-- Connect to Global Database
local db = mysqloo.connect("nyaa-nyaa.com", "isolation_gm", "3xs94axY7LC8WLhP", "isolation", 3306)

local oldPrint = print
local function print(s)
	oldPrint("\n[IsolationDB] >> " .. s)
end

-- Create onConnected() function
function db:onConeected()
	print("Server connected to Isolation Global Database.")
end

-- Create onConnectionFailed() function
function db:onConnectionFailed(err)
	print("Server failed to connect to Isolation Global Database.\n\t[Error] " .. err)
end

/* Player-Specific Code
=======================*/

function ply:GetShortSteamID()
	local id = tostring(self:SteamID())
	local shortid = string.Replace(id, "STEAM_0:0:", "")
	local shortid = string.Replace(id, "STEAM_0:1:", "")
	return shortid
end

function GetPlayerData(data, ply)
	PrintTable(data)
	local dbrow = data[1]
	local steamid = row['steamid']
	local level = row['level']
	local spoints = row['spoints']

	print("Retrieving info for " .. ply:Nick() .. "...")
	print("SteamID -> " .. tostring(steamid))
	print("Level -> " .. tostring(level))
	print("SPoints -> " .. tostring(spoints))

	ply:SetNWInt("Level", level)
	ply:SetNWInt("SkillPoints", spoints)
end

function ply:SaveData()
	local steamid = self:SteamID()
	local level = self:GetNWInt("Level")
	local spoitns = self:GetNWInt("SkillPoints")

	local qry = db:query("UPDATE stats SET level='" .. level .. "', spoints='" .. spoints .. "' WHERE steamid='" .. steamid .. "'")
	qry:start()

	function qry:onSuccess(data)
		PrintTable(data)
		print("Saved Player data.")
	end
	function qry:onError(err, sql)
		print("Count not save data.\n\t[Error]: " .. err .. "\n\t[Code]: " .. sql)
	end
	-- self:ChatPrint("Saved data.")
end

function ply:New()
	local id = self:SteamID()
	local qry = db:query("INSERT INTO stats (`steamid`, `level`, `spoints`) VALUES ('" .. self:SteamID() .. "', '" .. self:GetNWInt("Level") .. "', '" .. self:GetNWInt("SkillPoints") .. "')")
	qry:start()

	function qry:onSuccess()
		print("Created row for new player.")
	end
	
	function qry:onError(err, sql)
		print("Could not create new row for player.\n\t[Error]: " .. err .. "\n\t[Code]: " .. sql)
	end
	
	ply:SaveData()
	ply:CheckDB()
end

function ply:CheckDB()
	local id = self:SteamID()

	local res = db:query("SELECT * FROM stats WHERE steamid='" .. id .. "'")
	res:start()

	function res:onSuccess(data)
		PrintTable(data)
		if(data and data[1]) then
			print("Found data for " .. self:Nick())
			GetData(data, ply)
		else
			ply:New()
		end
	end
end

function InitSpawn(ply)
	timer.Create("SaveDBInfo", 300, 0, function()
		ply:Save()
	end)
	ply:CheckDB()
end
hook.Add("PlayerAuthed", "LoadDBData", InitSpawn)

concommand.Add("isolation_savedata", function(ply, cmd, args)
	if ply:IsAdmin() then
		if player.GetAll() == {} then
			print("No players online.")
		else
			for _,v in pairs(player.GetAll()) do
				v:ChatPrint(ply:Nick() .. " forced a session save. Please wait...")
				v:SaveData()
				v:ChatPrint("Save complete.")
				print("Save complete.")
			end
		end
	else
		ply:ChatPrint("You must be an admin to do that!")
		print(ply:Nick() .. " attempted to force a server save.\n\tSteamID: " .. ply:SteamID() .. "\n\tIP Address: " .. ply:IPAddress())
	end
end)

db:connect()







