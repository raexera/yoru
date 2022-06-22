## 🏬 Tiled Wallpaper <!-- {docsify-ignore} -->

### Usage

The function to set an automatically created tiled wallpaper can be called the following way (you don't need to set every option in the table):
```lua
awful.screen.connect_for_each_screen(function(s) -- that way the wallpaper is applied to every screen
    bling.module.tiled_wallpaper("x", s, {       -- call the actual function ("x" is the string that will be tiled)
        fg = "#ff0000", -- define the foreground color
        bg = "#00ffff", -- define the background color
        offset_y = 25,  -- set a y offset
        offset_x = 25,  -- set a x offset
        font = "Hack",  -- set the font (without the size)
        font_size = 14, -- set the font size
        padding = 100,  -- set padding (default is 100)
        zickzack = true -- rectangular pattern or criss cross
    })
end)
```

### Preview

![](https://media.discordapp.net/attachments/702548913999314964/773887721294135296/tiled-wallpapers.png?width=1920&height=1080)

*screenshots by [Nooo37](https://github.com/Nooo37)*

