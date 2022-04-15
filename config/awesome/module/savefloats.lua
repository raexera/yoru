local awful = require("awful")

local function rel(screen, win)
	return {
		x = (win.x - screen.x) / screen.width,
		y = (win.y - screen.y) / screen.height,
		width = win.width / screen.width,
		aspect = win.height / win.width,
	}
end

local function unrel(s, rel)
	return rel
		and {
			x = s.x + s.width * rel.x,
			y = s.y + s.height * rel.y,
			width = s.width * rel.width,
			height = rel.aspect * s.width * rel.width,
		}
end

local stored = {}

local function forget(c)
	stored[c] = nil
end

local floating = awful.layout.suit.floating

function remember(c)
	if floating == awful.layout.get(c.screen) or c.floating then
		stored[c.window] = rel(c.screen.geometry, c:geometry())
	end
end

function restore(c)
	local s = stored[c.window]
	if s then
		c:geometry(unrel(c.screen.geometry, stored[c.window]))
		return true
	else
		return false
	end
end

client.connect_signal("manage", remember)
client.connect_signal("property::geometry", remember)
client.connect_signal("unmanage", forget)

tag.connect_signal("property::layout", function(t)
	if floating == awful.layout.get(t.screen) then
		for _, c in ipairs(t:clients()) do
			c:geometry(unrel(t.screen.geometry, stored[c.window]))
		end
	end
end)

return restore
