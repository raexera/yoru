-- Provides:
-- signal::uptime
--      up (string)
local awful = require("awful")
local naughty = require("naughty")

local uptime_script = [[
  sh -c "
  cmd=$(uptime)

hr=$( echo $cmd | cut -d \":\" -f3 | awk '{print $NF}') 
mt=$( echo $cmd | cut -d \":\" -f4 | cut -c1-2 )
day=$(echo $cmd | grep day)

if [ -z \"$day\" ]; then
    hour=$(uptime -p | grep hour)
  if [ -z \"$hour\" ]; then
    uptime -p | awk '{print $2$3}' | cut -c1-3
  else
    echo \"${hr}h ${mt}m\"
  fi
else
    day=$(echo $day | cut -d \" \" -f3)
    echo \"${day}d ${hr}h ${mt}m\"
fi

  "]]

local update_interval = 60

-- Periodically get uptime info
awful.widget.watch(uptime_script, update_interval, function(_, stdout)
    local uptime_value = stdout

    uptime_value = string.gsub(uptime_value, '^%s*(.-)%s*$', '%1')
    awesome.emit_signal("signal::uptime", uptime_value)
end)

