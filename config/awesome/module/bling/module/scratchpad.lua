local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

local ruled
if awesome.version ~= "v4.3" then
    ruled = require("ruled")
end

local helpers = require(tostring(...):match(".*bling") .. ".helpers")

local Scratchpad = { mt = {} }

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
    args.in_anim = false
    local ret = gears.object({})
    gears.table.crush(ret, Scratchpad)
    gears.table.crush(ret, args)
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

--- The turn on animation
local function animate_turn_on(self, c, anim, axis)
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

    anim:subscribe(function(pos)
        if c and c.valid then
            if axis == "x" then
                c.x = pos
            else
                c.y = pos
            end
        end
        self.in_anim = true
    end)

    if axis == "x" then
        anim:set(self.geometry.x)
    else
        anim:set(self.geometry.y)
    end

    anim.ended:subscribe(function()
        self.in_anim = false
        anim:unsubscribe()
        anim.ended:unsubscribe()
    end)
end

--- Turns the scratchpad on
function Scratchpad:turn_on()
    local c = self:find()[1]
    local anim_x = self.rubato.x
    local anim_y = self.rubato.y

    if c and not self.in_anim and c.first_tag and c.first_tag.selected then
        c:raise()
        client.focus = c
        return
    end
    if c and not self.in_anim then
        -- if a client was found, turn it on
        if self.reapply then
            self:apply(c)
        end
        -- c.sticky was set to false in turn_off so it has to be reapplied anyway
        c.sticky = self.sticky

        if anim_x then
            animate_turn_on(self, c, anim_x, "x")
        end
        if anim_y then
            animate_turn_on(self, c, anim_y, "y")
        end

        helpers.client.turn_on(c)
        self:emit_signal("turn_on", c)

        return
    end
    if not c then
        -- if no client was found, spawn one, find the corresponding window,
        --  apply the properties only once (until the next closing)
        local pid = awful.spawn.with_shell(self.command)
        if awesome.version ~= "v4.3" then
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
                            self:apply(c)
                            c.hidden = false
                            c.minimized = false
                            -- Some clients fail to gain focus
                            c:activate({})

                            if anim_x then
                                animate_turn_on(self, c, anim_x, "x")
                            end
                            if anim_y then
                                animate_turn_on(self, c, anim_y, "y")
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
                    self:apply(c1)
                    if anim_x then
                        animate_turn_on(self, c1, anim_x, "x")
                    end
                    if anim_y then
                        animate_turn_on(self, c1, anim_y, "y")
                    end
                    self:emit_signal("inital_apply", c1)
                    client.disconnect_signal("manage", inital_apply)
                end
            end
            client.connect_signal("manage", inital_apply)
        end
    end
end

--- Called when the turn off animation has ended
local function on_animate_turn_off_end(self, c, anim, tag, turn_off_on_end)
    anim:unsubscribe()
    anim.ended:unsubscribe()

    if turn_off_on_end then
        -- When toggling off a scratchpad that's present on multiple tags
        -- depsite still being unminizmied on the other tags it will become invisible
        -- as it's position could be outside the screen from the animation
        c:geometry({
            x = self.geometry.x + c.screen.geometry.x,
            y = self.geometry.y + c.screen.geometry.y,
            width = self.geometry.width,
            height = self.geometry.height,
        })
        helpers.client.turn_off(c, tag)

        self:emit_signal("turn_off", c)

        self.in_anim = false
    end
end

--- The turn off animation
local function animate_turn_off(self, c, anim, axis, turn_off_on_end)
    local screen_on_toggled_scratchpad = c.screen
    local tag_on_toggled_scratchpad = screen_on_toggled_scratchpad.selected_tag

    if c.floating == false then
        -- Save the client geometry before floating it
        local non_floating_x = c.x
        local non_floating_y = c.y
        local non_floating_width = c.width
        local non_floating_height = c.height

        -- Can't animate non floating clients
        c.floating = true

        -- Set the client geometry back to what it was before floating it
        c:geometry({
            x = non_floating_x,
            y = non_floating_y,
            width = non_floating_width,
            height = non_floating_height,
        })
    end


    if axis == "x" then
        anim.pos = c.x
    else
        anim.pos = c.y
    end

    anim:subscribe(function(pos)
        if c and c.valid then
            if axis == "x" then
                c.x = pos
            else
                c.y = pos
            end
        end
        self.in_anim = true

        -- Handles changing tag mid animation
        -- Check for the following scenerio:
        -- Toggle on scratchpad at tag 1
        -- Toggle on scratchpad at tag 2
        -- Toggle off scratchpad at tag 1
        -- Switch to tag 2
        -- Outcome: The client will remain on tag 1 and will instead be removed from tag 2
        if screen_on_toggled_scratchpad.selected_tag ~= tag_on_toggled_scratchpad then
            on_animate_turn_off_end(self, c, anim, tag_on_toggled_scratchpad, true)
        end
    end)

    anim:set(anim:initial())

    anim.ended:subscribe(function()
        on_animate_turn_off_end(self, c, anim, nil, turn_off_on_end)
    end)
end

--- Turns the scratchpad off
function Scratchpad:turn_off()
    local c = self:find()[1]
    if c and not self.in_anim then
        -- Get the tweens
        local anim_x = self.rubato.x
        local anim_y = self.rubato.y

        local anim_x_duration = (anim_x and anim_x.duration) or 0
        local anim_y_duration = (anim_y and anim_y.duration) or 0

        local turn_off_on_end = (anim_x_duration >= anim_y_duration) and true or false
        if anim_x then
            animate_turn_off(self, c, anim_x, "x", turn_off_on_end)
        end
        if anim_y then
            animate_turn_off(self, c, anim_y, "y", not turn_off_on_end)
        end

        if not anim_x and not anim_y then
            helpers.client.turn_off(c)
            self:emit_signal("turn_off", c)
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
        is_turn_off = client.focus
            and awful.rules.match(client.focus, self.rule)
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
