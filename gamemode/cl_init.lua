include("client/concommands.lua")

local cash = 0
hudDisabled = false
avatar = vgui.Create("AvatarImage", Panel)
avatar:SetSize(80, 80)

-- Create fonts for clientside
surface.CreateFont("HUDFont1", {
	font = "Roboto-Regular",
	size = 24,
	weight = 500,
	antialias = true
})
surface.CreateFont("HUDFont2", {
	font = "Roboto-Regular",
	size = 18,
	weight = 500,
	antialias = true
})

/* Auto-Include Files
=====================*/

local function LoadClientFiles()
	local root = GM.FolderName.."/gamemode/client/"
	local _, folders = file.Find(root.."*", "LUA")
	for _, folder in SortedPairs(folders, true) do
		for _, File in SortedPairs(file.Find(root .. folder .."/*", "LUA"), true) do
			include(root.. folder .. "/" ..File)
		end
	end
end
LoadClientFiles()

-- Show hands
function GM:PostDrawViewModel( vm, ply, weapon )
  if ( weapon.UseHands || !weapon:IsScripted() ) then
    local hands = LocalPlayer():GetHands()
    if ( IsValid( hands ) ) then hands:DrawModel() end
  end
end

function GM:DrawDeathNotice(x, y)
	return
end

-- Disable default gmod HUD
hook.Add("HUDShouldDraw", "DisableDefault", function(item)
	local huditems = {"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo", "CHudCrosshair"}

	for _,v in pairs(huditems) do
		if item == v then return false end
	end
end)

hook.Add("HUDPaint", "IsolationHUD", function()
	if !hudDisabled then
		local ply = LocalPlayer()

		draw.RoundedBoxEx(0, 10, ScrH() - 110, 300, 90, Color(0, 0, 0, 127), false, false, false, false)
		draw.RoundedBoxEx(0, ScrW() - 310, ScrH() - 110, 300, 90, Color(0, 0, 0, 127), false, false, false, false)
		draw.RoundedBoxEx(0, 10, ScrH() - 20, ScrW() - 20, 20, Color(0, 0, 0, 127), false, false, false, false)
		surface.SetDrawColor(200, 0, 0, 255)
		surface.DrawOutlinedRect(10, ScrH() - 20, ScrW() - 20, 21)
		draw.RoundedBoxEx(0, 14, ScrH() - 16, (ScrW() - 28) * (ply:GetNWInt("Exp") / ply:GetNWInt("MaxExp")), 14, Color(180, 180, 0, 255), false, false, false, false)

		avatar:SetPos(20, ScrH() - 100)
		avatar:SetPlayer(ply, 64)

		draw.SimpleText("Round: " .. ply:GetNWInt("Round"), "HUDFont1", 120, ScrH() - 100, Color(200, 0, 0, 255))

		draw.SimpleText("Zombies: " .. ply:GetNWInt("Zombies"), "HUDFont1", 120, ScrH() - 72.5, Color(200, 0, 0, 255))

		change = ply:GetNWInt("Cash") - cash
		if change != 0 then
			if change < 0 then
				cash = cash - 1
				draw.SimpleText(change, "HUDFont2", 260, ScrH() - 55, Color(200, 0, 0, 255))
			elseif change > 0 then
				cash = cash + 1
				draw.SimpleText("+" .. change, "HUDFont2", 260, ScrH() - 55, Color(200, 200, 0, 255))
			end
		end
		draw.SimpleText("Money: $" .. cash, "HUDFont1", 120, ScrH() - 45, Color(200, 200, 0, 255))
		draw.SimpleText(ply:GetNWInt("Exp") .. " / " .. ply:GetNWInt("MaxExp"), "HUDFont2", ScrW() / 2, ScrH() - 10, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Level: " .. ply:GetNWInt("Level"), "HUDFont1", ScrW() / 2, ScrH() - 30, Color(200, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		if ply:Health() > 0 then
			if ply:GetActiveWeapon() != nil then
				draw.SimpleText("Ammo: " .. ply:GetActiveWeapon():Clip1() .. " / " .. ply:GetAmmoCount(ply:GetActiveWeapon():GetPrimaryAmmoType()), "HUDFont1", ScrW() - 300, ScrH() - 100, Color(255, 255, 255, 255))
			end
		elseif ply:GetObserverTarget() != nil then
			draw.SimpleText("Spectating " .. ply:GetObserverTarget():Nick(), "HUDFont1", ScrW() - 300, ScrH() - 80, Color(255, 255, 255, 255))
		end
		if ply:GetNWInt("Preperation") then
			draw.SimpleText("Round " .. (ply:GetNWInt("Round") + 1) .. " Starts In " .. ply:GetNWInt("TimeLeft") .. " Second(s)", "HUDFont1", ScrW() / 2, 20, Color(200, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		if ply:GetNWBool("ShowInfo") then
			draw.SimpleText(ply:GetNWString("Info"), "HUDFont1", ScrW()/2, ScrH()-130, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end)

timer.Create( "removeRagdolls", 20, 0, function() game.RemoveRagdolls() end )

/* Pre-Game Lobby System
========================*/

function ShowWindow()

	-- Define player list array
	plylist = player.GetAll()
	plycount = #plylist
	minplayers = cMinPlayers or 2

	plyready = {}
	plynotready = {}
	plyingame = {}

	-- Create Window Frame
	local window = vgui.Create("DFrame")
	window:SetSize(650, 750)
	window:Center()
	window:SetTitle("Isolation System Menu")
	window:SetVisible(true)
	window:SetDraggable(false)
	window:ShowCloseButton(true)
	window:MakePopup()

	local sheet = vgui.Create("DPropertySheet", window)
	sheet:SetPos(5, 30)
	sheet:SetSize(640, 715)

	if window:IsActive() then
		//sound.Play("LobbyMusic", Vector(0, 0, 0))
	end

	-- Current Status Label
	local gameready = true
	if started then
		curstatus = "Game in Progress"
		gameready = false
	elseif !started and plycount < minplayers then
		if minplayers-plycount == 1 then
			curstatus = "Waiting for 1 Player"
		else
			curstatus = "Waiting for " .. (minplayers - plycount) .. " Players"
		end
	else
		curstatus = "Ready to Play"
	end

	local lobbypanel = vgui.Create("DPanel")

	-- Game Status Label
	local gamestatus = vgui.Create("DLabel", lobbypanel)
	gamestatus:SetPos(10, 5)
	gamestatus:SetColor(Color(0, 0, 0, 255))
	gamestatus:SetFont("HUDFont1")
	gamestatus:SetText("Current Game Status: " .. curstatus)
	gamestatus:SizeToContents()

	for k,v in pairs(plylist) do

		local plyreadystatus = "Not Ready"
		local plyisready = false

		local avatarbtn = vgui.Create("DButton", lobbypanel)
		avatarbtn:SetPos(35, 55*k)
		avatarbtn:SetSize(64, 64)
		avatarbtn.DoClick = function() v:ShowProfile() end

		local avimg = vgui.Create("AvatarImage", avatarbtn)
		avimg:SetSize(64, 64)
		avimg:SetPlayer(v, 64)
		avimg:SetMouseInputEnabled(false)

		local plytext = vgui.Create("DLabel", lobbypanel)
		plytext:SetPos(110, 55*k)
		plytext:SetColor(Color(0, 0, 0, 255))
		plytext:SetFont("HUDFont1")
		plytext:SetText(v:Nick())
		plytext:SizeToContents()

		local plystatus = vgui.Create("DLabel", lobbypanel)
		plystatus:SetPos(110, (55*k)+25)
		plystatus:SetColor(Color(0, 0, 0, 255))
		plystatus:SetFont("HUDFont2")
		plystatus:SetText("Player Level " .. v:GetNWInt("Level"))
		plystatus:SizeToContents()

		local plymode = vgui.Create("DLabel", lobbypanel)
		plymode:SetPos(110, (55*k)+45)
		plymode:SetColor(Color(0, 0, 0, 255))
		plymode:SetFont("HUDFont2")
		plymode:SetText(plyreadystatus)
		plymode:SizeToContents()

		if LocalPlayer() == v then
			local readybtn = vgui.Create("DButton", lobbypanel)
			readybtn:SetText("Ready Up")
			readybtn:SetPos(540, (55*k)+15)
			readybtn:SetSize(70, 30)

			if !gameready then
				readybtn:SetDisabled(true)
			else
				readybtn:SetDisabled(false)
			end

			readybtn.DoClick = function()
				if readybtn:GetDisabled() then return false else
					if plyisready then
						plymode:SetText("Not Ready")
						plymode:SetColor(Color(0, 0, 0, 255))
						readybtn:SetText("Ready Up")
						plyisready = false
						v:StopSound("isolation/lobby_music.wav")
					else
						plymode:SetText("Ready!")
						plymode:SetColor(Color(0, 175, 0, 255))
						readybtn:SetText("Un-Ready")
						plyisready = true
						v:EmitSound("isolation/lobby_music.wav", 100, 100)
					end
				end
			end
		end
	end

	sheet:AddSheet("Current Game", lobbypanel, nil, false, false, "Current game lobby.")

end
usermessage.Hook("isolation_pregame", ShowWindow)

function OptionsMenu()
	opt = vgui.Create("DFrame")
	opt:SetSize(250, 350)
	opt:Center()
	opt:SetTitle("Isolation Clientside Options Menu")
	opt:SetVisible(true)
	opt:SetDraggable(false)
	opt:ShowCloseButton(true)
	opt:MakePopup()

	local opttitle = vgui.Create("DLabel", opt)
	opttitle:SetPos(50, 35)
	opttitle:SetColor(Color(255, 255, 255, 255))
	opttitle:SetFont("HUDFont1")
	opttitle:SetText("Set your preferred settings below.")
	opttitle:SizeToContents()

	local weaponaim = vgui.Create("DCheckBoxLabel", opt)
	weaponaim:SetPos(50, 60)
	weaponaim:SetText("Hold Aim Down Sights?")
	weaponaim:SetConVar("is_holdweaponaim")
	weaponaim:SetValue(1)
	weaponaim:SizeToContents()

	local nadetext = vgui.Create("DLabel", opt)
	nadetext:SetPos(50, 75)
	nadetext:SetColor(Color(255, 255, 255, 255))
	nadetext:SetFont("HUDFont2")
	nadetext:SetText("Throw Grenade")
	nadetext:SizeToContents()

	local nadebtn = vgui.Create("DButton", opt)
	nadebtn:SetText("G")
	nadebtn:SetPos(120, 75)
	nadebtn:SetSize(150, 20)
	nadebtn.DoClick = function()
		self:SetText("<Press a Key>")
		timer.Simple(5, function()
			self:SetText("G")
		end)
	end
end
usermessage.Hook("isolation_options", OptionsMenu)




























/* Scoreboard Setup
===================*/

local PLAYER_LINE = 
{
	Init = function( self )

		self.AvatarButton = self:Add( "DButton" )
		self.AvatarButton:Dock( LEFT )
		self.AvatarButton:SetSize( 32, 32 )
		self.AvatarButton.DoClick = function() self.Player:ShowProfile() end

		self.Avatar		= vgui.Create( "AvatarImage", self.AvatarButton )
		self.Avatar:SetSize( 32, 32 )
		self.Avatar:SetMouseInputEnabled( false )		

		self.Name		= self:Add( "DLabel" )
		self.Name:Dock( FILL )
		self.Name:SetFont( "HUDFont1" )
		self.Name:DockMargin( 8, 0, 0, 0 )

		self.Mute		= self:Add( "DImageButton" )
		self.Mute:SetSize( 32, 32 )
		self.Mute:Dock( RIGHT )

		self.Ping		= self:Add( "DLabel" )
		self.Ping:Dock( RIGHT )
		self.Ping:SetWidth( 50 )
		self.Ping:SetFont( "HUDFont1" )
		self.Ping:SetContentAlignment( 5 )

		self.Deaths		= self:Add( "DLabel" )
		self.Deaths:Dock( RIGHT )
		self.Deaths:SetWidth( 50 )
		self.Deaths:SetFont( "HUDFont1" )
		self.Deaths:SetContentAlignment( 5 )

		self.Money		= self:Add( "DLabel" )
		self.Money:Dock( RIGHT )
		self.Money:SetWidth( 125 )
		self.Money:SetFont( "HUDFont1" )
		self.Money:SetContentAlignment( 5 )

		self.Level		= self:Add( "DLabel" )
		self.Level:Dock( RIGHT )
		self.Level:SetWidth( 50 )
		self.Level:SetFont( "HUDFont1" )
		self.Level:SetContentAlignment( 5 )

		self.Kills		= self:Add( "DLabel" )
		self.Kills:Dock( RIGHT )
		self.Kills:SetWidth( 50 )
		self.Kills:SetFont( "HUDFont1" )
		self.Kills:SetContentAlignment( 5 )



		self:Dock( TOP )
		self:DockPadding( 3, 3, 3, 3 )
		self:SetHeight( 32 + 3*2 )
		self:DockMargin( 2, 0, 2, 2 )

	end,

	Setup = function( self, pl )

		self.Player = pl

		self.Avatar:SetPlayer( pl )
		self.Name:SetText( pl:Nick() )

		self:Think( self )

		--local friend = self.Player:GetFriendStatus()
		--MsgN( pl, " Friend: ", friend )

	end,

	Think = function( self )

		if ( !IsValid( self.Player ) ) then
			self:Remove()
			return
		end

		if ( self.NumKills == nil || self.NumKills != self.Player:GetNWInt("Kills") ) then
			self.NumKills	=	self.Player:GetNWInt("Kills")
			self.Kills:SetText( self.NumKills )
		end

		if ( self.CurLevel == nil || self.CurLevel != self.Player:GetNWInt("Level") ) then
			self.CurLevel	=	self.Player:GetNWInt("Level")
			self.Level:SetText( self.CurLevel )
		end

		if ( self.CurMoney == nil || self.CurMoney != self.Player:GetNWInt("Cash") ) then
			self.CurLevel	=	self.Player:GetNWInt("Cash")
			self.Money:SetText("$" .. self.CurLevel )
		end

		if ( self.NumDeaths == nil || self.NumDeaths != self.Player:GetNWInt("Downs") ) then
			self.NumDeaths	=	self.Player:GetNWInt("Downs")
			self.Deaths:SetText( self.NumDeaths )
		end

		if ( self.NumPing == nil || self.NumPing != self.Player:Ping() ) then
			self.NumPing	=	self.Player:Ping()
			self.Ping:SetText( self.NumPing )
		end

		--
		-- Change the icon of the mute button based on state
		--
		if ( self.Muted == nil || self.Muted != self.Player:IsMuted() ) then

			self.Muted = self.Player:IsMuted()
			if ( self.Muted ) then
				self.Mute:SetImage( "icon32/muted.png" )
			else
				self.Mute:SetImage( "icon32/unmuted.png" )
			end

			self.Mute.DoClick = function() self.Player:SetMuted( !self.Muted ) end

		end

		--
		-- This is what sorts the list. The panels are docked in the z order, 
		-- so if we set the z order according to kills they'll be ordered that way!
		-- Careful though, it's a signed short internally, so needs to range between -32,768k and +32,767
		--
		self:SetZPos( (self.NumKills * -50) + self.NumDeaths )

	end,

	Paint = function( self, w, h )

		if ( !IsValid( self.Player ) ) then
			return
		end

		surface.SetDrawColor(0, 0, 0, 127)
		surface.DrawOutlinedRect( 0, 0, w, h)

		surface.SetDrawColor(200, 0, 0, 255)
		surface.DrawOutlinedRect( 0, 0, w, h)

	end,
}

PLAYER_LINE = vgui.RegisterTable( PLAYER_LINE, "DPanel" )

local is_scoreboard = 
{
	Init = function(self)
		self.Header = self:Add("Panel")
		self.Header:Dock(TOP)
		self.Header:SetHeight(100)

		self.Name = self.Header:Add("DLabel")
		self.Name:SetFont("HUDFont1")
		self.Name:SetTextColor(Color(255, 255, 255, 255))
		self.Name:Dock(TOP)
		self.Name:SetHeight(40)
		self.Name:SetContentAlignment(5)
		self.Name:SetExpensiveShadow(2, Color(0, 0, 0, 200))

		self.Scores = self:Add("DScrollPanel")
		self.Scores:Dock(FILL)
	end,

	PerformLayout = function(self)
		self:SetSize(700, ScrH()-200)
		self:SetPos( ScrW() / 2 - 350, 100 )

	end,

	Paint = function( self, w, h )

		--draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 200 ) )
		draw.SimpleText("Kills", "HUDFont2", w-60, -40, Color(200, 0, 0, 255))

	end,

	Think = function( self, w, h )

		self.Name:SetText( GetHostName() .. "\nPlaying on " .. game.GetMap())

		--
		-- Loop through each player, and if one doesn't have a score entry - create it.
		--
		local plyrs = player.GetAll()
		for id, pl in pairs( plyrs ) do

			if ( IsValid( pl.ScoreEntry ) ) then continue end

			pl.ScoreEntry = vgui.CreateFromTable( PLAYER_LINE, pl.ScoreEntry )
			pl.ScoreEntry:Setup( pl )

			self.Scores:AddItem( pl.ScoreEntry )

		end		

	end,
}

is_scoreboard = vgui.RegisterTable(is_scoreboard, "EditablePanel")

function GM:ScoreboardShow()
	/*local scoreboard = vgui.Create("DPanel")
	scoreboard:SetSize(ScrW()/2, ScrH()/2)
	scoreboard:Center()
	scoreboard.Paint = function()
		surface.SetDrawColor(200, 0, 0, 255)
		surface.DrawOutlinedRect(0, 0, scoreboard:GetWide(), scoreboard:GetTall())
	end

	local plylist = vgui.Create("DListView")
	plylist:SetParent(scoreboard)
	plylist:SetPos(2, 2)
	plylist:SetSize(scoreboard:GetWide()-2, scoreboard:GetTall()-2)
	plylist:SetMultiSelect(false)
	plylist:AddColumn("Name")
	plylist:AddColumn("Level")
	plylist:AddColumn("Money")
	plylist:AddColumn("Kills")
	plylist:AddColumn("Downs")
	plylist:AddColumn("Ping")

	for _,v in pairs(player.GetAll()) do
		plylist:AddLine(v:Nick(), v:GetNWInt("Level"), v:GetNWInt("Money"), v:GetNWInt("Kills"), v:GetNWInt("Downs"), v:Ping())
	end*/

	if !IsValid(g_Scoreboard) then
		g_Scoreboard = vgui.CreateFromTable(is_scoreboard)
	end
	
	if IsValid(g_Scoreboard) then
		g_Scoreboard:Show()
		g_Scoreboard:MakePopup()
		g_Scoreboard:SetKeyBoardInputEnabled(false)
	end
end

function GM:ScoreboardHide()
	if IsValid(g_Scoreboard) then
		g_Scoreboard:Hide()
	end
end

function GM:HUDDrawScoreBoard()
end