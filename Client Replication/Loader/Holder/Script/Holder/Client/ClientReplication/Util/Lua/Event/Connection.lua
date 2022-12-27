local Connection = {}
Connection.__index = Connection

function Connection.new(func)
	local self = setmetatable({
		__Function = func,
		__Active = true
	}, Connection)
	return self
end

function Connection:Fire(...)
	if (self.__Active) then
		self.__Function(...)
	end
end

function Connection:Disconnect()
	self.__Active = false
end

return Connection
