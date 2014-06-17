local ready = false

function InitDoors()
    for _, s in pairs(ents.FindByClass("prop_door_rotating")) do
        if string.StartWith(s:GetName(), "door") then
            s:Fire("unlock", "", 0)
            s:Fire("close", "", 0)
            s:Fire("lock", "", 0)
            s.opened = false
        end
    end
    ready = true
end

function FindShops()
    local shops = {}
    for _, s in pairs(ents.GetAll()) do
        local split = string.Explode(" ", s:GetName())
        if split[1] == "shop" then
            table.insert(shops, s)
        end
    end
    return shops
end

function SetDoorOpened(num, enable)
    for _, s in pairs(ents.FindByClass("prop_door_rotating")) do
        local sep = string.Explode(" ", s:GetName())
        if tonumber(sep[2]) == num then
            s.opened = enable
        end
    end
end

function IsDoorOpened(num)
    for _, s in pairs(ents.FindByClass("prop_door_rotating")) do
        local sep = string.Explode(" ", s:GetName())
        if tonumber(sep[2]) == num then
            return s.opened
        end
    end
    return false
end

function DoorInfo(info, ply)
    ply:SetNWBool("ShowInfo", true)
    ply:SetNWString("Info", "Press F to open this door for $" .. info[5])
end

function WeaponInfo(info, ply)
    weaponClass = info[3]
    weaponCost = tonumber(info[4])
    ammoCost = tonumber(info[5])
    upgradedAmmoCost = tonumber(info[6])
    if !ply:HasWeapon(weaponClass) then
        ply:SetNWBool("ShowInfo", true)
        ply:SetNWString("Info", "Press F to buy the " .. weapons.Get(weaponClass).PrintName .. " for $" .. info[4])
        return
    end
    if ply:HasWeapon(weaponClass) then
        ply:SetNWBool("ShowInfo", true)
        ply:SetNWString("Info", "Press F to buy " .. weapons.Get(weaponClass).PrintName .. " ammo for $" .. info[5])
        return
    end
    if ply:HasWeapon(weaponClass .. "_upgraded") and ply:GetNWInt("Cash") >= upgradedAmmoCost then
        ply:SetNWBool("ShowInfo", true)
        ply:SetNWString("Info", "Press F to buy upgraded " .. weapons.Get(weaponClass .. "_upgraded").PrintName .. " ammo for $" .. info[6])
        return
    end
end

function DoorBuy(ent, info, ply)
    local doorNum = tonumber(info[3])
    local spawnNum = tonumber(info[4])
    if !IsDoorOpened(doorNum) then
        local cost = tonumber(info[5])
        if ply:GetNWInt("Cash") >= cost then
            ent:EmitSound("isolation/buy.wav", 500, 100)
            ply:SetNWInt("Cash", ply:GetNWInt("Cash") - cost)
            ply:SetNWBool("ShowInfo", false)
            ply:SetNWString("Info", "")
            ply.shopEntity = nil
            SetZombieSpawnsEnabled(spawnNum, true)
            for _, s in pairs(ents.FindByName("door " .. doorNum)) do
                s.opened = true
                s:Fire("unlock", "", 0)
                s:Fire("open", "", 0)
                s:Fire("lock", "", 0)
            end
        end
    end
end

function WeaponBuy(ent, info, ply)
    weaponClass = info[3]
    weaponCost = tonumber(info[4])
    ammoCost = tonumber(info[5])
    upgradedAmmoCost = tonumber(info[6])
    if !ply:HasWeapon(weaponClass) and ply:GetNWInt("Cash") >= weaponCost then
        ent:EmitSound("isolation/buy.wav", 500, 100)
        ply:SetNWInt("Cash", ply:GetNWInt("Cash") - weaponCost)
        if ply:GetActiveWeapon() != nil and #ply:GetWeapons() == 3 then
            ply:StripWeapon(ply:GetActiveWeapon():GetClass())
        end
        ply:Give(weaponClass)
        ply:SelectWeapon(weaponClass)
        return
    end
    if ply:HasWeapon(weaponClass) and ply:GetNWInt("Cash") >= ammoCost then
        ent:EmitSound("isolation/buy.wav", 500, 100)
        ply:SetNWInt("Cash", ply:GetNWInt("Cash") - ammoCost)
        ply:GiveAmmo(250, ply:GetActiveWeapon():GetPrimaryAmmoType(), true)
        return
    end
    if ply:HasWeapon(weaponClass .. "_upgraded") and ply:GetNWInt("Cash") >= upgradedAmmoCost then
        ent:EmitSound("isolation/buy.wav", 500, 100)
        ply:SetNWInt("Cash", ply:GetNWInt("Cash") - upgradedAmmoCost)
        ply:GiveAmmo(250, ply:GetActiveWeapon():GetPrimaryAmmoType(), true)
        return
    end
end

hook.Add("Think", "ShopInfo", function()
    if ready then
        local outsidePlys = player.GetAll()
        local shops = FindShops()
        if #shops > 0 then
            for _, s in pairs(shops) do
                local split = string.Explode(" ", s:GetName())
                local shopType = split[2]
                local insidePlys = ents.FindInBox(s:LocalToWorld(s:OBBMins()), s:LocalToWorld(s:OBBMaxs()))
                for _, p in pairs(insidePlys) do
                    if p:IsPlayer() then
                        if table.HasValue(outsidePlys, p) then
                            table.RemoveByValue(outsidePlys, p)
                        end
                        p.shopEntity = s
                        if shopType == "door" then
                            local doorNum = tonumber(split[3])
                            if !IsDoorOpened(doorNum) then
                                DoorInfo(split, p)
                            else
                                if table.HasValue(outsidePlys, p) then
                                    table.RemoveByValue(outsidePlys, p)
                                end
                            end
                        elseif shopType == "weapon" then
                            WeaponInfo(split, p)
                        end
                    end
                end
            end
            for _, p in pairs(outsidePlys) do
                p.shopEntity = nil
                p:SetNWBool("ShowInfo", false)
                p:SetNWString("Info", "")
            end
        end
    end
end)

hook.Add("PlayerButtonDown", "ShopBuy", function(ply, btn)
    if btn == KEY_F then
        if ply:GetNWBool("ShowInfo") and ply.shopEntity != nil then
            local split = string.Explode(" ", ply.shopEntity:GetName())
            local shopType = split[2]
            if shopType == "door" then
                DoorBuy(ply.shopEntity, split, ply)
            elseif shopType == "weapon" then
                WeaponBuy(ply.shopEntity, split, ply)
            end
        end
    end
end)