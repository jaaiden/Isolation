function FindShopLocations()
    local shops = {}
    for _, v in pairs(ents.GetAll()) do
        local sep = string.Explode(" ", v:GetName())
        if sep[1] == "shop" then
            table.insert(shops, v)
        end
    end
    return shops
end

function WeaponShopInfo(shop, ply)
    local shopGun = shop[3]
    local shopGunPrice = tonumber(shop[4])
    local shopAmmoPrice = tonumber(shop[5])
    if !ply:HasWeapon(shopGun) then
        ply:SetNWString("Info", tostring("Press F To Buy " .. weapons.Get(shopGun)["PrintName"]) .. " For $" .. shopGunPrice)
        ply:SetNWBool("ShowInfo", true)
    else
        ply:SetNWString("Info", tostring("Press F To Buy " .. weapons.Get(shopGun)["PrintName"]) .. " Ammo For $" .. shopAmmoPrice)
        ply:SetNWBool("ShowInfo", true)
    end
end

function WeaponShop(shop, ply)
    local shopGun = shop[3]
    local shopPrice = tonumber(shop[4])
    local shopAmmo = tonumber(shop[5])
    if !ply:HasWeapon(shopGun) and ply:GetNWInt("Cash") >= shopPrice then
        ply:SetNWInt("Cash", ply:GetNWInt("Cash") - shopPrice)
        ply:Give(shopGun)
        ply:SelectWeapon(shopGun)
        ply:ChatPrint("Bought a " .. shopGun .. " for $" .. shopPrice .. ".")
    elseif !ply:HasWeapon(shopGun) and ply:GetNWInt("Cash") < shopPrice then
        ply:ChatPrint("You don't have enough money to purchase this weapon!")
    elseif ply:HasWeapon(shopGun) and ply:GetNWInt("Cash") >= shopAmmo then
        ply:SetNWInt("Cash", ply:GetNWInt("Cash") - shopAmmo)
        ply:GiveAmmo(300, ply:GetWeapon(shopGun):GetPrimaryAmmoType())
        ply:ChatPrint("Bought " .. shopGun .. " ammo for $" .. shopAmmo .. ".")
    elseif ply:HasWeapon(shopGun) and ply:GetNWInt("Cash") <= shopAmmo then
        ply:ChatPrint("You don't have enough money to purchase ammo for this weapon!")
    end
end

function DoorShopInfo(ent, shop, ply)
    local num = shop[3]
    local shopDoorPrice = tonumber(shop[4])
    if !ent:GetNWBool("Baught", false) then
        ply:SetNWString("Info", "Press F To Buy Door For $" .. tostring(shopDoorPrice))
        ply:SetNWBool("ShowInfo", true)
    end
end

function DoorShop(ent, shop, ply)
    local number = shop[3]
    local shopPrice = tonumber(shop[4])
    if !ent:GetNWBool("Baught", false) and ply:GetNWInt("Cash") >= shopPrice then
        ent:SetNWBool("Baught", true)
        for _, d in pairs(ents.FindByName(ent:GetName())) do
            d:SetNWBool("Baught", true)
        end
        ply:SetNWInt("Cash", ply:GetNWInt("Cash") - shopPrice)
        for _, d in pairs(ents.FindByName("door " .. number)) do
            d:Fire("unlock", "", 0)
            d:Fire("open", "", 0)
            d:Fire("lock", "", 0)
        end
    end
end

function ShowShopInfo()
    local shops = FindShopLocations()
    local allPlys = player.GetAll()
    for _, s in pairs(shops) do
        plys = ents.FindInBox(s:LocalToWorld(s:OBBMins()), s:LocalToWorld(s:OBBMaxs()))
        for _, ply in pairs(plys) do
            if ply:IsPlayer() then
                if table.HasValue(allPlys, ply) then
                    table.RemoveByValue(allPlys, ply)
                end
                local shopName = string.Explode(" ", s:GetName())
                local shopType = shopName[2]
                if shopType == "weapon" then
                    WeaponShopInfo(shopName, ply)
                end
                if shopType == "door" then
                    DoorShopInfo(s, shopName, ply)
                end
            end
        end
    end
    for _, ply in pairs(allPlys) do
        ply:SetNWString("Info", "")
        ply:SetNWBool("ShowInfo", false)
    end
end

hook.Add("PlayerButtonDown", "GunShop", function (ply, key)
    if key == KEY_F then
        local shops = FindShopLocations()
        for _, s in pairs(shops) do
            plys = ents.FindInBox(s:LocalToWorld(s:OBBMins()), s:LocalToWorld(s:OBBMaxs()))
            if table.HasValue(plys, ply) then
                local shopName = string.Explode(" ", s:GetName())
                local shopType = shopName[2]
                if shopType == "weapon" then
                    WeaponShop(shopName, ply)
                end
                if shopType == "door" then
                    DoorShop(s, shopName, ply)
                end
            end
        end
    end
end)

hook.Add("Tick", "Shop", function ()
    ShowShopInfo()
end)

timer.Create("Duration", 1, 0, function ()
    for _, p in pairs(player.GetAll()) do
        if p.duration > 0 then
            p.duration = p.duration - 1
        end
    end
end)