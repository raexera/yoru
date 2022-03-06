local awful = require("awful")
local gears = require("gears")

local function run_once(cmd)
  local findme = cmd
  local firstspace = cmd:find(' ')
  if firstspace then findme = cmd:sub(0, firstspace - 1) end
  awful.spawn.with_shell(string.format(
                             'pgrep -u $USER -x %s > /dev/null || (%s)',
                             findme, cmd), false)
end

-- picom

run_once("picom --experimental-backends --config " ..
             gears.filesystem.get_configuration_dir() .. "theme/picom.conf")

return autostart