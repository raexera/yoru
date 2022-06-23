-------------------------------------------
-- @author https://github.com/Kasper24
-- @copyright 2021-2022 Kasper24
-------------------------------------------

local gobject = require("gears.object")

-- Kidna copying awesotre's stores on a surface level for added compatibility
local function subscribable(args)
	local ret = gobject({})
	local subscribed = {}

	-- Subscrubes a function to the object so that it's called when `fire` is
	-- Calls subscribe_callback if it exists as well
	function ret:subscribe(func)
		local id = tostring(func):gsub("function: ", "")
		subscribed[id] = func

		if self.subscribe_callback then
			self.subscribe_callback(func)
		end
	end

	-- Unsubscribes a function and calls unsubscribe_callback if it exists
	function ret:unsubscribe(func)
		if not func then
			subscribed = {}
		else
			local id = tostring(func):gsub("function: ", "")
			subscribed[id] = nil
		end

		if self.unsubscribe_callback then
			self.unsubscribe_callback(func)
		end
	end

	function ret:fire(...)
		for _, func in pairs(subscribed) do
			func(...)
		end
	end

	return ret
end

return subscribable
