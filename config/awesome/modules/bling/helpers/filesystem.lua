local Gio = require("lgi").Gio
local awful = require("awful")
local string = string

local _filesystem = {}

--- Get a list of files from a given directory.
-- @string path The directory to search.
-- @tparam[opt] table exts Specific extensions to limit the search to. eg:`{ "jpg", "png" }`
--   If ommited, all files are considered.
-- @bool[opt=false] recursive List files from subdirectories
-- @staticfct bling.helpers.filesystem.get_random_file_from_dir
function _filesystem.list_directory_files(path, exts, recursive)
    recursive = recursive or false
    local files, valid_exts = {}, {}

    -- Transforms { "jpg", ... } into { [jpg] = #, ... }
    if exts then
        for i, j in ipairs(exts) do
            valid_exts[j:lower()] = i
        end
    end

    -- Build a table of files from the path with the required extensions
    local file_list = Gio.File.new_for_path(path):enumerate_children(
        "standard::*",
        0
    )
    if file_list then
        for file in function()
            return file_list:next_file()
        end do
            local file_type = file:get_file_type()
            if file_type == "REGULAR" then
                local file_name = file:get_display_name()
                if
                    not exts
                    or valid_exts[file_name:lower():match(".+%.(.*)$") or ""]
                then
                    table.insert(files, file_name)
                end
            elseif recursive and file_type == "DIRECTORY" then
                local file_name = file:get_display_name()
                files = gears.table.join(
                    files,
                    list_directory_files(file_name, exts, recursive)
                )
            end
        end
    end

    return files
end

function _filesystem.save_image_async_curl(url, filepath, callback)
    awful.spawn.with_line_callback(string.format("curl -L -s %s -o %s", url, filepath),
    {
      exit=callback
    })
end

return _filesystem
