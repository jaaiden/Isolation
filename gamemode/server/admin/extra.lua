function getPlayerBySteamId(steamId)
	for i, v in pairs(player.GetAll()) do
		if v:SteamID():lower() == steamId:lower() then
			return v;
		end
	end
	return NULL;
end

function getPlayerByName(name)
	for i, v in pairs(player.GetAll()) do
		if string.match(v:Name():lower(), name:lower()) ~= nil then
			return v;
		end
	end
	return NULL;
end

function getRankByNum(ply)
	if ply:IsUserGroup("superadmin") then
		return 1;
	elseif ply:IsUserGroup("admin") then
		return 2;
	end
	return 3;
end

function getArgs(message)
	oArgs = string.Split(message, " ");
	args = {};
	for i = 2, table.getn(oArgs) do
		args[i - 1] = oArgs[i];
	end
	return args;
end

function findValueInTable(array, value)
	for i = 1, table.getn(array) do
		if array[i] == value then
			return i;
		end
	end
	return nil;
end