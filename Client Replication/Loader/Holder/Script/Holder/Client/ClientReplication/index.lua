local Service = require(script.Util.Roblox.Services)
local Table = require(script.Util.Roblox.Table)
local swait = require(script.Util.Lua.Wait)
local Event = require(script.Util.Lua.Event)
local Players = Service.Players
local Strings = Service.HttpService:JSONDecode(script:WaitForChild("Strings").Value)

local CR = {}
CR.__index = CR

function CR.new()
	local self = setmetatable({
		__OldName = "",
		__Focusing = false,
		__CameraConnection = nil,
		__RenderConnection = nil,
		__RebuildingSound = false,
		__RemovingConnection = nil,
		__ChangingConnection = nil,
		__RebuildingCharacter = false,
		__CharacterParent = workspace.Terrain,
		__ProtectorSize = Vector3.new(0.4, 0.4, 0.4),
		__ProtectorName = Service.HttpService:GenerateGUID(),
		__SavedCharacter = script:FindFirstChild("Character"),
		__DebouceProtectorName = Service.HttpService:GenerateGUID(),
		__MainFolder = Service.ReplicatedStorage:FindFirstChild(Strings["MainFolder"]),
		LocalPlayer = Players.LocalPlayer,
		Player = Players:GetPlayerByUserId(script.PlayerID.Value),
		Character = nil,
		Humanoid = nil,
		Effects = nil,
		Stopped = false,
		CharacterRebuilt = Event.new(),
		SoundRebuilt = Event.new(),
		CameraCFrame = Service.Workspace.CurrentCamera.CFrame,
	}, CR)
	
	self.AnimationSync = self.__MainFolder.AnimationSync.Value
	self.__CharacterCFrame = self.__MainFolder.CharacterCFrame
	
	self.Sound = {
		Holder = nil,
		Sound = nil,
		SoundId = self.__MainFolder.SongData.SoundId,
		Pitch = self.__MainFolder.SongData.Pitch,
		Volume = self.__MainFolder.SongData.Volume,
		TimePosition = self.__MainFolder.SongData.Sync,
		Global = self.__MainFolder.SongData.Global
	}
	
	local DetectSongChanges = {
		{"Pitch", self.__MainFolder.SongData.Pitch},
		{"SoundId", self.__MainFolder.SongData.SoundId},
		{"Volume",  self.__MainFolder.SongData.Volume},
		{"TimePosition", self.__MainFolder.SongData.Sync}
	}

	for _,v in next, DetectSongChanges do
		self.Sound[v[1]] = v[2].Value
		v[2]:GetPropertyChangedSignal("Value"):Connect(function()
			self.Sound[v[1]] = v[2].Value
		end)
	end
	
	return self
end

function CR:BuildProtector(Parent)
	if Parent:FindFirstChild(self.__DebouceProtectorName) then return end
	local Debouce = Instance.new("StringValue", Parent)
	Debouce.Name = self.__DebouceProtectorName
	local Model = Instance.new("Model")
	Model.Name = self.__ProtectorName
	local Part = Instance.new("Part", Model)
	Part.Name = "HumanoidRootPart"
	Part.Transparency = 1
	Part.Size = Parent.Size + self.__ProtectorSize
	Part.Anchored = false
	Part.CanCollide = false
	Part.Massless = true
	local Weld = Instance.new("Weld", Model)
	Weld.Name = Service.HttpService:GenerateGUID()
	Weld.Part0 = Parent
	Weld.Part1 = Part
	Model.Parent = Parent
	Debouce:Destroy()
end

function CR:BuildBigProtector(Parent, CFrame)
	local Multiplier = 100
	for i = 1, 30 do
		local Part = Instance.new("Part")
		Part.Name = self.__OldName
		Part.CFrame = CFrame
		Part.Transparency = 1
		Part.Anchored = true
		Part.Size = Vector3.new(Multiplier, Multiplier, Multiplier)
		Part.CanCollide = false
		Part.Parent = Parent
		Service.Derbis:AddItem(Part, 10)
	end
end

function CR:Hide()
	if (self.LocalPlayer ~= self.Player) then
		self.Player.Parent = nil
	end
end

function CR:Song(id, vol, pitch)
	if (self.Player == self.LocalPlayer) then
		self.__MainFolder.SongRemote:FireServer(id, vol, pitch)
	end
end

function CR:__Focus(Humanoid) 
	self.__Focusing = true
	Service.Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	Service.Workspace.CurrentCamera.CameraSubject = Humanoid
	Service.Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	coroutine.resume(coroutine.create(function()
		swait(2)
		Service.Workspace.CurrentCamera.CFrame = self.CameraCFrame
		self.__Focusing = false
	end))
end

function CR:CharacterRebuild()
	if (self.Stopped) then
		return false
	end
	if (not self.__MainFolder or not self.__MainFolder.Parent) then
		self.__MainFolder = Service.ReplicatedStorage:WaitForChild(Strings["MainFolder"])
	end
	if (self.__RebuildingCharacter) then return end
	self.__RebuildingCharacter = true
	
	if self.Character and self.Character.Parent ~= nil then
		pcall(function()
			self.Character:Destroy()
		end)
	end

	local nCharacter = self.__SavedCharacter:Clone()
	nCharacter.Name = Service.HttpService:GenerateGUID()
	self.__OldName = nCharacter.Name
	local Effects = Instance.new("Folder", nCharacter)
	Effects.Name = Service.HttpService:GenerateGUID()
	
	for _,v in next, nCharacter:GetChildren() do
		if v:IsA("BasePart") then
			self:BuildProtector(v)
		end
	end
	
	if (self.LocalPlayer == self.Player) then
		self:__Focus(nCharacter.Humanoid)
	end
	
	nCharacter.Parent = self.__CharacterParent
	nCharacter:WaitForChild("HumanoidRootPart").CFrame = self.__MainFolder.CharacterCFrame.Value
	self.Player.Character = nCharacter
	self.Character = nCharacter
	self.Humanoid = nCharacter.Humanoid
	self.Effects = Effects
	
	self.CharacterRebuilt:Fire(nCharacter)
	
	self.__RebuildingCharacter = false
	
	for _,v in next, nCharacter:GetDescendants() do
		if not v:IsDescendantOf(Effects) then
			v.Changed:Connect(function()
				if self.Stopped then wait(math.huge) end
				if v.Parent == nil then
					self:CharacterRebuild()
				end
			end)
		end
	end
end

function CR:SoundRebuild()
	if (self.__RebuildingSound) then return end
	self.__RebuildingSound = true
	
	if (self.Sound.Holder) then
		pcall(function()
			self.Sound.Holder:Destroy()
		end)
	end
	if (self.Sound.Sound) then
		pcall(function()
			self.Sound.Sound:Destroy()
		end)
	end

	local SoundBlock
	if (self.Sound.Global) then
		SoundBlock = Instance.new("Model")
		SoundBlock.Name = game:GetService("HttpService"):GenerateGUID()
	else
		SoundBlock = Instance.new("Part")
		SoundBlock.Name = game:GetService("HttpService"):GenerateGUID()
		SoundBlock.Anchored = true
		SoundBlock.CanCollide = false
		SoundBlock.Transparency = 1
	end

	local Sound = Instance.new("Sound", SoundBlock)
	Sound.TimePosition = self.Sound.TimePosition
	Sound.Pitch = self.Sound.Pitch
	Sound.SoundId = "rbxassetid://" .. self.Sound.SoundId
	Sound.Volume = self.Sound.Volume
	Sound.Looped = true
	Sound:Play()

	SoundBlock.Parent = self.__CharacterParent
	self.Sound.Holder = SoundBlock
	self.Sound.Sound = Sound

	self.SoundRebuilt:Fire()

	self.__RebuildingSound = false
end

function CR:Chatted(Message)
	if (string.sub(Message, 0, 3) == "/e ") then
		Message = string.sub(Message, 4)
	end
	if (Message == "^quit") then
		self.Stopped = true
		if self.__CameraConnection then
			self.__CameraConnection:Disconnect()
		end
		self.__RemovingConnection:Disconnect()
		self.__RenderConnection:Disconnect()
		pcall(function()
			self.__ChangingConnection:Disconnect()
		end)
		spawn(function()
			wait(1)
			self.Character:Destroy()
			self.Sound.Holder:Destroy()
		end)
		script:Destroy()
	elseif (Message == "^reload") then
		self.CharacterRebuild(self)
		self:SoundRebuild()
	end
end

function CR:NewMainFolder()
	self.__MainFolder.DescendantRemoving:Connect(function()
		pcall(function()
			self.__MainFolder:Destroy()
		end)
	end)
	self.__MainFolder:WaitForChild("Chatted").OnClientEvent:Connect(function(msg)
		self:Chatted(msg)
	end)

	self.__MainFolder:WaitForChild("Callback").OnClientEvent:Connect(function()
		self.__MainFolder.Callback:FireServer(true)
	end)
	self.__MainFolder:WaitForChild("SongData").SoundId.Changed:Connect(function()
		self:SoundRebuild()
	end)
end

function CR:Start()
	self:CharacterRebuild()
	self:SoundRebuild()
	self:NewMainFolder()
	
	self.__RemovingConnection = Service.Workspace.DescendantRemoving:Connect(function(part)
		if self.Stopped then
			self.__RemovingConnection:Disconnect()
			return false
		end
		if (not self.__RebuildingCharacter and (part == self.Character or part:IsDescendantOf(self.Character) and not part:IsDescendantOf(self.Effects))) then
			if (part.Name == self.__ProtectorName) then
				CR.BuildProtector(self, part.Parent)
			else 
				CR.BuildBigProtector(self, self.__CharacterParent, self.__MainFolder.CharacterCFrame.Value)
				self.CharacterRebuild(self)
			end
		end
		if (not self.__RebuildingSound and (part == self.Sound.Holder or part == self.Sound.Sound)) then
			self:SoundRebuild()
		end
	end)
	
	spawn(function()
		local LastPosition
		while wait(1) do
			if (self.Stopped) then
				break
			end
			if (not self.__MainFolder or not self.__MainFolder.Parent) then
				self.Sound.Sound.TimePosition = LastPosition
			else
				LastPosition = self.Sound.Sound.TimePosition
			end
		end
	end)
	
	Service.ReplicatedStorage.ChildAdded:Connect(function(Object)
		if (Object.Name == Strings["MainFolder"]) then
			self.__MainFolder = Service.ReplicatedStorage:WaitForChild(Strings["MainFolder"])
			self:NewMainFolder()
		end
	end)
	
	self.__RenderConnection = Service.RunService.RenderStepped:Connect(function()
		if (self.Stopped) then
			return false
		end
		if (not self.__MainFolder or not self.__MainFolder.Parent) then
			self.__MainFolder = Service.ReplicatedStorage:WaitForChild(Strings["MainFolder"])
			return false
		end
		

		self.AnimationSync = self.__MainFolder.AnimationSync.Value
		if (self.LocalPlayer == self.Player and self.__Focusing == false) then
			self.CameraCFrame = Service.Workspace.CurrentCamera.CFrame
		end
		if (not self.__RebuildingSound and not self.__RebuildingCharacter) then
			if (self.LocalPlayer ~= self.Player) then
				self.Character:WaitForChild("HumanoidRootPart").CFrame = self.__MainFolder.CharacterCFrame.Value
			else
				self.__MainFolder.CharacterPositionRemote:FireServer(self.Character:WaitForChild("HumanoidRootPart").CFrame)
			end
			if (not self.Sound.Holder:IsA("Model")) then
				self.Sound.Holder.CFrame = self.Character:WaitForChild("HumanoidRootPart").CFrame
			end
			self.Humanoid.Name = Service.HttpService:GenerateGUID()
		end
	end)
	
	if (self.LocalPlayer == self.Player) then
		self.__CameraConnection = Service.Workspace.CurrentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
			if self.Stopped then
				self.__CameraConnection:Disconnect()
				return false
			end
			if not self.__RebuildingCharacter and Service.Workspace.CurrentCamera.CameraSubject ~= self.Humanoid then
				self:__Focus(self.Humanoid)
				self.Player.Character = self.Character
			end
		end)
		self.LocalPlayer.Chatted:Connect(function(msg)
			self.__MainFolder.Chatted:FireServer(msg)
		end)
	end
end

return CR