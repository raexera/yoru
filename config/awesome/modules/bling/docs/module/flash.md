## 🔦 Flash Focus <!-- {docsify-ignore} -->

Flash focus does an opacity animation effect on a client when it is focused.


### Usage

There are two ways in which you can use this module. You can enable it by calling the `enable()` function:
```lua
bling.module.flash_focus.enable()
```
This connects to the focus signal of a client, which means that the flash focus will activate however you focus the client.

The other way is to call the function itself like this: `bling.module.flash_focus.flashfocus(someclient)`. This allows you to activate on certain keybinds like so:
```lua
awful.key({modkey}, "Up",
    function()
        awful.client.focus.bydirection("up")
        bling.module.flash_focus.flashfocus(client.focus)
     end, {description = "focus up", group = "client"})
```

### Theme Variables
```lua
theme.flash_focus_start_opacity = 0.6 -- the starting opacity
theme.flash_focus_step = 0.01         -- the step of animation
```

### Preview

![](https://imgur.com/5txYrlV.gif)

*gif by [JavaCafe01](https://github.com/JavaCafe01)*
