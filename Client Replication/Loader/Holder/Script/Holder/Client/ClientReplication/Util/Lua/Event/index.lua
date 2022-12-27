local Table = require(script.Parent.Parent.Roblox.Table)
local Connection = require(script.Connection)
local Object = require(script.Parent.Object)

local Event = {}
Event.__index = Event

function Event.new()
	local self = setmetatable({
		__Connections = {}
	}, Event)
	return self
end

function Event:Connect(...)
	local Connections = {}
	for i,v in next, {...} do
		local nConnection = Connection.new(v)
		Connections[i] = nConnection
		table.insert(self.__Connections, nConnection)
	end
	return unpack(Connections)
end

function Event:Fire(...)
	for i,v in next, self.__Connections do
		v:Fire(...)
	end
end

return Table:Lock(Event)
