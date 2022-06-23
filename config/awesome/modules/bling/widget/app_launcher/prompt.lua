---------------------------------------------------------------------------
--- Modified Prompt module.
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Julien Danjou
---------------------------------------------------------------------------

local akey = require("awful.key")
local keygrabber = require("awful.keygrabber")
local gobject = require("gears.object")
local gdebug = require('gears.debug')
local gtable = require("gears.table")
local gcolor = require("gears.color")
local gstring = require("gears.string")
local gfs = require("gears.filesystem")
local wibox = require("wibox")
local beautiful = require("beautiful")
local io = io
local table = table
local math = math
local ipairs = ipairs
local unpack = unpack or table.unpack -- luacheck: globals unpack (compatibility with Lua 5.1)
local capi = { selection = selection }

local prompt  = { mt = {} }

--- Private data
local data = {}
data.history = {}

local function itera(inc,a, i)
    i = i + inc
    local v = a[i]
    if v then return i,v end
end

local function history_check_load(id, max)
    if id and id ~= "" and not data.history[id] then
        data.history[id] = { max = 50, table = {} }

        if max then
            data.history[id].max = max
        end

        local f = io.open(id, "r")
        if not f then return end

        -- Read history file
        for line in f:lines() do
            if gtable.hasitem(data.history[id].table, line) == nil then
                table.insert(data.history[id].table, line)
                if #data.history[id].table >= data.history[id].max then
                    break
                end
            end
        end
        f:close()
    end
end

local function is_word_char(c)
    if string.find(c, "[{[(,.:;_-+=@/ ]") then
        return false
    else
        return true
    end
end

local function cword_start(s, pos)
    local i = pos
    if i > 1 then
        i = i - 1
    end
    while i >= 1 and not is_word_char(s:sub(i, i)) do
        i = i - 1
    end
    while i >= 1 and is_word_char(s:sub(i, i)) do
        i = i - 1
    end
    if i <= #s then
        i = i + 1
    end
    return i
end

local function cword_end(s, pos)
    local i = pos
    while i <= #s and not is_word_char(s:sub(i, i)) do
        i = i + 1
    end
    while i <= #s and  is_word_char(s:sub(i, i)) do
        i = i + 1
    end
    return i
end

local function history_save(id)
    if data.history[id] then
        gfs.make_parent_directories(id)
        local f = io.open(id, "w")
        if not f then
            gdebug.print_warning("Failed to write the history to "..id)
            return
        end
        for i = 1, math.min(#data.history[id].table, data.history[id].max) do
            f:write(data.history[id].table[i] .. "\n")
        end
       f:close()
    end
end

local function history_items(id)
    if data.history[id] then
        return #data.history[id].table
    else
        return -1
    end
end

local function history_add(id, command)
    if data.history[id] and command ~= "" then
        local index = gtable.hasitem(data.history[id].table, command)
        if index == nil then
            table.insert(data.history[id].table, command)

            -- Do not exceed our max_cmd
            if #data.history[id].table > data.history[id].max then
                table.remove(data.history[id].table, 1)
            end

            history_save(id)
        else
            -- Bump this command to the end of history
            table.remove(data.history[id].table, index)
            table.insert(data.history[id].table, command)
            history_save(id)
        end
    end
end

local function have_multibyte_char_at(text, position)
    return text:sub(position, position):wlen() == -1
end

local function prompt_text_with_cursor(args)
    local char, spacer, text_start, text_end, ret
    local text = args.text or ""
    local _prompt = args.prompt or ""
    local underline = args.cursor_ul or "none"

    if args.select_all then
        if #text == 0 then char = " " else char = gstring.xml_escape(text) end
        spacer = " "
        text_start = ""
        text_end = ""
    elseif #text < args.cursor_pos then
        char = " "
        spacer = ""
        text_start = gstring.xml_escape(text)
        text_end = ""
    else
        local offset = 0
        if have_multibyte_char_at(text, args.cursor_pos) then
            offset = 1
        end
        char = gstring.xml_escape(text:sub(args.cursor_pos, args.cursor_pos + offset))
        spacer = " "
        text_start = gstring.xml_escape(text:sub(1, args.cursor_pos - 1))
        text_end = gstring.xml_escape(text:sub(args.cursor_pos + 1 + offset))
    end

    local cursor_color = gcolor.ensure_pango_color(args.cursor_color)
    local text_color = gcolor.ensure_pango_color(args.text_color)

    if args.highlighter then
        text_start, text_end = args.highlighter(text_start, text_end)
    end

    ret = _prompt .. text_start .. "<span background=\"" .. cursor_color ..
        "\" foreground=\"" .. text_color .. "\" underline=\"" .. underline ..
        "\">" .. char .. "</span>" .. text_end .. spacer

    return ret
end

local function update(self)
    self.textbox:set_font(self.font)
    self.textbox:set_markup(prompt_text_with_cursor{
       text = self.command, text_color = self.fg_cursor, cursor_color = self.bg_cursor,
       cursor_pos = self._private_cur_pos, cursor_ul = self.ul_cursor, select_all = self.select_all,
       prompt = self.prompt, highlighter = self.highlighter })
end

local function exec(self, cb, command_to_history)
    self.textbox:set_markup("")
    history_add(self.history_path, command_to_history)
    keygrabber.stop(self._private.grabber)
    if cb then cb(self.command) end
    if self.done_callback then
        self.done_callback()
    end
end

function prompt:start()
    -- The cursor position
    if self.reset_on_stop == true or self._private_cur_pos == nil then
        self._private_cur_pos = (self.select_all and 1) or self.text:wlen() + 1
    end
    if self.reset_on_stop == true then self.text = "" self.command = "" end

    self.textbox:set_font(self.font)
    self.textbox:set_markup(prompt_text_with_cursor{
        text = self.reset_on_stop and self.text or self.command, text_color = self.fg_cursor, cursor_color = self.bg_cursor,
        cursor_pos = self._private_cur_pos, cursor_ul = self.ul_cursor, select_all = self.select_all,
        prompt = self.prompt, highlighter = self.highlighter})

    self._private.search_term = nil

    history_check_load(self.history_path, self.history_max)
    local history_index = history_items(self.history_path) + 1

    -- The completion element to use on completion request.
    local ncomp = 1

    local command_before_comp
    local cur_pos_before_comp

    self._private.grabber = keygrabber.run(function(modifiers, key, event)
        -- Convert index array to hash table
        local mod = {}
        for _, v in ipairs(modifiers) do mod[v] = true end

        if event ~= "press" then
            if self.keyreleased_callback then
                self.keyreleased_callback(mod, key, self.command)
            end
            return
        end

        -- Call the user specified callback. If it returns true as
        -- the first result then return from the function. Treat the
        -- second and third results as a new command and new prompt
        -- to be set (if provided)
        if self.keypressed_callback then
            local user_catched, new_command, new_prompt =
            self.keypressed_callback(mod, key, self.command)
            if new_command or new_prompt then
                if new_command then
                    self.command = new_command
                end
                if new_prompt then
                    self.prompt = new_prompt
                end
                update(self)
            end
            if user_catched then
                if self.changed_callback then
                    self.changed_callback(self.command)
                end
                return
            end
        end

        local filtered_modifiers = {}

        -- User defined cases
        if self.hooks[key] then
            -- Remove caps and num lock
            for _, m in ipairs(modifiers) do
                if not gtable.hasitem(akey.ignore_modifiers, m) then
                    table.insert(filtered_modifiers, m)
                end
            end

            for _,v in ipairs(self.hooks[key]) do
                if #filtered_modifiers == #v[1] then
                    local match = true
                    for _,v2 in ipairs(v[1]) do
                        match = match and mod[v2]
                    end
                    if match then
                        local cb
                        local ret, quit = v[3](self.command)
                        local original_command = self.command

                        -- Support both a "simple" and a "complex" way to
                        -- control if the prompt should quit.
                        quit = quit == nil and (ret ~= true) or (quit~=false)

                        -- Allow the callback to change the command
                        self.command = (ret ~= true) and ret or self.command

                        -- Quit by default, but allow it to be disabled
                        if ret and type(ret) ~= "boolean" then
                            cb = self.exe_callback
                            if not quit then
                                self._private_cur_pos = ret:wlen() + 1
                                update(self)
                            end
                        elseif quit then
                            -- No callback.
                            cb = function() end
                        end

                        -- Execute the callback
                        if cb then
                            exec(self, cb, original_command)
                        end

                        return
                    end
                end
            end
        end

        -- Get out cases
        if (mod.Control and (key == "c" or key == "g"))
            or (not mod.Control and key == "Escape") then
            self:stop()
            return false
        elseif (mod.Control and (key == "j" or key == "m"))
            -- or (not mod.Control and key == "Return")
            -- or (not mod.Control and key == "KP_Enter")
            then
            exec(self, self.exe_callback, self.command)
            -- We already unregistered ourselves so we don't want to return
            -- true, otherwise we may unregister someone else.
            return
        end

        -- Control cases
        if mod.Control then
            self.select_all = nil
            if key == "v" then
                local selection = capi.selection()
                if selection then
                    -- Remove \n
                    local n = selection:find("\n")
                    if n then
                        selection = selection:sub(1, n - 1)
                    end
                    self.command = self.command:sub(1, self._private_cur_pos - 1) .. selection .. self.command:sub(self._private_cur_pos)
                    self._private_cur_pos = self._private_cur_pos + #selection
                end
            elseif key == "a" then
                self._private_cur_pos = 1
            elseif key == "b" then
                if self._private_cur_pos > 1 then
                    self._private_cur_pos = self._private_cur_pos - 1
                    if have_multibyte_char_at(self.command, self._private_cur_pos) then
                        self._private_cur_pos = self._private_cur_pos - 1
                    end
                end
            elseif key == "d" then
                if self._private_cur_pos <= #self.command then
                    self.command = self.command:sub(1, self._private_cur_pos - 1) .. self.command:sub(self._private_cur_pos + 1)
                end
            elseif key == "p" then
                if history_index > 1 then
                    history_index = history_index - 1

                    self.command = data.history[self.history_path].table[history_index]
                    self._private_cur_pos = #self.command + 2
                end
            elseif key == "n" then
                if history_index < history_items(self.history_path) then
                    history_index = history_index + 1

                    self.command = data.history[self.history_path].table[history_index]
                    self._private_cur_pos = #self.command + 2
                elseif history_index == history_items(self.history_path) then
                    history_index = history_index + 1

                    self.command = ""
                    self._private_cur_pos = 1
                end
            elseif key == "e" then
                self._private_cur_pos = #self.command + 1
            elseif key == "r" then
                self._private.search_term = self._private.search_term or self.command:sub(1, self._private_cur_pos - 1)
                for i,v in (function(a,i) return itera(-1,a,i) end), data.history[self.history_path].table, history_index do
                    if v:find(self._private.search_term,1,true) ~= nil then
                        self.command=v
                        history_index=i
                        self._private_cur_pos=#self.command+1
                        break
                    end
                end
            elseif key == "s" then
                self._private.search_term = self._private.search_term or self.command:sub(1, self._private_cur_pos - 1)
                for i,v in (function(a,i) return itera(1,a,i) end), data.history[self.history_path].table, history_index do
                    if v:find(self._private.search_term,1,true) ~= nil then
                        self.command=v
                        history_index=i
                        self._private_cur_pos=#self.command+1
                        break
                    end
                end
            elseif key == "f" then
                if self._private_cur_pos <= #self.command then
                    if have_multibyte_char_at(self.command, self._private_cur_pos) then
                        self._private_cur_pos = self._private_cur_pos + 2
                    else
                        self._private_cur_pos = self._private_cur_pos + 1
                    end
                end
            elseif key == "h" then
                if self._private_cur_pos > 1 then
                    local offset = 0
                    if have_multibyte_char_at(self.command, self._private_cur_pos - 1) then
                        offset = 1
                    end
                    self.command = self.command:sub(1, self._private_cur_pos - 2 - offset) .. self.command:sub(self._private_cur_pos)
                    self._private_cur_pos = self._private_cur_pos - 1 - offset
                end
            elseif key == "k" then
                self.command = self.command:sub(1, self._private_cur_pos - 1)
            elseif key == "u" then
                self.command = self.command:sub(self._private_cur_pos, #self.command)
                self._private_cur_pos = 1
            elseif key == "Prior" then
                self._private.search_term = self.command:sub(1, self._private_cur_pos - 1) or ""
                for i,v in (function(a,i) return itera(-1,a,i) end), data.history[self.history_path].table, history_index do
                    if v:find(self._private.search_term,1,true) == 1 then
                        self.command=v
                        history_index=i
                        break
                    end
                end
            elseif key == "Next" then
                self._private.search_term = self.command:sub(1, self._private_cur_pos - 1) or ""
                for i,v in (function(a,i) return itera(1,a,i) end), data.history[self.history_path].table, history_index do
                    if v:find(self._private.search_term,1,true) == 1 then
                        self.command=v
                        history_index=i
                        break
                    end
                end
            elseif key == "w" or key == "BackSpace" then
                local wstart = 1
                local wend = 1
                local cword_start_pos = 1
                local cword_end_pos = 1
                while wend < self._private_cur_pos do
                    wend = self.command:find("[{[(,.:;_-+=@/ ]", wstart)
                    if not wend then wend = #self.command + 1 end
                    if self._private_cur_pos >= wstart and self._private_cur_pos <= wend + 1 then
                        cword_start_pos = wstart
                        cword_end_pos = self._private_cur_pos - 1
                        break
                    end
                    wstart = wend + 1
                end
                self.command = self.command:sub(1, cword_start_pos - 1) .. self.command:sub(cword_end_pos + 1)
                self._private_cur_pos = cword_start_pos
            elseif key == "Delete" then
                -- delete from history only if:
                --  we are not dealing with a new command
                --  the user has not edited an existing entry
                if self.command == data.history[self.history_path].table[history_index] then
                    table.remove(data.history[self.history_path].table, history_index)
                    if history_index <= history_items(self.history_path) then
                        self.command = data.history[self.history_path].table[history_index]
                        self._private_cur_pos = #self.command + 2
                    elseif history_index > 1 then
                        history_index = history_index - 1

                        self.command = data.history[self.history_path].table[history_index]
                        self._private_cur_pos = #self.command + 2
                    else
                        self.command = ""
                        self._private_cur_pos = 1
                    end
                end
            end
        elseif mod.Mod1 or mod.Mod3 then
            if key == "b" then
                self._private_cur_pos = cword_start(self.command, self._private_cur_pos)
            elseif key == "f" then
                self._private_cur_pos = cword_end(self.command, self._private_cur_pos)
            elseif key == "d" then
                self.command = self.command:sub(1, self._private_cur_pos - 1) .. self.command:sub(cword_end(self.command, self._private_cur_pos))
            elseif key == "BackSpace" then
                local wstart = cword_start(self.command, self._private_cur_pos)
                self.command = self.command:sub(1, wstart - 1) .. self.command:sub(self._private_cur_pos)
                self._private_cur_pos = wstart
            end
        else
            if self.completion_callback then
                if key == "Tab" or key == "ISO_Left_Tab" then
                    if key == "ISO_Left_Tab" or mod.Shift then
                        if ncomp == 1 then return end
                        if ncomp == 2 then
                            self.command = command_before_comp
                            self.textbox:set_font(self.font)
                            self.textbox:set_markup(prompt_text_with_cursor{
                                text = command_before_comp, text_color = self.fg_cursor, cursor_color = self.bg_cursor,
                                cursor_pos = self._private_cur_pos, cursor_ul = self.ul_cursor, select_all = self.select_all,
                                prompt = self.prompt })
                            self._private_cur_pos = cur_pos_before_comp
                            ncomp = 1
                            return
                        end

                        ncomp = ncomp - 2
                    elseif ncomp == 1 then
                        command_before_comp = self.command
                        cur_pos_before_comp = self._private_cur_pos
                    end
                    local matches
                    self.command, self._private_cur_pos, matches = self.completion_callback(command_before_comp, cur_pos_before_comp, ncomp)
                    ncomp = ncomp + 1
                    key = ""
                    -- execute if only one match found and autoexec flag set
                    if matches and #matches == 1 and args.autoexec then
                        exec(self, self.exe_callback)
                        return
                    end
                elseif key ~= "Shift_L" and key ~= "Shift_R" then
                    ncomp = 1
                end
            end

            -- Typin cases
            if mod.Shift and key == "Insert" then
                local selection = capi.selection()
                if selection then
                    -- Remove \n
                    local n = selection:find("\n")
                    if n then
                        selection = selection:sub(1, n - 1)
                    end
                    self.command = self.command:sub(1, self._private_cur_pos - 1) .. selection .. self.command:sub(self._private_cur_pos)
                    self._private_cur_pos = self._private_cur_pos + #selection
                end
            elseif key == "Home" then
                self._private_cur_pos = 1
            elseif key == "End" then
                self._private_cur_pos = #self.command + 1
            elseif key == "BackSpace" then
                if self._private_cur_pos > 1 then
                    local offset = 0
                    if have_multibyte_char_at(self.command, self._private_cur_pos - 1) then
                        offset = 1
                    end
                    self.command = self.command:sub(1, self._private_cur_pos - 2 - offset) .. self.command:sub(self._private_cur_pos)
                    self._private_cur_pos = self._private_cur_pos - 1 - offset
                end
            elseif key == "Delete" then
                self.command = self.command:sub(1, self._private_cur_pos - 1) .. self.command:sub(self._private_cur_pos + 1)
            elseif key == "Left" then
                self._private_cur_pos = self._private_cur_pos - 1
            elseif key == "Right" then
                self._private_cur_pos = self._private_cur_pos + 1
            elseif key == "Prior" then
                if history_index > 1 then
                    history_index = history_index - 1

                    self.command = data.history[self.history_path].table[history_index]
                    self._private_cur_pos = #self.command + 2
                end
            elseif key == "Next" then
               if history_index < history_items(self.history_path) then
                    history_index = history_index + 1

                    self.command = data.history[self.history_path].table[history_index]
                    self._private_cur_pos = #self.command + 2
                elseif history_index == history_items(self.history_path) then
                    history_index = history_index + 1

                    self.command = ""
                    self._private_cur_pos = 1
                end
            else
                -- wlen() is UTF-8 aware but #key is not,
                -- so check that we have one UTF-8 char but advance the cursor of # position
                if key:wlen() == 1 then
                    if self.select_all then self.command = "" end
                    self.command = self.command:sub(1, self._private_cur_pos - 1) .. key .. self.command:sub(self._private_cur_pos)
                    self._private_cur_pos = self._private_cur_pos + #key
                end
            end
            if self._private_cur_pos < 1 then
                self._private_cur_pos = 1
            elseif self._private_cur_pos > #self.command + 1 then
                self._private_cur_pos = #self.command + 1
            end
            self.select_all = nil
        end

        update(self)
        if self.changed_callback then
            self.changed_callback(self.command)
        end
    end)
end

function prompt:stop()
    keygrabber.stop(self._private.grabber)
    history_save(self.history_path)
    if self.done_callback then self.done_callback() end
    return false
end

local function new(args)
    args = args or {}

    args.command = args.text or ""
    args.prompt = args.prompt or ""
    args.text = args.text or ""
    args.font = args.font or beautiful.prompt_font or beautiful.font
    args.bg_cursor = args.bg_cursor or beautiful.prompt_bg_cursor or beautiful.bg_focus or "white"
    args.fg_cursor = args.fg_cursor or beautiful.prompt_fg_cursor or beautiful.fg_focus or "black"
    args.ul_cursor = args.ul_cursor or nil
    args.reset_on_stop = args.reset_on_stop == nil and true or args.reset_on_stop
    args.select_all = args.select_all or nil
    args.highlighter = args.highlighter or nil
    args.hooks = args.hooks or {}
    args.keypressed_callback = args.keypressed_callback or nil
    args.changed_callback = args.changed_callback or nil
    args.done_callback = args.done_callback or nil
    args.history_max = args.history_max or nil
    args.history_path = args.history_path or nil
    args.completion_callback = args.completion_callback or nil
    args.exe_callback = args.exe_callback or nil
    args.textbox  = args.textbox or wibox.widget.textbox()

    -- Build the hook map
    local hooks = {}
    for _,v in ipairs(args.hooks) do
        if #v == 3 then
            local _,key,callback = unpack(v)
            if type(callback) == "function" then
                hooks[key] = hooks[key] or {}
                hooks[key][#hooks[key]+1] = v
            else
                gdebug.print_warning("The hook's 3rd parameter has to be a function.")
            end
        else
            gdebug.print_warning("The hook has to have 3 parameters.")
        end
    end
    args.hooks = hooks

    local ret = gobject({})
    ret._private = {}
    gtable.crush(ret, prompt)
    gtable.crush(ret, args)

    return ret
end

function prompt.mt:__call(...)
    return new(...)
end

return setmetatable(prompt, prompt.mt)