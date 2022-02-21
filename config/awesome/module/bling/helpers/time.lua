local time = {}

--- Parse a time string to seconds (from midnight)
--
-- @string time The time (`HH:MM:SS`)
-- @treturn int The number of seconds since 00:00:00
function time.hhmmss_to_seconds(time)
    hour_sec = tonumber(string.sub(time, 1, 2)) * 3600
    min_sec = tonumber(string.sub(time, 4, 5)) * 60
    get_sec = tonumber(string.sub(time, 7, 8))
    return (hour_sec + min_sec + get_sec)
end

--- Get time difference in seconds.
--
-- @tparam string base The time to compare from (`HH:MM:SS`).
-- @tparam string base The time to compare to (`HH:MM:SS`).
-- @treturn int Number of seconds between the two times.
function time.time_diff(base, compare)
    local diff = time.hhmmss_to_seconds(base) - time.hhmmss_to_seconds(compare)
    return diff
end

return time
