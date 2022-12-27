--[[
	Module API:
		__RebuildingCharacter = false: Is the character rebuilding?
		__MainFolder = Service.ReplicatedStorage:FindFirstChild(Strings["MainFolder"]): The MainFolder
		LocalPlayer = Players.LocalPlayer: LocalPlayer
		Player = Players:GetPlayerByUserId(script.PlayerID.Value): Target
		Character = nil: Character
		Humanoid = nil: Humanoid
		Effects = nil: Effects folder
		Stopped = false: Is Stopped
		CharacterRebuilt = Event.new(): Character rebuild event
		SoundRebuilt = Event.new(): Sound rebuild event
		Sound:
			Holder = nil:Sound holder
			Sound = nil: Sound Instance
			SoundId = self.__MainFolder.SongData.SoundId: self explanatory
			Pitch = self.__MainFolder.SongData.Pitch: self explanatory
			Volume = self.__MainFolder.SongData.Volume: self explanatory
			TimePosition = self.__MainFolder.SongData.Sync: self explanatory

--]]

local S = setmetatable({},{__index = function(s,i) return game:service(i) end})
local CF = {N=CFrame.new,A=CFrame.Angles,fEA=CFrame.fromEulerAnglesXYZ}
local C3 = {tRGB= function(c3) return c3.r*255,c3.g*255,c3.b*255 end,N=Color3.new,RGB=Color3.fromRGB,HSV=Color3.fromHSV,tHSV=Color3.toHSV}
local V3 = {N=Vector3.new,FNI=Vector3.FromNormalId,A=Vector3.FromAxis}
local M = {C=math.cos,R=math.rad,S=math.sin,P=math.pi,RNG=math.random,MRS=math.randomseed,H=math.huge,RRNG = function(min,max,div) return math.rad(math.random(min,max)/(div or 1)) end}
local R3 = {N=Region3.new}
local De = S.Debris
local WS = workspace
local Lght = S.Lighting
local RepS = S.ReplicatedStorage
local IN = Instance.new
local Plrs = S.Players
local TWS = S.TweenService

game:GetService("RunService").RenderStepped:Wait()
local CR = require(script.ClientReplication).new()
local Chatter = require(script.Chatter)
local Effects = require(script.Effects)
local Rainbow = Color3.new()
local Hue = 0
local Sine = 0
local Alpha = 0.1
local Hum, Root, Torso, Head, LArm, RArm, LLeg, RLeg
local RJ, NK, RS, LS, RH, LH
local RJC0, NKC0, RSC0, LSC0, RHC0, LHC0 = CF.N(), CF.N(0,1.5,0), CF.N(1.5,.5,0), CF.N(-1.5,.5,0), CF.N(.5,-1,0), CF.N(-.5,-1,0)

local function BuildMotor(P1, P2, C0, C1)
	local Motor = Instance.new("Motor6D")
	Motor.Parent = P1
	Motor.Part0 = P1
	Motor.Part1 = P2
	Motor.C0 = C0 or CF.N()
	Motor.C1 = C1 or CF.N()
	return Motor
end

CR.CharacterRebuilt:Connect(function()
	Hum = CR.Character:FindFirstChildOfClass("Humanoid")
	Root = CR.Character["HumanoidRootPart"]
	Torso = CR.Character["Torso"]
	Head = CR.Character["Head"]
	LArm = CR.Character["Left Arm"]
	RArm = CR.Character["Right Arm"]
	LLeg = CR.Character["Left Leg"]
	RLeg = CR.Character["Right Leg"]
	RJ = BuildMotor(Root, Torso)
	NK = BuildMotor(Torso, Head, NKC0, CF.N())
	RS = BuildMotor(Torso, RArm, RSC0, CF.N(0,.5,0))
	LS = BuildMotor(Torso, LArm, LSC0, CF.N(0,.5,0))
	RH = BuildMotor(Torso, RLeg, RHC0, CF.N(0,1,0))
	LH = BuildMotor(Torso, LLeg, LHC0, CF.N(0,1,0))
end)

local UI

if (CR.LocalPlayer == CR.Player) then
	UI = Instance.new("ScreenGui", CR.Player.PlayerGui)
	UI.ResetOnSpawn = false
end

CR:Start()

math.randomseed(tick())

while not CR.Stopped do
	wait()
	Sine = CR.AnimationSync
	if (not CR.__RebuildingCharacter) then
		local hitfloor,posfloor = workspace:FindPartOnRayWithIgnoreList(Ray.new(Root.CFrame.p,((CFrame.new(Root.Position,Root.Position - Vector3.new(0,1,0))).lookVector).unit * (4)), {CR.Effects,CR.Character})
		local Walking = (math.abs(Root.Velocity.x) > 1 or math.abs(Root.Velocity.z) > 1)
		local State = (Hum.PlatformStand and 'Paralyzed' or Hum.Sit and 'Sit' or not hitfloor and Root.Velocity.y < -1 and "Fall" or not hitfloor and Root.Velocity.y > 1 and "Jump" or hitfloor and Walking and "Walk" or hitfloor and "Idle" or hitfloor and Walking and Hum.WalkSpeed>24 and "Run")
		local sidevec = math.clamp((Root.Velocity*Root.CFrame.rightVector).X+(Root.Velocity*Root.CFrame.rightVector).Z,-Hum.WalkSpeed,Hum.WalkSpeed)
		local forwardvec =  math.clamp((Root.Velocity*Root.CFrame.lookVector).X+(Root.Velocity*Root.CFrame.lookVector).Z,-Hum.WalkSpeed,Hum.WalkSpeed)
		local sidevelocity = sidevec/Hum.WalkSpeed
		local forwardvelocity = forwardvec/Hum.WalkSpeed
		local lhit,lpos = workspace:FindPartOnRayWithIgnoreList(Ray.new(LLeg.CFrame.p,((CFrame.new(LLeg.Position,LLeg.Position - Vector3.new(0,1,0))).lookVector).unit * (2)), {CR.Effects,CR.Character})
		local rhit,rpos = workspace:FindPartOnRayWithIgnoreList(Ray.new(RLeg.CFrame.p,((CFrame.new(RLeg.Position,RLeg.Position - Vector3.new(0,1,0))).lookVector).unit * (2)), {CR.Effects,CR.Character})
		if (M.RNG(0, 50) == 10) then
			NK.C0 = NK.C0:Lerp(NKC0 * CF.A(M.R(M.RNG(-45, 45)), M.R(M.RNG(-45, 45)), M.R(M.RNG(-45, 45))), Alpha)
		else
			NK.C0 = NK.C0:Lerp(NKC0, Alpha)
		end
		if (State == "Idle") then
			RJ.C0 = RJ.C0:Lerp(RJC0 * CF.A(M.R(-45), 0, 0) * CF.N(0, -0.5 + 0.1 * M.S(Sine / 50), 0), Alpha)
			RS.C0 = RS.C0:Lerp(RSC0 * CF.N(0, .05 * M.S(Sine / 30), 0) *CF.A(M.R(45) + M.R(M.RNG(-20, 20)), 0, M.R(M.RNG(-20, 20))), Alpha)
			LS.C0 = LS.C0:Lerp(LSC0 * CF.N(0, .05 * M.S(Sine / 30), 0) *CF.A(M.R(45) + M.R(M.RNG(-20, 20)), 0, M.R(M.RNG(-20, 20))), Alpha)
			RH.C0 = RH.C0:Lerp(RHC0 * CF.N(0, -0.1 * M.S(Sine / 50), 0) * CF.A(M.R(45), M.R(-20), 0), Alpha)
			LH.C0 = LH.C0:Lerp(LHC0 * CF.N(0, -0.1 * M.S(Sine / 50), 0) * CF.A(M.R(45), M.R(20), 0), Alpha)
		elseif (State == "Walk") then
			RJ.C0 = RJ.C0:Lerp(RJC0 * CF.N(0, 2 + M.S(Sine / 50), 0) * CF.A(M.R(-45), 0, 0), Alpha)
			RS.C0 = RS.C0:Lerp(RSC0 * CF.N(0, .05 * M.S(Sine / 50), 0) *CF.A(M.R(30), 0, 0), Alpha)
			LS.C0 = LS.C0:Lerp(LSC0 * CF.N(0, .05 * M.S(Sine / 50), 0) *CF.A(M.R(30), 0, 0), Alpha)
			RH.C0 = RH.C0:Lerp(RHC0 * CF.N() * CF.A(M.R(30), M.R(-20), 0), Alpha)
			LH.C0 = LH.C0:Lerp(LHC0 * CF.N() * CF.A(M.R(30), M.R(20), 0), Alpha)
		end
	end
end