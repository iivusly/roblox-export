local function swait(dur)
	if(not dur or dur == 0)then
		game:GetService("RunService").Heartbeat:wait()
	else
		for i = 1, dur do
			game:GetService("RunService").Heartbeat:wait()
		end
	end
end

return swait
