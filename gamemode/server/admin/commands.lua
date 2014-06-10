local name = "[Admin] - ";
commands = {};

table.insert(commands, {2, 0, "noclip",
function (ply, args, msg)
	if ply:GetMoveType() == MOVETYPE_WALK then
		ply:SetMoveType(MOVETYPE_NOCLIP);
	else
		ply:SetMoveType(MOVETYPE_WALK);
	end
end});

table.insert(commands, {1, 1, "givemoney",
function (ply, args, msg)
	ply:SetNWInt("Cash", ply:GetNWInt("Cash") + tonumber(args[1]));
	ply:SaveData()
end});

table.insert(commands, {2, 2, "kick",
function (ply, args, msg)
	playerToKick = getPlayerByName(args[1]);
	if IsValid(playerToKick) then
		if playerToKick ~= ply then
			reason = string.sub(msg, 7 + string.len(args[1]));
			if getRankByNum(playerToKick) > 2 then
				playerToKick:Kick("Kicked - (Reason) " .. reason);
				PrintMessage(HUD_PRINTTALK, name..playerToKick:Name().." Was Kicked by "..ply:Name());
			elseif getRankByNum(playerToKick) > 1 then
				playerToKick:Kick("Kicked - (Reason) "..reason);
				PrintMessage(HUD_PRINTTALK, name..playerToKick:Name().." Was Kicked By "..ply:Name());
			else
				ply:PrintMessage(HUD_PRINTTALK, name.."Cannot Kick People With Your Rank Or Higher");
			end
		end
	else
		ply:PrintMessage(HUD_PRINTTALK, name.."Couldn't Find That Player");
	end
end});

table.insert(commands, {3, 1, "resetstats",
function (ply, args, msg)
	if args[1] == "me" then
		ply:SetDefaults()
		PrintMessage(HUD_PRINTTALK, name..ply:Name().." Deleted Their Player Data");
	else
		if getRankByNum(ply) == 1 then
			playerToDeleteData = getPlayerByName(args[1]);
			if IsValid(playerToDeleteData) then
				if playerToDeleteData ~= ply then
					ply:SetDefaults()
					PrintMessage(HUD_PRINTTALK, name..playerToDeleteData:Name().."'s Data Has Been Deleted By "..ply:Name());
				end
			else
				ply:PrintMessage(HUD_PRINTTALK, name.."Couldn't Find That Player");
			end
		end
	end
end});

table.insert(commands, {1, 2, "setrank",
function (ply, args, msg)
	playerToSetRank = getPlayerByName(args[1]);
	if IsValid(playerToSetRank) then
		if playerToSetRank ~= ply then
			playerToSetRank:SetUserGroup(args[2]);
			PrintMessage(HUD_PRINTTALK, name..ply:Name().." Set "..playerToSetRank:Name().."'s Rank To "..args[2]);
		end
	else
		ply:PrintMessage(HUD_PRINTTALK, name.."Couldn't Find That Player");
	end
end})

table.insert(commands, {3, 1, "kill",
function (ply, args, msg)
	if args[1] == "me" then
		ply:Kill()
		PrintMessage(HUD_PRINTTALK, name..ply:Name().." Killed Themself");
	else
		if getRankByNum(ply) <= 2 then
			playerToKill = getPlayerByName(args[1]);
			if IsValid(playerToKill) then
				if playerToKill ~= ply then
					if getRankByNum(playerToKill) > 2 then
						playerToKill:Kill();
						PrintMessage(HUD_PRINTTALK, name..playerToKill:Name().." Was Slayed By "..ply:Name());
					elseif getRankByNum(playerToKill) > 1 then
						playerToKill:Kill();
						PrintMessage(HUD_PRINTTALK, name..playerToKill:Name().." Was Slayed By "..ply:Name());
					else
						ply:PrintMessage(HUD_PRINTTALK, name.."Cannot Kill People With Your Rank Or Higher");
					end
				end
			else
				ply:PrintMessage(HUD_PRINTTALK, name.."Couldn't Find That Player");
			end
		end
	end
end});

table.insert(commands, {2, 1, "freeze",
function (ply, args, msg)
	if args[1] == "me" then
		if playerToFreeze:IsFrozen() then
			playerToFreeze:Freeze(false);
			PrintMessage(HUD_PRINTTALK, name..ply:Name().." Unfroze Themself");
		else
			playerToFreeze:Freeze(true);
			PrintMessage(HUD_PRINTTALK, name..ply:Name().." Froze Themself");
		end
	else
		playerToFreeze = getPlayerByName(args[1]);
		if playerToFreeze ~= NULL then
			if playerToFreeze ~= ply then
				if getRankByNum(playerToFreeze) > 2 then
					if playerToFreeze:IsFrozen() then
						playerToFreeze:Freeze(false);
						PrintMessage(HUD_PRINTTALK, name..playerToFreeze:Name().." Was Unfrozen By "..ply:Name());
					else
						playerToFreeze:Freeze(true);
						PrintMessage(HUD_PRINTTALK, name..playerToFreeze:Name().." Was Frozen By "..ply:Name());
					end
				elseif getRankByNum(playerToFreeze) > 1 then
					if playerToFreeze:IsFrozen() then
						playerToFreeze:Freeze(false);
						PrintMessage(HUD_PRINTTALK, name..playerToFreeze:Name().." Was Unfrozen By "..ply:Name());
					else
						playerToFreeze:Freeze(true);
						PrintMessage(HUD_PRINTTALK, name..playerToFreeze:Name().." Was Frozen By "..ply:Name());
					end
				else
					ply:PrintMessage(HUD_PRINTTALK, name.."Cannot Freeze People With Your Rank Or Higher");
				end
			end
		else
			ply:PrintMessage(HUD_PRINTTALK, name.."Couldn't Find That Player");
		end
	end
end});

table.insert(commands, {3, 1, "god",
function (ply, args, msg)
	if args[1] == "me" then
		ply:GodEnable();
		PrintMessage(HUD_PRINTTALK, name..ply:Name().." Has Godded Themself");
	else
		playerToFreeze = getPlayerByName(args[1]);
		if playerToFreeze ~= NULL then
			if playerToFreeze ~= ply then
				if getRankByNum(playerToFreeze) > 2 then
					playerToFreeze:GodEnable();
					PrintMessage(HUD_PRINTTALK, name..playerToFreeze:Name().." Has Been Godded By "..ply:Name());
				elseif getRankByNum(playerToFreeze) > 1 then
					playerToFreeze:GodEnable();
					PrintMessage(HUD_PRINTTALK, name..playerToFreeze:Name().." Has Been Godded By "..ply:Name());
				else
					ply:PrintMessage(HUD_PRINTTALK, name.."Cannot God People With Your Rank Or Higher");
				end
			end
		else
			ply:PrintMessage(HUD_PRINTTALK, name.."Couldn't Find That Player");
		end
	end
end});

table.insert(commands, {2, 1, "ungod",
function (ply, args, msg)
	if args[1] == "me" then
		ply:GodDisable();
		PrintMessage(HUD_PRINTTALK, name..ply:Name().." Has Ungodded Themself");
	else
		playerToFreeze = getPlayerByName(args[1]);
		if playerToFreeze ~= NULL then
			if playerToFreeze ~= ply then
				if getRankByNum(playerToFreeze) > 2 then
					playerToFreeze:GodDisable();
					PrintMessage(HUD_PRINTTALK, name..playerToFreeze:Name().." Has Been Ungodded By "..ply:Name());
				elseif getRankByNum(playerToFreeze) > 1 then
					playerToFreeze:GodDisable();
					PrintMessage(HUD_PRINTTALK, name..playerToFreeze:Name().." Has Been Ungodded By "..ply:Name());
				else
					ply:PrintMessage(HUD_PRINTTALK, name.."Cannot UnGod People With Your Rank Or Higher");
				end
			end
		else
			ply:PrintMessage(HUD_PRINTTALK, name.."Couldn't Find That Player");
		end
	end
end});

table.insert(commands, {2, 1, "goto",
function (ply, args, msg)
	playerToGoTo = getPlayerByName(args[1]);
	if IsValid(playerToGoTo) then
		if playerToGoTo ~= ply then
			ply:SetMoveType(MOVETYPE_NOCLIP);
			ply:SetPos(playerToGoTo:GetPos());
			PrintMessage(HUD_PRINTTALK, name..ply:Name().." Has Teleported To "..playerToGoTo:Name());
		end
	else
		ply:PrintMessage(HUD_PRINTTALK, name.."Couldn't Find That Player");
	end
end});

table.insert(commands, {2, 2, "teleport",
function (ply, args, msg)
	if args[1] == "me" then
		ply:GodDisable();
		PrintMessage(HUD_PRINTTALK, name..ply:Name().." Has Ungodded Themself");
	else
		playerToTeleport = getPlayerByName(args[1]);
		playerToTeleportTo = getPlayerByName(args[2]);
		if IsValid(playerToTeleport) and IsValid(playerToTeleportTo) then
			if playerToTeleport ~= ply then
				if getRankByNum(playerToTeleport) > 2 then
					playerToTeleport:SetPos(playerToTeleportTo:GetPos());
					PrintMessage(HUD_PRINTTALK, name..playerToTeleport:Name().." Has Been Teleport To "..playerToTeleportTo:Name());
				elseif getRankByNum(playerToTeleport) > 1 then
					playerToTeleport:SetPos(playerToTeleportTo:GetPos());
					PrintMessage(HUD_PRINTTALK, name..playerToTeleport:Name().." Has Been Teleport To "..playerToTeleportTo:Name().." By Owner");
				else
					ply:PrintMessage(HUD_PRINTTALK, name.."Cannot Teleport People With Your Rank Or Higher");
				end
			end
		else
			ply:PrintMessage(HUD_PRINTTALK, name.."Couldn't Find That Player");
		end
	end
end});

table.insert(commands, {1, 2, "give",
function (ply, args, msg)
	if args[1] == "me" then
		ply:Give(args[2])
		PrintMessage(HUD_PRINTTALK, name..ply:Name().." gave themself a " .. args[2]);
	else
		if getRankByNum(ply) <= 2 then
			playerToGive = getPlayerByName(args[1]);
			if IsValid(playerToGive) then
				if playerToGive ~= ply then
					if getRankByNum(playerToGive) > 2 then
						playerToGive:Give(args[2]);
						PrintMessage(HUD_PRINTTALK, name..playerToGive:Name().." was given a " .. args[2] .. " by "..ply:Name());
					elseif getRankByNum(playerToGive) > 1 then
						playerToGive:Give(args[2]);
						PrintMessage(HUD_PRINTTALK, name..playerToGive:Name().." was given a " .. args[2] .. " by "..ply:Name());
					else
						ply:PrintMessage(HUD_PRINTTALK, name.."Couldn't give weapon to player of your rank or higher.");
					end
				end
			else
				ply:PrintMessage(HUD_PRINTTALK, name.."Couldn't Find That Player");
			end
		end
	end
end});

table.insert(commands, {1, 2, "giveammo",
function (ply, args, msg)
	if args[1] == "me" then
		ply:GiveAmmo(args[2], ply:GetActiveWeapon():GetPrimaryAmmoType())
		PrintMessage(HUD_PRINTTALK, name..ply:Name().." gave themself " .. args[2] .. " ammo.");
	else
		if getRankByNum(ply) <= 2 then
			playerToGive = getPlayerByName(args[1]);
			if IsValid(playerToGive) then
				if playerToGive ~= ply then
					if getRankByNum(playerToGive) > 2 then
						playerToGive:GiveAmmo(args[2], playerToGive:GetActiveWeapon():GetPrimaryAmmoType());
						PrintMessage(HUD_PRINTTALK, name..playerToGive:Name().." was given " .. args[2] .. " ammo by "..ply:Name());
					elseif getRankByNum(playerToGive) > 1 then
						playerToGive:GiveAmmo(args[2], playerToGive:GetActiveWeapon():GetPrimaryAmmoType());
						PrintMessage(HUD_PRINTTALK, name..playerToGive:Name().." was given " .. args[2] .. " ammo by "..ply:Name());
					else
						ply:PrintMessage(HUD_PRINTTALK, name.."Couldn't give ammo to player of your rank or higher.");
					end
				end
			else
				ply:PrintMessage(HUD_PRINTTALK, name.."Couldn't Find That Player");
			end
		end
	end
end});

table.insert(commands, {3, 1, "me",
function (ply, args, msg)
	for _,v in pairs(player.GetAll()) do
		PrintToChat("*" .. ply:Nick() .. " " .. args[1], Color(63, 232, 181))
	end
end});

function getCommands()
	return commands;
end