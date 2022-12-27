local S = setmetatable({},{__index = function(s,i) return game:service(i) end})
local CF = {N=CFrame.new,A=CFrame.Angles,fEA=CFrame.fromEulerAnglesXYZ}
local C3 = {N=Color3.new,RGB=Color3.fromRGB,HSV=Color3.fromHSV,tHSV=Color3.toHSV}
local V3 = {N=Vector3.new,FNI=Vector3.FromNormalId,A=Vector3.FromAxis}
local M = {C=math.cos,R=math.rad,S=math.sin,P=math.pi,RNG=math.random,MRS=math.randomseed,H=math.huge,RRNG = function(min,max,div) return math.rad(math.random(min,max)/(div or 1)) end}
local R3 = {N=Region3.new}
local De = S.Debris
local WS = workspace
local Lght = S.Lighting
local RepS = S.ReplicatedStorage
local IN = Instance.new
local Plrs = S.Players
local UIS = S.UserInputService
local CAS = S.ContextActionService

local Chatter = {Gui = nil}

local function NewInstance(prt, par, dat)
	local prt = Instance.new(prt)
	for i,v in next, dat do
		pcall(function()
			prt[i] = v
		end)
	end
	prt.Parent = par
	return prt
end

function Chatter:Setup(Head)
	local Gui = Instance.new("BillboardGui", Head)
	Gui.StudsOffset = Vector3.new(0, 2, 0)
	Gui.Size = UDim2.new(0, 100, 0, 100)
	Chatter.Gui = Gui
end

function Chatter:Chat(msg, effects, Color)
	local Char = game:GetService("Players").LocalPlayer.Character
	coroutine.wrap(function()
		if(effects:FindFirstChild'ChatGUI')then effects.ChatGUI:destroy() end
		local BBG = NewInstance("BillboardGui",effects,{Name='ChatGUI',Size=UDim2.new(1,0,0,1),StudsOffset=V3.N(0,2,0),Adornee=Char["Head"]})
		local offset = 0;
		local xsize = 0;
		for i = 1, #msg do
			offset = offset - 12
			xsize = xsize + 32 	
			delay(i/25, function()
				local Txt = NewInstance("TextLabel",BBG,{Text = string.sub(msg, i, i),Position=UDim2.new(0,0,0,300),BackgroundTransparency=1,BorderSizePixel=0,Font=Enum.Font.Antique,TextColor3=Color,TextSize=40,TextStrokeTransparency=1,Size=UDim2.new(1,0,.1,0)})
				offset = offset + game:GetService("TextService"):GetTextSize(Txt.Text, Txt.TextSize, Txt.Font, BBG.AbsoluteSize).X
				if(Txt.Parent)then Txt:TweenPosition(UDim2.new(0,offset,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Elastic,1) end
			end)
		end
		BBG.Size = UDim2.new(0,xsize,0,40)
		delay((#msg/25)+3, function()
			for _,v in next, BBG:children() do
				local tween = game:GetService("TweenService"):Create(v, TweenInfo.new(1), {
					TextTransparency = 1,
					Position = v.Position - UDim2.new(0, 0, -1, 0),
					Rotation = -45
				})
				tween.Completed:Connect(function()
					BBG:Destroy()
				end)
				tween:Play()
			end
		end)
	end)()
end

return Chatter
