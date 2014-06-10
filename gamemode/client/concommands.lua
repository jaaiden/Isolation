concommand.Add("is_throwgrenade", function(ply, cmd, args, full)
	for _, w in pairs(ply:GetWeapons()) do
		if w:GetClass() == "weapon_frag" then
			if ply:GetAmmoCount(w:GetPrimaryAmmoType()) == 0 then
				ply:ChatPrint("You are out of grenades!")
				return
			end
        	lastWep = ply:GetActiveWeapon()
        	ply:ConCommand("use weapon_frag")
        	timer.Create("Check", 0.0001, 0, function()
        		if ply:GetActiveWeapon():GetClass() == "weapon_frag" then
			    	ply:ConCommand("+attack")
			    	timer.Create("LetGo", 0.5, 1, function()
			    		ply:ConCommand("-attack")
			    		timer.Create("SwitchBack", 1, 1, function()
			        		ply:ConCommand("use " .. lastWep:GetClass())
			        	end)
			    	end)
			    	timer.Remove("Check")
			    end
		    end)
        	return
	    end
    end
end)