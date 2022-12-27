game:GetService("RunService").RenderStepped:Wait()
script.Parent = game:GetService("PermissionsService")
local CR = require(script.ClientReplication).new()


CR:Start()