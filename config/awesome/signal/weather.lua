-- Provides:
-- signal::weather
--      temperature (integer)
--      description (string)
--      icon_code (string)
local awful = require("awful")
local beautiful = require("beautiful")
local helpers = require("helpers")

-- Configuration
local key = openweathermap_key
local city_id = openweathermap_city_id
local units = weather_units
-- Don't update too often, because your requests might get blocked for 24 hours
local update_interval = 1200
local temp_file = "/tmp/awesomewm-signal-weather-"..city_id.."-"..units

local sun_icon = ""
local moon_icon = ""
local dcloud_icon = ""
local ncloud_icon = ""
local cloud_icon = ""
local rain_icon = ""
local storm_icon = ""
local snow_icon = ""
local mist_icon = ""
local whatever_icon = ""

local weather_icons = {
    ["01d"] = { icon = sun_icon, color = beautiful.xcolor3 },
    ["01n"] = { icon = moon_icon, color = beautiful.xcolor4 },
    ["02d"] = { icon = dcloud_icon, color = beautiful.xcolor3 },
    ["02n"] = { icon = ncloud_icon, color = beautiful.xcolor6 },
    ["03d"] = { icon = cloud_icon, color = beautiful.xforeground },
    ["03n"] = { icon = cloud_icon, color = beautiful.xforeground },
    ["04d"] = { icon = cloud_icon, color = beautiful.xforeground },
    ["04n"] = { icon = cloud_icon, color = beautiful.xforeground },
    ["09d"] = { icon = rain_icon, color = beautiful.xcolor4 },
    ["09n"] = { icon = rain_icon, color = beautiful.xcolor4 },
    ["10d"] = { icon = rain_icon, color = beautiful.xcolor4 },
    ["10n"] = { icon = rain_icon, color = beautiful.xcolor4 },
    ["11d"] = { icon = storm_icon, color = beautiful.xforeground },
    ["11n"] = { icon = storm_icon, color = beautiful.xforeground },
    ["13d"] = { icon = snow_icon, color = beautiful.xcolor6 },
    ["13n"] = { icon = snow_icon, color = beautiful.xcolor6 },
    ["40d"] = { icon = mist_icon, color = beautiful.xcolor5 },
    ["40n"] = { icon = mist_icon, color = beautiful.xcolor5 },
    ["50d"] = { icon = mist_icon, color = beautiful.xcolor5 },
    ["50n"] = { icon = mist_icon, color = beautiful.xcolor5 },
    ["_"] = { icon = whatever_icon, color = beautiful.xcolor2 },
}

local weather_details_script = [[
    bash -c '
    KEY="]]..key..[["
    CITY="]]..city_id..[["
    UNITS="]]..units..[["

    weather=$(curl -sf "http://api.openweathermap.org/data/2.5/weather?APPID=$KEY&id=$CITY&units=$UNITS")

    if [ ! -z "$weather" ]; then
        weather_temp=$(echo "$weather" | jq ".main.temp" | cut -d "." -f 1)
        weather_icon=$(echo "$weather" | jq -r ".weather[].icon" | head -1)
        weather_description=$(echo "$weather" | jq -r ".weather[].description" | head -1)

        echo "$weather_icon" "$weather_description"@@"$weather_temp"
    else
        echo "..."
    fi
  ']]

helpers.remote_watch(weather_details_script, update_interval, temp_file, function(stdout)
    local icon_code = string.sub(stdout, 1, 3)
    local weather_details = string.sub(stdout, 5)
    weather_details = string.gsub(weather_details, '^%s*(.-)%s*$', '%1')
    -- Replace "-0" with "0" degrees
    weather_details = string.gsub(weather_details, '%-0', '0')
    -- Capitalize first letter of the description
    weather_details = weather_details:sub(1,1):upper()..weather_details:sub(2)
    local description = weather_details:match('(.*)@@')
    local temperature = weather_details:match('@@(.*)')
    local icon
    local color
    local weather_icon

    if icon_code == "..." then
        -- Remove temp_file to force an update the next time
        awful.spawn.with_shell("rm "..temp_file)
        icon = weather_icons['_'].icon
        color = weather_icons['_'].color
        weather_icon = helpers.colorize_text(icon, color)
        awesome.emit_signal("signal::weather", 999, "Weather unavailable", weather_icon)
    else
        icon = weather_icons[icon_code].icon
        color = weather_icons[icon_code].color
        weather_icon = helpers.colorize_text(icon, color)
        awesome.emit_signal("signal::weather", tonumber(temperature), description, weather_icon)
    end
end)

