local Table = {}


function Table:Lock(tbl)
	local Metatable = newproxy(true)
	local Metadata = getmetatable(Metatable)
	
	function Metadata.__newindex()
		return error("Table is locked!")
	end
	
	function Metadata.__index(o, k)
		return tbl[k]
	end
	
	return Metatable
end

function Table:Clone(tbl)
	local ntbl = {}
	for i,v in next, tbl do
		if type(v) == "table" then
			ntbl[i] = Table:Clone(tbl)
		else
			ntbl[i] = v
		end
	end
	return setmetatable(ntbl, getmetatable(tbl))
end

function Table:Combine(tbl1, tbl2)
	for i,v in next, tbl1 do
		tbl2[i] = v
	end
	return setmetatable(tbl2, getmetatable(tbl1))
end

return Table:Lock(Table)
