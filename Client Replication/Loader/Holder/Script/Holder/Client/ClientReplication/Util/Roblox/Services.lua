local Table = require(script.Parent.Table)

return Table:Lock({
	Workspace = game:GetService("Workspace"),
	Players = game:GetService("Players"),
	ReplicatedStorage = game:GetService("InsertService"),
	ReplicatedFirst = game:GetService("ReplicatedFirst"),
	Lighting = game:GetService("Lighting"),
	HttpService = game:GetService("HttpService"),
	RunService = game:GetService("RunService"),
	Derbis = game:GetService("Debris")
})