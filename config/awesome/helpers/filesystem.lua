local lgi = require("lgi")
local Gio = lgi.Gio
local Glib = lgi.GLib
local awful = require("awful")
local gtimer = require("gears.timer")
local tonumber = tonumber
local tostring = tostring
local ipairs = ipairs
local math = math
local os = os
local capi = { awesome = awesome }

local _filesystem = {}

function _filesystem.is_directory_readable_block(path)
    local gfile = Gio.File.new_for_path(path)
    local gfileinfo = gfile:query_info(
        "standard::type,access::can-read,time::modified",
        Gio.FileQueryInfoFlags.NONE
    )
    return  gfileinfo and gfileinfo:get_file_type() == "DIRECTORY" and
            gfileinfo:get_attribute_boolean("access::can-read")
end

function _filesystem.is_file_readable_block(path)
    local gfile = Gio.File.new_for_path(path)
    local gfileinfo = gfile:query_info(
        "standard::type,access::can-read,time::modified",
        Gio.FileQueryInfoFlags.NONE
    )
    return  gfileinfo and gfileinfo:get_file_type() ~= "DIRECTORY" and
            gfileinfo:get_attribute_boolean("access::can-read")
end

function _filesystem.read_file_block(path)
    if _filesystem.is_file_readable_block(path) == false then
        print("file '" .. path .. "' is not found or not readable...")
        return nil
    else
        local gfile = Gio.File.new_for_path(path)
        local content = gfile:load_contents()
        if content == nil or content == false then
            print("Failed reading " .. path)
            return nil
        else
            return content
        end
    end
end

function _filesystem.query_info(path, callback)
    local gfile = Gio.File.new_for_path(path)
    gfile:query_info_async(
        "standard::type,access::can-read,time::modified",
        Gio.FileQueryInfoFlags.NONE, Glib.PRIORITY_DEFAULT,
        nil,
        function(_, info_result)
            local info, error = gfile:query_info_finish(info_result)
            if info == nil or error ~= nil then
                callback(nil)
                print(error)
                return
            else
                callback(info)
            end
    end, nil)
end

function _filesystem.is_directory_readable(path, callback)
    _filesystem.query_info(path, function(info)
        if info ~= nil then
            if  info:get_file_type() == "DIRECTORY" and
                info:get_attribute_boolean("access::can-read")
            then
                callback(true)
            else
                print("directory '" .. path .. "' is not found or not readable...")
                callback(false)
            end
        else
            print("info for directory '" .. path .. "' could not be retrived")
            callback(false)
        end
    end)
end

function _filesystem.is_file_readable(path, callback)
    _filesystem.query_info(path, function(info)
        if info ~= nil then
            if  info:get_file_type() ~= "DIRECTORY" and
                info:get_attribute_boolean("access::can-read")
            then
                callback(true)
            else
                print("file '" .. path .. "' is not found or not readable...")
                callback(false)
            end
        else
            print("info for file '" .. path .. "' could not be retrived")
            callback(false)
        end
    end)
end

function _filesystem.make_directory(path, callback)
    local gfile = Gio.File.new_for_path(path)
    _filesystem.is_directory_readable(path, function(is_readable)
        if is_readable then
            print("directory '" .. path .. "' already exists")
            callback(true)
            return
        else
            gfile:make_directory_async(Glib.PRIORITY_DEFAULT, nil, function(file, task, c)
                local result, error = gfile:make_directory_finish(task)
                if result == false or error ~= nil then
                    print("Failed creating " .. path)
                    callback(false)
                else
                    print("Successfully created " .. path)
                    callback(true)
                end
            end)
        end
    end)
end

function _filesystem.save_file(path, text, callback, is_retry)
    print("writing to file " .. path)
    local gfile = Gio.File.new_for_path(path)
    _filesystem.is_file_readable(path, function(is_readable)
        if not is_readable then
            if is_retry then
                print("failed creating file "..path)
                if callback then
                    callback(false)
                end
                return
            end
            print("making parent directories...")
            gfile:get_parent():make_directory_with_parents()
            gfile:create_readwrite_async(Gio.FileCreateFlags.NONE, Glib.PRIORITY_DEFAULT, nil, function(_, create_result)
                print("file created " .. tostring(gfile:create_readwrite_finish(create_result)))
                _filesystem.save_file(path, text, callback, true)
            end, nil)
        else
            gfile:open_readwrite_async(Glib.PRIORITY_DEFAULT, nil, function(_, io_stream_result)
                local io_stream = gfile:open_readwrite_finish(io_stream_result)
                io_stream:seek(0, Glib.SeekType.SET, nil)
                local file = io_stream:get_output_stream()
                file:write_all_async(text, Glib.PRIORITY_DEFAULT, nil, function(_, write_result)
                    local length_written = file:write_all_finish(write_result)
                    print("file written " .. length_written)
                    file:truncate(length_written, nil)
                    file:close_async(Glib.PRIORITY_DEFAULT, nil, function(_, file_close_result)
                        print("output stream closed " .. tostring(file:close_finish(file_close_result)))
                        io_stream:close_async(Glib.PRIORITY_DEFAULT, nil, function(_, stream_close_result)
                            print("file stream closed " .. tostring(io_stream:close_finish(stream_close_result)))
                            if callback then
                                callback(true)
                            end
                        end, nil)
                    end, nil)
                end, nil)
            end, nil)
        end
    end)
end

function _filesystem.read_file(path, callback)
    local gfile = Gio.File.new_for_path(path)
    _filesystem.is_file_readable(path, function(is_readable)
        if not is_readable then
            print("file '" .. path .. "' is not found or not readable...")
            callback(nil)
        else
            gfile:load_contents_async(nil, function(file, task, c)
                local content = gfile:load_contents_finish(task)
                if content == nil then
                    print("Failed reading " .. path)
                    callback(nil)
                else
                    callback(content)
                end
            end)
        end
    end)
end

function _filesystem.read_file_uri(uri, callback)
    local gfile = Gio.File.new_for_uri(uri)
    gfile:load_contents_async(nil, function(file, task, c)
        local content = gfile:load_contents_finish(task)
        if content == nil then
            print("Failed reading " .. uri)
            callback(nil)
        else
            callback(content)
        end
    end)
end

function _filesystem.delete_file(path, callback)
    local gfile = Gio.File.new_for_path(path)
    gfile:delete_async(Glib.PRIORITY_DEFAULT, nil, function(file, task, c)
        local result, error = gfile:delete_finish(task)
        if result == false or error ~= nil then
            print("Failed deleting " .. tostring(error))
            if callback then
                callback(false)
            end
        else
            if callback then
                callback(true)
            end
        end
    end)
end

function _filesystem.scan(path, callback, recursive)
    if not path then
        return
    end

    local result = {}

    local function enumerator(path)
        local gfile = Gio.File.new_for_path(path)
        gfile:enumerate_children_async(
            "standard::name,standard::type,access::can-read",
            Gio.FileQueryInfoFlags.NONE,
            0,
            nil,
            function(file, task, c)
                local enum, error = file:enumerate_children_finish(task)
                if enum == nil or error ~= nil then
                    print("Failed enumrating " .. path .. " " .. tostring(error))
                    callback(nil)
                    return
                end

                enum:next_files_async(99999, 0, nil, function(file_enum, task2, c)
                    local files, error = file_enum:next_files_finish(task2)
                    if files == nil or error ~= nil then
                        print("Failed enumrating " .. tostring(error))
                        callback(nil)
                        return
                    end

                    for _, file in ipairs(files) do
                        local file_child = enum:get_child(file)
                        local file_type = file:get_file_type()
                        local readable = file:get_attribute_boolean("access::can-read")
                        if file_type == "REGULAR" and readable then
                            local path = file_child:get_path()
                            if path ~= nil then
                                table.insert(result, path)
                            end
                        elseif file_type == "DIRECTORY" and recursive then
                            enumerator(file_child:get_path())
                        end
                    end

                    enum:close_async(0, nil)
                    callback(result)
                end)
            end)
    end

    enumerator(path)
end

function _filesystem.scan_with_folders(path, callback)
    if not path then
        return
    end

    local files_table = {}
    local folders_table = {}

    local function enumerator(path)
        local gfile = Gio.File.new_for_path(path)
        gfile:enumerate_children_async(
            "standard::name,standard::type,access::can-read",
            Gio.FileQueryInfoFlags.NONE,
            0,
            nil,
            function(file, task, c)
                local enum, error = file:enumerate_children_finish(task)
                if enum == nil or error ~= nil then
                    print("Failed enumrating " .. path .. " " .. tostring(error))
                    callback(nil)
                    return
                end

                enum:next_files_async(99999, 0, nil, function(file_enum, task2, c)
                    local files, error = file_enum:next_files_finish(task2)
                    if files == nil or error ~= nil then
                        print("Failed enumrating " .. tostring(error))
                        callback(nil)
                        return
                    end

                    for _, file in ipairs(files) do
                        local file_child = enum:get_child(file)
                        local file_type = file:get_file_type()
                        local readable = file:get_attribute_boolean("access::can-read")
                        if file_type == "REGULAR" and readable then
                            local path = file_child:get_path()
                            if path ~= nil then
                                table.insert(files_table, path)
                            end
                        elseif file_type == "DIRECTORY" then
                            table.insert(folders_table, file_child:get_path())
                        end
                    end

                    enum:close_async(0, nil)
                    callback(files_table, folders_table)
                end)
            end)
    end

    enumerator(path)
end

function _filesystem.save_uri(path, uri, callback)
    _filesystem.read_file_uri(uri, function(content)
        if content == nil then
            print("Failed to download file " .. uri)
            callback(false)
        else
            _filesystem.save_file(path, content, function(result)
                if result == true then
                    callback(true)
                else
                    print("Failed to save " .. uri .. " to" .. path)
                    callback(false)
                end
            end)
        end
    end)
end

function _filesystem.remote_watch(path, uri, interval, callback, old_content_callback)
    local function download()
        _filesystem.read_file_uri(uri, function(content)
            callback(content)
            if content ~= nil and content ~= false then
                _filesystem.read_file(path, function(old_content)
                    if old_content ~= nil and old_content ~= false then
                        if old_content_callback ~= nil then
                            old_content_callback(old_content)
                        end
                    end

                    _filesystem.save_file(path, content)
                end)
            end
        end)
    end

    _filesystem.read_file(path, function(old_content)
        if old_content ~= nil and old_content ~= false then
            if old_content_callback ~= nil then
                old_content_callback(old_content)
            end
        end

        local timer
        timer = gtimer
        {
            timeout = interval,
            call_now = true,
            autostart = true,
            single_shot = false,
            callback = function()
                _filesystem.query_info(path, function(info)
                    if info ~= nil then
                        local time = info:get_modification_date_time()
                        local diff = math.ceil(Glib.DateTime.new_now_local():difference(time) / 1000000)
                        if diff >= interval then
                            print("Enough time has passed, redownloading " .. path)
                            download()
                        else
                            _filesystem.read_file(path, function(content)
                                if content == nil or content:gsub("%s+", "") == "" then
                                    print("Empty file, Redownloading " .. path)
                                    download()
                                else
                                    callback(content)
                                end
                            end)

                            -- Schedule an update for when the remaining time to complete the interval passes
                            timer:stop()
                            gtimer.start_new(interval - diff, function()
                                print("Finally! redownloading " .. path)
                                download()
                                timer:again()
                            end)
                        end
                    else
                        print(path .. " doesn't exist, downloading " .. uri)
                        download()
                    end
                end)
            end
        }
    end)
end

function _filesystem.get_awesome_config_dir(sub_folder)
    return (capi.awesome.conffile:match(".*/") or "./") .. sub_folder .. "/"
end

function _filesystem.get_cache_dir(sub_folder)
    return (os.getenv("XDG_CACHE_HOME") or os.getenv("HOME") .. "/.cache")
    .. "/awesome/" .. sub_folder .. "/"
end

function _filesystem.get_xdg_cache_home(sub_folder)
    return (os.getenv("XDG_CACHE_HOME") or os.getenv("HOME") .. "/.cache")
    .. "/" .. sub_folder .. "/"
end

return _filesystem