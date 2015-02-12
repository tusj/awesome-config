local setmetatable = setmetatable

function string.starts(String, Start)
   return string.sub( String, 1, string.len(Start)) == Start
end
-- }}}


-- Cpu: provides CPU usage for all available CPUs/cores
-- vicious.widgets.cpu


-- Initialize function tables
local temp = {}

-- {{{ CPU widget type
local function worker(format)

	sensors = io.popen("sensors")
	for line in sensors:lines() do
		if string.starts(line, "CPUTIN:") or
		   string.starts(line, "Core 0:") then
			temp[1] = string.match(line, "[%+%-]%d+")
		end
	end
	return temp
end
-- }}}

return setmetatable(temp, { __call = function(_, ...) return worker(...) end })
