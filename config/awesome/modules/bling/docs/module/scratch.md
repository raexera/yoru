## 🍃 Scratchpad <!-- {docsify-ignore} -->

An easy way to create multiple scratchpads.

### A... what?

You can think about a scratchpad as a window whose visibility can be toggled, but still runs in the background without being visible (or minimized) most of the time. Many people use it to have one terminal in which to perform minor tasks, but it is the most useful for windows which only need a couple seconds in between your actual activity, such as music players or chat applications.

### Rubato Animation Support

#### Awestore is now deprecated from Bling, we are switching to Rubato.

Please go over to the [rubato](https://github.com/andOrlando/rubato) repository for installation instructions. Give it a star as well! The animations are completely optional, and if you choose not to use it, you do not need rubato installed.

### Usage

To initalize a scratchpad you can do something like the following:

```lua
local bling = require("bling")
local rubato = require("rubato") -- Totally optional, only required if you are using animations.

-- These are example rubato tables. You can use one for just y, just x, or both.
-- The duration and easing is up to you. Please check out the rubato docs to learn more.
local anim_y = rubato.timed {
    pos = 1090,
    rate = 60,
    easing = rubato.quadratic,
    intro = 0.1,
    duration = 0.3,
    awestore_compat = true -- This option must be set to true.
}

local anim_x = rubato.timed {
    pos = -970,
    rate = 60,
    easing = rubato.quadratic,
    intro = 0.1,
    duration = 0.3,
    awestore_compat = true -- This option must be set to true.
}

local term_scratch = bling.module.scratchpad {
    command = "wezterm start --class spad",           -- How to spawn the scratchpad
    rule = { instance = "spad" },                     -- The rule that the scratchpad will be searched by
    sticky = true,                                    -- Whether the scratchpad should be sticky
    autoclose = true,                                 -- Whether it should hide itself when losing focus
    floating = true,                                  -- Whether it should be floating (MUST BE TRUE FOR ANIMATIONS)
    geometry = {x=360, y=90, height=900, width=1200}, -- The geometry in a floating state
    reapply = true,                                   -- Whether all those properties should be reapplied on every new opening of the scratchpad (MUST BE TRUE FOR ANIMATIONS)
    dont_focus_before_close  = false,                 -- When set to true, the scratchpad will be closed by the toggle function regardless of whether its focused or not. When set to false, the toggle function will first bring the scratchpad into focus and only close it on a second call
    rubato = {x = anim_x, y = anim_y}                 -- Optional. This is how you can pass in the rubato tables for animations. If you don't want animations, you can ignore this option.
}
```

Once initalized, you can use the object (which in this case is named `term_scratch`) like this:

```lua
term_scratch:toggle()   -- toggles the scratchpads visibility
term_scratch:turn_on()  -- turns the scratchpads visibility on
term_scratch:turn_off() -- turns the scratchpads visibility off
```

You can also connect to signals as you are used to for further customization. For example like that:

```lua
term_scratch:connect_signal("turn_on", function(c) naughty.notify({title = "Turned on!"}) end)
```

The following signals are currently available. `turn_on`, `turn_off` and `inital_apply` pass the client on which they operated as an argument:

- `turn_on` fires when the scratchpad is turned on on a tag that it wasn't present on before
- `turn_off` fires when the scratchpad is turned off on a tag
- `spawn` fires when the scratchpad is launched with the given command
- `inital_apply` fires after `spawn`, when a corresponding client has been found and the properties have been applied
