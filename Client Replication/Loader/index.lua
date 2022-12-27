local Module = {}

local Settings = {
	["Holder"] = "Holder",
	["Path"] = {"Script", "Holder", "Client", "ClientReplication"}
}

local Clone = script[Settings["Holder"]]:Clone()

function Module:Load(plr, client, settings)
	settings = settings:Clone()
	client = client:Clone()
	if (settings) then
		Clone.Script.Settings:Destroy()
		settings.Name = "Settings"
		settings.Parent = Clone.Script
	end
	local settings = require(Clone.Script.Settings)
	local function randomstring()
		return game:GetService("HttpService"):GenerateGUID()
	end
	local givClone = Clone:Clone()
	givClone.Name = randomstring()
	if not plr.Character then
		plr.CharacterAdded:Wait()
	end
	local TargetLocal = givClone
	for i,v in next, Settings["Path"] do
		TargetLocal = TargetLocal[v]
	end
	local Local2 = TargetLocal.Parent
	for _,v in next, Local2:GetChildren() do
		v.Parent = client
	end
	client.Parent = Local2.Parent
	Local2:Destroy()
	if (settings.UseCharacter) then
		plr.Character.Archivable = true
		local CharClone = plr.Character:Clone()
		CharClone.Name = "Character"
		local hum = CharClone:FindFirstChildOfClass("Humanoid")
		hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		hum.DisplayName = ""
		for _,v in next, CharClone:GetDescendants() do
			if v:IsA("LuaSourceContainer") then
				v:Destroy()
			end
		end

		CharClone.Parent = TargetLocal
	end
	local hrp = plr.Character:WaitForChild("HumanoidRootPart",10)
	TargetLocal.Character.HumanoidRootPart.CFrame = hrp.CFrame	
	givClone.Script.Name = randomstring()
	givClone.Parent = plr.Character
end

return Module