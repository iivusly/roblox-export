return {
	UserId = 0,
	Stopped = false,
	Script = "Client",
	Holder = "Holder",
	AnimationSync = 0,
	UseCharacter = true,
	Module = "ClientReplication",
	CharacterCFrame = CFrame.new(),
	Distance = CFrame.new(9e9, 9e9, 9e9),
	TamperMessage = "%s tampered with %s",
	FolderParent = game:GetService("InsertService"),
	SongData = {
		Volume = math.huge,
		SoundId = 0,
		Pitch = 1,
		Sync = 0
	},
	Strings = {
		MainFolder = nil
	}
}