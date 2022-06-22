package = "color"
version = "1.1-1"
source = {
   url = "git+https://github.com/andOrlando/color.git"
}
description = {
   detailed = [[
Allows for easy access to rgba, hsla or hex by only defining one of them as well as efficient computation of other values when one changes. It also has a couple useful color conversion methods like hex_to_rgba, rgba_to_hex, rgb_to_hsl and hsl_to_rgb and the class uses those methods to calculate the other values when one value updates.

The main color class itself contains h, s, l, r, g, b and hex values which, when one is updated, updates all the others (but it only does it when the values are needed, ensuring no more calculations than necessary)

There's a better description in the github's README
   ]],
   homepage = "https://github.com/andOrlando/color",
   license = "MIT"
}
build = {
   type = "builtin",
   modules = {
      color = "color.lua"
   }
}
