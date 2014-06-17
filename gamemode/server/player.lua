function InitValues(ply)
    ply:LoadData()
    ply:SetNWInt("Cash", cStartMoney)
    ply:SetNWInt("Kills", 0)
    ply:SetNWInt("Downs", 0)
    ply:SetNWString("Info", "")
    ply:SetNWBool("ShowInfo", false)
    ply.shopEntity = nil
    ply.maxStamina = cMaxStamina
    ply.stamina = cMaxStamina
    ply.stamimaReg = false
    ply.duration = 0
end

function LevelUp(ply)
    ply:SetNWInt("Level", ply:GetNWInt("Level") + 1)
    ply:SetNWInt("MaxExp", ply:GetNWInt("MaxExp") + math.Round(ply:GetNWInt("MaxExp") / 4))
    ply:SetNWInt("SkillPoints", ply:GetNWInt("SkillPoints") + 1)
    ply:SaveData()
    for _,v in pairs(player.GetAll()) do
        v:ChatPrint(ply:Nick() .. " has reached Level " .. ply:GetNWInt("Level") .. "!")
    end
    ply:EmitSound("isolation/level_up.wav", 500, 100)
end

function GM:PlayerLoadout(ply)
    local plymodels = 
    {
        "models/jessev92/player/ww2/nz-hero/dempsey.mdl",
        "models/jessev92/player/ww2/nz-hero/nikolai.mdl",
        "models/jessev92/player/ww2/nz-hero/richtofen.mdl",
        "models/jessev92/player/ww2/nz-hero/takeo.mdl"
    }
    ply:SetModel(table.Random(plymodels))
    ply:SetWalkSpeed(cInitWalk)
    ply:SetRunSpeed(cInitSprint)
    ply:SetNoCollideWithTeammates(true)
    local oldhands = ply:GetHands()
    if ( IsValid( oldhands ) ) then oldhands:Remove() end

    local hands = ents.Create( "gmod_hands" )
    if ( IsValid( hands ) ) then
        ply:SetHands( hands )
        hands:SetOwner( ply )

        -- Which hands should we use?
        local cl_playermodel = ply:GetInfo( "cl_playermodel" )
        local info = player_manager.TranslatePlayerHands( cl_playermodel )
        if ( info ) then
            hands:SetModel( info.model )
            hands:SetSkin( info.skin )
            hands:SetBodyGroups( info.body )
        end

        -- Attach them to the viewmodel
        local vm = ply:GetViewModel( 0 )
        hands:AttachToViewmodel( vm )

        vm:DeleteOnRemove( hands )
        ply:DeleteOnRemove( hands )

        hands:Spawn()
    end

    for i = 1, #cInitLoadout, 3 do
        ply:Give(cInitLoadout[i])
        if cInitLoadout[i + 2] > 0 then
            ply:SetAmmo(cInitLoadout[i + 2], cInitLoadout[i + 1])
        end
    end
end

-- Prevent player friendly fire
function GM:PlayerShouldTakeDamage(ply, victim)
    if ply:IsPlayer() and victim:IsPlayer() then
        if ply == victim then
            return true
        end
        return false
    else
        return true
    end
end

-- Spectate players on death
hook.Add("PlayerDeath", "SpectatePlayer", function(victim, weapon, killer)
    if !game.SinglePlayer() then
        for _,p in pairs(player.GetAll()) do
            p:ChatPrint(victim:Nick() .. " has died!")
        end
    end

    print("\t>> Checking player count...")
    local plyalivecount = 0
    local stillalive = {}
    for _, p in pairs(player.GetAll()) do
        if p:Health() > 0 then
            table.insert(stillalive, p)
            plyalivecount = plyalivecount + 1
            print("\t\t>> There are " .. plyalivecount .. " players alive")
        end
    end
    if plyalivecount > 0 then
        print("\t>> Spectating player...")
        victim:Spectate(OBS_MODE_CHASE)
        victim:SpectateEntity(table.Random(stillalive))
        print("\t\t>> " .. victim:Nick() .. " is now spectating " .. victim:GetObserverTarget():Nick())
    else
        victim:Spectate(OBS_MODE_ROAMING)
        EndGame()
    end
end)

hook.Add("PlayerDeathThink", "WaitForRespawn", function(ply)
    if !ply:GetNWBool("Preperation") then return false else
        ply:UnSpectate()
        ply:Spawn()
    end
end)

function StaminaAdd(ply)
    if !timer.Exists("StaminaAdd") and ply.stamina < ply.maxStamina then
        timer.Create("StaminaAdd", 0.1, 1, function ()
            ply.stamina = ply.stamina + 1
        end)
    end
end

function StaminaSub(ply)
    if ply.stamina > 0 then
        if !timer.Exists("StaminaSub") then
            timer.Create("StaminaSub", 0.1, 1, function ()
                ply.stamina = ply.stamina - 1
            end)
        end
    else
        if ply.stamina < 0 then
            ply.stamina = 0
        end
        ply:SetRunSpeed(ply:GetWalkSpeed())
    end
end

function Stamina()
    for _, p in pairs(player.GetAll()) do
        if p != nil then
            if p.stamina > 0 then
                p:SetRunSpeed(cInitSprint)
            end
            if p:KeyDown(IN_SPEED) then
                p.staminaReg = false
                StaminaSub(p)
                if !timer.Exists("SprintWait") then
                    timer.Create("SprintWait", 4, 1, function()
                        p.staminaReg = true
                    end)
                else
                    timer.Adjust("SprintWait", 4, 1, function()
                        p.staminaReg = true
                    end)
                end
            end
            if p.staminaReg then
                StaminaAdd(p)
            end
        end
    end
end

hook.Add("Tick", "Input", function ()
    Stamina()
end)