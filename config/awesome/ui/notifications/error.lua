local naughty = require("naughty")

--- Check if awesome encountered an error during startup and fell back to
--- another config (This code will only ever execute for the fallback config)
naughty.connect_signal("request::display_error", function(message, startup)
	naughty.notification({
		urgency = "critical",
		app_name = "Awesome",
		title = "Oops, an error happened" .. (startup and " during startup!" or "!"),
		message = message,
	})
end)
