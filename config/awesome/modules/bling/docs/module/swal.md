## 😋 Window Swallowing <!-- {docsify-ignore} -->

Can your window manager swallow? It probably can...

### Usage

To activate and deactivate window swallowing here are the following functions. If you want to activate it, just call the `start` function once in your `rc.lua`.
```lua
bling.module.window_swallowing.start()  -- activates window swallowing
bling.module.window_swallowing.stop()   -- deactivates window swallowing
bling.module.window_swallowing.toggle() -- toggles window swallowing
```

### Theme Variables
```lua
theme.parent_filter_list   = {"firefox", "Gimp"} -- class names list of parents that should not be swallowed
theme.child_filter_list    = { "Dragon" }        -- class names list that should not swallow their parents
theme.swallowing_filter = true                   -- whether the filters above should be active
```

### Preview

![](https://media.discordapp.net/attachments/635625813143978012/769180910683684864/20-10-23-14-40-32.gif)

*gif by [Nooo37](https://github.com/Nooo37)*
