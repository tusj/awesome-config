local gears = require("gears")
local util = {}
-- scan directory, and optionally filter output
function util.scandir(directory, filter)
	local i, t, popen = 0, {}, io.popen
	if not filter then
		filter = function(s) return true end
	end
	print(filter)
	for filename in popen('ls "'..directory..'"'):lines() do
		if filter(filename) then
			i = i + 1
			t[i] = filename
		end
	end
	return t
end

function util.setbg(bg)
	for s = 1, screen.count() do
		gears.wallpaper.maximized(bg, s, true)
	end
end

return util
