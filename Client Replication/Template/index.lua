local CRLoader = require(--[[Loader]])

return function(plr)
	CRLoader:Load(game:GetService("Players"):WaitForChild(plr), script.Client, script.Settings)
end