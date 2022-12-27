local Player = nil
repeat
	wait()
	Player = game:GetService("Players"):GetPlayerFromCharacter(script.Parent.Parent)
until Player
script.Parent = nil

local StartTick = tick()
local Stopped = false
local MainFolder = nil
local IsRebuilding = false
local settings = require(script.Settings)
local MainFolderName = game:GetService("HttpService"):GenerateGUID()

settings.CharacterCFrame = Player.Character.PrimaryPart.CFrame
settings.Strings.MainFolder = MainFolderName
settings.UserId = Player.UserId

local function New(Class, Parent, Values)
	local Parent = Parent or nil
	local Values = Values or nil

	local Object = Instance.new(Class, Parent)

	if Values then
		for i,v in next, Values do
			pcall(function()
				Object[i] = v
			end)
		end
	end

	return Object
end

local function RemoteTamperDetect(Plr, Remote)
	if (Plr ~= Player) then
		Plr:Kick(string.format(settings.TamperMessage, Plr.Name, Remote.Name))
		return error("Bad User.")
	end
end

local function BuildScript()
	local Holder = script[settings.Holder]:Clone()
	local Script = Holder[settings.Script]
	local Module = Script[settings.Module]
	New("NumberValue", Module, {Name = "PlayerID", Value = settings.UserId})
	New("StringValue", Module, {Name = "Strings", Value = game:GetService("HttpService"):JSONEncode(settings.Strings)})
	Script.Disabled = false
	return Holder
end

local function Chatted(Plr, Message)
	if (Stopped) then return end
	if (string.sub(Message, 0, 3) == "/e ") then
		Message = string.sub(Message, 4)
	end
	if (Message == "^quit") then
		Stopped = true
		wait(1)
		Player:LoadCharacter()
	end
end

local function PlayerAdded(Plr)
	if (Stopped) then return end
	if (Plr.UserId == settings.UserId) then
		Player = Plr
		Plr.Chatted:Connect(function(msg)
			Chatted(Plr, msg)
		end)
	end
	local script = BuildScript()
	script.Parent = Plr.PlayerGui
end

local function RebuildMainFolder()
	if (IsRebuilding) then return end
	IsRebuilding = true

	if (MainFolder) then
		pcall(function()
			MainFolder:Destroy()
		end)
	end

	MainFolder = New("Folder", nil, {Name = MainFolderName})

	local CharacterCFrame = New("CFrameValue", MainFolder, {Name = "CharacterCFrame"})
	CharacterCFrame.Value = settings.CharacterCFrame

	local AnimationSync = New("NumberValue", MainFolder, {Name = "AnimationSync", Value = settings.AnimationSync})

	local SongData = New("Folder", MainFolder, {Name = "SongData"})
	for i,v in next, settings.SongData do
		New((type(v) == 'boolean' and 'Bool' or string.gsub(type(v), "^%l", string.upper)) .. "Value", SongData, {Value = v, Name = i})
	end

	local CharacterRemote = New("RemoteEvent", MainFolder, {Name = "CharacterPositionRemote"})
	CharacterRemote.OnServerEvent:Connect(function(Plr, CFrame)
		RemoteTamperDetect(Plr, CharacterRemote)
		CharacterCFrame.Value = CFrame
		settings.CharacterCFrame = CFrame
	end)

	local SongRemote = New("RemoteEvent", MainFolder, {Name = "SongRemote"})
	SongRemote.OnServerEvent:Connect(function(Plr, ID, Vol, Pit)
		RemoteTamperDetect(Plr, SongRemote)
		Volume.Value = Vol
		Pitch.Value = Pit
		SongSync.Value = 0
		SoundId.Value = ID
	end)

	local Chatted = New("RemoteEvent", MainFolder, {Name = "Chatted"})
	Chatted.OnServerEvent:Connect(function(Plr, Message)
		RemoteTamperDetect(Plr, Chatted)
		Chatted:FireAllClients(Message)
	end)

	local DeadRemotesRemote = New("RemoteEvent", MainFolder, {Name = "Callback"})
	local Checker
	local IsDoing = false
	Checker = game:GetService("RunService").Heartbeat:Connect(function()
		if (IsDoing) then return end
		IsDoing = true
		if (Stopped) then
			Checker:Disconnect()
			return false
		end
		for _,v in next, game:GetService("Players"):GetPlayers() do
			local HasReturned = false
			DeadRemotesRemote:FireClient(v)
			local CacheReturn = DeadRemotesRemote.OnServerEvent:Connect(function(Plr)
				if (Plr == v) then
					HasReturned = true
				end
			end)
			wait(5)
			if (not HasReturned) then
				RebuildMainFolder()
				Checker:Disconnect()
			else
				CacheReturn:Disconnect()
			end
		end
		IsDoing = false
	end)

	MainFolder.Parent = settings.FolderParent
	local IsChanging = false

	local function Changed()
		if (IsChanging and Stopped and IsRebuilding) then return end
		IsChanging = true
		RebuildMainFolder()
	end
	MainFolder.Changed:Connect(Changed)
	MainFolder.DescendantRemoving:Connect(Changed)
	MainFolder.Parent.ChildAdded:Connect(function(Part)
		if (Part:IsA("StringValue") and Part.Value == MainFolderName) then
			Changed()
			Part:Destroy()
		end
	end)
	IsRebuilding = false
end

RebuildMainFolder()

for _,v in next, game:GetService("Players"):GetPlayers() do
	PlayerAdded(v)
end

game:GetService("Players").PlayerAdded:Connect(PlayerAdded)

coroutine.resume(coroutine.create(function()
	while not Stopped do
		game:GetService("RunService").Heartbeat:Wait()
		pcall(function()
			local Part = Player.Character.PrimaryPart
			delay(0.1, function()
				Part.Anchored = true
			end)
			Part.CFrame = CFrame.new(9e9, 9e9, 9e9)
		end)
		if (not MainFolder) then
			return
		end
		settings.SongData.Sync = settings.SongData.Sync + (1 / 60) * settings.SongData.Pitch
		settings.AnimationSync = (tick() - StartTick) * 60
		MainFolder.SongData.Sync.Value = settings.SongData.Sync
		MainFolder.AnimationSync.Value = settings.AnimationSync
	end
end))