/* Pre-Game Lobby System
========================*/

function ShowWindow()
	local plylist = player.GetHumans()

	lobby = vgui.Create("DFrame")
	lobby:SetSize(500, 350)
	lobby:Center()
	lobby:SetText("Pre-Game Lobby")
	lobby:SetVisible(true)
	lobby:SetDraggable(false)
	lobby:ShowCloseButton(true)
end

concommand.Add("isolation_pregame", function(ply, cmd, args) ShowWindow() end)