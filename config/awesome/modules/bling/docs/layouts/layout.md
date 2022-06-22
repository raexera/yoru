## 📎 Layouts <!-- {docsify-ignore} -->

Choose layouts from the list below and add them to to your `awful.layouts` list in your `rc.lua`.

Everyone of them supports multiple master clients and master width factor making them easy to use.

The mstab layout uses the tab theme from the tabbed module.

```lua
bling.layout.mstab
bling.layout.centered
bling.layout.vertical
bling.layout.horizontal
bling.layout.equalarea
bling.layout.deck
```

### Theme Variables

```lua
-- mstab
theme.mstab_bar_disable = false        -- disable the tabbar
theme.mstab_bar_ontop = false          -- whether you want to allow the bar to be ontop of clients
theme.mstab_dont_resize_slaves = false -- whether the tabbed stack windows should be smaller than the
                                       -- currently focused stack window (set it to true if you use
                                       -- transparent terminals. False if you use shadows on solid ones
theme.mstab_bar_padding = "default"    -- how much padding there should be between clients and your tabbar
                                       -- by default it will adjust based on your useless gaps.
                                       -- If you want a custom value. Set it to the number of pixels (int)
theme.mstab_border_radius = 0          -- border radius of the tabbar
theme.mstab_bar_height = 40            -- height of the tabbar
theme.mstab_tabbar_position = "top"    -- position of the tabbar (mstab currently does not support left,right)
theme.mstab_tabbar_style = "default"   -- style of the tabbar ("default", "boxes" or "modern")
                                       -- defaults to the tabbar_style so only change if you want a
                                       -- different style for mstab and tabbed
```

### Previews

#### Mstab (dynamic tabbing layout)

![](https://imgur.com/HZRgApE.png)

*screenshot by [JavaCafe01](https://github.com/JavaCafe01)*

#### Centered

![](https://media.discordapp.net/attachments/769673106842845194/780095998239834142/unknown.png)

*screenshot by [HeavyRain266](https://github.com/HeavyRain266)*

#### Equal area

![](https://imgur.com/JCFFywv.png)

*screenshot by [bysmutheye](https://github.com/bysmutheye)*

#### Deck

The left area shows the deck layout in action. In this screenshot it is used together with [layout machi](https://github.com/xinhaoyuan/layout-machi) and its sublayout support.

![](https://cdn.discordapp.com/attachments/635625954219261982/877957824225894430/unknown.png)

*screenshot by [JavaCafe01](https://github.com/JavaCafe01)*

