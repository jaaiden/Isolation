GM.Name = "Isolation"
GM.Author = "RedXVIII and Wayward"
GM.Email = "redx_viii@hotmail.com"
GM.Website = "http://isolation.cf"

sound.Add({
	name = "LobbyMusic",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 80,
	pitch = {95, 110},
	sound = "isolation/lobby_music.wav"
})

sound.Add({
	name = "RoundStart",
	channel = CHAN_STATIC,
	volume = 0.75,
	level = 80,
	pitch = {95, 110},
	sound = "isolation/round_start.wav"
})

sound.Add({
	name = "RoundEnd",
	channel = CHAN_STATIC,
	volume = 0.75,
	level = 80,
	pitch = {95, 110},
	sound = "isolation/round_end.wav"
})

util.PrecacheModel("models/jessev92/player/ww2/nz-hero/dempsey.mdl")
util.PrecacheModel("models/jessev92/player/ww2/nz-hero/nikolai.mdl")
util.PrecacheModel("models/jessev92/player/ww2/nz-hero/richtofen.mdl")
util.PrecacheModel("models/jessev92/player/ww2/nz-hero/takeo.mdl")