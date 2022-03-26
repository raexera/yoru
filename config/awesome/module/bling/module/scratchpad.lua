local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local helpers = require(tostring(...):match(".*bling") .. ".helpers")
local capi = { awesome = awesome, client = client }
local ruled = capi.awesome.version ~= "v4.3" and require("ruled") or nil
local pairs = pairs

local Scratchpad = { mt = {} }

--- Called when the turn off animation has ended
local function on_animate_turn_off_end(self, tag)
    -- When toggling off a scratchpad that's present on multiple tags
    -- depsite still being unminizmied on the other tags it will become invisible
    -- as it's position could be outside the screen from the animation
    self.client:geometry({
        x = self.geometry.x + self.client.screen.geometry.x,
        y = self.geometry.y + self.client.screen.geometry.y,
        width = self.geometry.width,
        height = self.geometry.height,
    })

    helpers.client.turn_off(self.client, tag)

    self.turning_off = false

    self:emit_signal("turn_off", self.client)
end

--- The turn off animation
local function animate_turn_off(self, anim, axis)
    self.screen_on_toggled_scratchpad = self.client.screen
    self.tag_on_toggled_scratchpad = self.screen_on_toggled_scratchpad.selected_tag

    if self.client.floating == false then
        -- Save the client geometry before floating it
        local non_floating_x = self.client.x
        local non_floating_y = self.client.y
        local non_floating_width = self.client.width
        local non_floating_height = self.client.height

        -- Can't animate non floating clients
        self.client.floating = true

        -- Set the client geometry back to what it was before floating it
        self.client:geometry({
            x = non_floating_x,
            y = non_floating_y,
            width = non_floating_width,
            height = non_floating_height,
        })
    end

    if axis == "x" then
        anim.pos = self.client.x
    else
        anim.pos = self.client.y
    end

    anim:set(anim:initial())
end

-- Handles changing tag mid animation
local function abort_if_tag_was_switched(self)
    -- Check for the following scenerio:
    -- Toggle on scratchpad at tag 1
    -- Toggle on scratchpad at tag 2
    -- Toggle off scratchpad at tag 1
    -- Switch to tag 2
    -- Outcome: The client will remain on tag 1 and will instead be removed from tag 2
    if (self.turning_off) and (self.screen_on_toggled_scratchpad and
        self.screen_on_toggled_scratchpad.selected_tag) ~= self.tag_on_toggled_scratchpad
    then
        if self.rubato.x then
            self.rubato.x:abort()
        end
        if self.rubato.y then
            self.rubato.y:abort()
        end
        on_animate_turn_off_end(self, self.tag_on_toggled_scratchpad)
        self.screen_on_toggled_scratchpad.selected_tag = nil
        self.tag_on_toggled_scratchpad = nil
    end
end

--- The turn on animation
local function animate_turn_on(self, anim, axis)
    -- Check for the following scenerio:
    -- Toggle on scratchpad at tag 1
    -- Toggle on scratchpad at tag 2
    -- The animation will instantly end
    -- as the timer pos is already at the on position
    -- from toggling on the scratchpad at tag 1
    if axis == "x" and anim.pos == self.geometry.x then
        anim.pos = anim:initial()
    else
        if anim.pos == self.geometry.y then
            anim.pos = anim:initial()
        end
    end

    if axis == "x" then
        anim:set(self.geometry.x)
    else
        anim:set(self.geometry.y)
    end
end

--- Creates a new scratchpad object based on the argument
--
-- @param args A table of possible arguments
-- @return The new scratchpad object
function Scratchpad:new(args)
    args = args or {}
    if args.awestore then
        naughty.notify({
            title = "Bling Error",
            text = "Awestore is no longer supported! Please take a look at the scratchpad documentation and use rubato for animations instead.",
        })
    end

    args.rubato = args.rubato or {}

    local ret = gears.object{}
    gears.table.crush(ret, Scratchpad)
    gears.table.crush(ret, args)

    if ret.rubato.x then
        ret.rubato.x:subscribe(function(pos)
            if ret.client and ret.client.valid then
                ret.client.x = pos
            end
            abort_if_tag_was_switched(ret)
        end)

        ret.rubato.x.ended:subscribe(function()
            if ((ret.rubato.y and ret.rubato.y.state == false) or (ret.rubato.y == nil)) and ret.turning_off == true then
                on_animate_turn_off_end(ret)
            end
        end)
    end
    if ret.rubato.y then
        ret.rubato.y:subscribe(function(pos)
            if ret.client and ret.client.valid then
                ret.client.y = pos
            end
            abort_if_tag_was_switched(ret)
        end)

        ret.rubato.y.ended:subscribe(function()
            if ((ret.rubato.x and ret.rubato.x.state == false) or (ret.rubato.x == nil)) and ret.turning_off == true then
                on_animate_turn_off_end(ret)
            end
        end)
    end

    return ret
end

--- Find all clients that satisfy the the rule
--
-- @return A list of all clients that satisfy the rule
function Scratchpad:find()
    return helpers.client.find(self.rule)
end

--- Applies the objects scratchpad properties to a given client
--
-- @param c A client to which to apply the properties
function Scratchpad:apply(c)
    if not c or not c.valid then
        return
    end
    c.floating = self.floating
    c.sticky = self.sticky
    c.fullscreen = false
    c.maximized = false
    c:geometry({
        x = self.geometry.x + awful.screen.focused().geometry.x,
        y = self.geometry.y + awful.screen.focused().geometry.y,
        width = self.geometry.width,
        height = self.geometry.height,
    })

    if self.autoclose then
        c:connect_signal("unfocus", function(c1)
            c1.sticky = false -- client won't turn off if sticky
            helpers.client.turn_off(c1)
        end)
    end
end

--- Turns the scratchpad on
function Scratchpad:turn_on()
    self.client = self:find()[1]

    local anim_x = self.rubato.x
    local anim_y = self.rubato.y

    local in_anim = false
    if (anim_x and anim_x.state == true) or (anim_y and anim_y.state == true) then
        in_anim = true
    end

    if self.client and not in_anim and self.client.first_tag and self.client.first_tag.selected then
        self.client:raise()
        capi.client.focus = self.client
        return
    end
    if self.client and not in_anim then
        -- if a client was found, turn it on
        if self.reapply then
            self:apply(self.client)
        end
        -- c.sticky was set to false in turn_off so it has to be reapplied anyway
        self.client.sticky = self.sticky

        if anim_x then
            animate_turn_on(self, anim_x, "x")
        end
        if anim_y then
            animate_turn_on(self, anim_y, "y")
        end

        helpers.client.turn_on(self.client)
        self:emit_signal("turn_on", self.client)

        return
    end
    if not self.client then
        -- if no client was found, spawn one, find the corresponding window,
        --  apply the properties only once (until the next closing)
        local pid = awful.spawn.with_shell(self.command)
        if capi.awesome.version ~= "v4.3" then
            ruled.client.append_rule({
                id = "scratchpad",
                rule = self.rule,
                properties = {
                    -- If a scratchpad is opened it should spawn at the current tag
                    -- the same way it will behave if the client was already open
                    tag = awful.screen.focused().selected_tag,
                    switch_to_tags = false,
                    -- Hide the client until the gemoetry rules are applied
                    hidden = true,
                    minimized = true,
                },
                callback = function(c)
                    -- For a reason I can't quite get the gemotery rules will fail to apply unless we use this timer
                    gears.timer({
                        timeout = 0.15,
                        autostart = true,
                        single_shot = true,
                        callback = function()
                            self.client = c

                            self:apply(c)
                            c.hidden = false
                            c.minimized = false
                            -- Some clients fail to gain focus
                            c:activate({})

                            if anim_x then
                                animate_turn_on(self, anim_x, "x")
                            end
                            if anim_y then
                                animate_turn_on(self, anim_y, "y")
                            end

                            self:emit_signal("inital_apply", c)

                            -- Discord spawns 2 windows, so keep the rule until the 2nd window shows
                            if c.name ~= "Discord Updater" then
                                ruled.client.remove_rule("scratchpad")
                            end
                            -- In a case Discord is killed before the second window spawns
                            c:connect_signal("request::unmanage", function()
                                ruled.client.remove_rule("scratchpad")
                            end)
                        end,
                    })
                end,
            })
        else
            local function inital_apply(c1)
                if helpers.client.is_child_of(c1, pid) then
                    self.client = c1

                    self:apply(c1)
                    if anim_x then
                        animate_turn_on(self, anim_x, "x")
                    end
                    if anim_y then
                        animate_turn_on(self, anim_y, "y")
                    end
                    self:emit_signal("inital_apply", c1)
                    client.disconnect_signal("manage", inital_apply)
                end
            end
            client.connect_signal("manage", inital_apply)
        end
    end
end

--- Turns the scratchpad off
function Scratchpad:turn_off()
    self.client = self:find()[1]

    -- Get the tweens
    local anim_x = self.rubato.x
    local anim_y = self.rubato.y

    local in_anim = false
    if (anim_x and anim_x.state == true) or (anim_y and anim_y.state == true) then
        in_anim = true
    end

    if self.client and not in_anim then
        if anim_x then
            self.turning_off = true
            animate_turn_off(self, anim_x, "x")
        end
        if anim_y then
            self.turning_off = true
            animate_turn_off(self, anim_y, "y")
        end

        if not anim_x and not anim_y then
            helpers.client.turn_off(self.client)
            self:emit_signal("turn_off", self.client)
        end
    end
end

--- Turns the scratchpad off if it is focused otherwise it raises the scratchpad
function Scratchpad:toggle()
    local is_turn_off = false
    local c = self:find()[1]
    if self.dont_focus_before_close then
        if c then
            if c.sticky and #c:tags() > 0 then
                is_turn_off = true
            else
                local current_tag = c.screen.selected_tag
                for k, tag in pairs(c:tags()) do
                    if tag == current_tag then
                        is_turn_off = true
                        break
                    else
                        is_turn_off = false
                    end
                end
            end
        end
    else
        is_turn_off = capi.client.focus
            and awful.rules.match(capi.client.focus, self.rule)
    end

    if is_turn_off then
        self:turn_off()
    else
        self:turn_on()
    end
end

--- Make the module callable without putting a `:new` at the end of it
--
-- @param args A table of possible arguments
-- @return The new scratchpad object
function Scratchpad.mt:__call(...)
    return Scratchpad:new(...)
end

return setmetatable(Scratchpad, Scratchpad.mt)
