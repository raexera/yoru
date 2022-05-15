-- Provides:
-- signal::todo
--      total (integer)
--      done (integer)
--      undone (integer)
local awful = require("awful")

local todo_file_path = os.getenv("TODO_PATH") or os.getenv("HOME") .. "/.todo"

-- Subscribe to todo changes
-- Requires inotify-tools
local todo_subscribe_script = [[
   bash -c "
   while (inotifywait -e modify "]] .. todo_file_path .. [[" -qq) do echo; done
"]]

local todo_script = [[
   bash -c "
   todo_done=$(todo raw done | wc -l)
   todo_undone=$(todo raw todo | wc -l) 

   echo "$todo_done"@@"$todo_undone"
"]]

local emit_todo_info = function()
	awful.spawn.with_line_callback(todo_script, {
		stdout = function(line)
			local done = tonumber(line:match("(.*)@@"))
			local undone = tonumber(line:match("@@(.*)"))
			local total = undone + done
			awesome.emit_signal("signal::todo", total, done, undone)
		end,
	})
end

-- Run once to initialize widgets
emit_todo_info()

-- Kill old inotifywait process
awful.spawn.easy_async_with_shell(
	'ps x | grep "inotifywait -e modify ' .. todo_file_path .. "\" | grep -v grep | awk '{print $1}' | xargs kill",
	function()
		-- Update todo status with each line printed
		awful.spawn.with_line_callback(todo_subscribe_script, {
			stdout = function(_)
				emit_todo_info()
			end,
		})
	end
)
