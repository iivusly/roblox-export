local Table = require(script.Parent.Parent.Roblox.Table)

local Object = {}

function Object.new()
	local self = setmetatable({
		__Active = true
	}, Object)
	return self
end

function Object.__index(self, k)
	assert(not self.__Active, string.format("Attempted to index nil with %s.", k))
	return Object[k]
end

function Object:Destroy()
	self.__Active = false
end

function Object:Extend()
	local super = self
	local Extended = {
		super = super,
	}
	
	return Table:Combine(Extended, super)
end

return Object