local ply = FindMetaTable("Player")

function ply:SaveData()
	print("Saving player data for " .. self:SteamID())
	self:SetPData("Level", self:GetNWInt("Level"))
	self:SetPData("MaxExp", self:GetNWInt("MaxExp"))
	self:SetPData("Exp", self:GetNWInt("Exp"))
	self:SetPData("SkillPoints", self:GetNWInt("SkillPoints"))
	self:SetPData("Stanima", ply.stanima)
	print("Data saved.")
end

function ply:LoadData()
	if self:GetPData("Level") == nil then
		self:SetDefaults()
	else
		print("Loading player data for " .. self:SteamID())
		self:SetNWInt("Level", tonumber(self:GetPData("Level")))
		self:SetNWInt("MaxExp", tonumber(self:GetPData("MaxExp")))
		self:SetNWInt("Exp", tonumber(self:GetPData("Exp")))
		self:SetNWInt("SkillPoints", tonumber(self:GetPData("SkillPoints")))
		ply.stanima = tonumber(self:GetPData("Stanima"))
		print("Loaded data.")
	end
end

function ply:SetDefaults()
	print("No data found for " .. self:SteamID() .. ". Setting defaults...")
	self:SetPData("Level", 1)
	self:SetPData("MaxExp", cMaxExp)
	self:SetPData("Exp", 0)
	self:SetPData("SkillPoints", 0)
	self:SetPData("Stanima", cStanima)
	print("Defaults set.")
	self:LoadData()
end