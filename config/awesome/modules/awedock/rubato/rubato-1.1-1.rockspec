package = "rubato"
version = "1.1-1"
source = {
   url = "git+https://github.com/andOrlando/rubato.git"
}
description = {
   detailed = [[
Create smooth animations based off of a slope curve for near perfect interruptions. Similar to awestore, but solely dedicated to interpolation. Also has a cool name. Check out the README on github for more informaiton. Has (basically) complete compatibility with awestore.

Requires either gears or to be ran from awesomeWM
]],
   homepage = "https://github.com/andOrlando/rubato",
   license = "MIT"
}
dependencies = {
   "gears"
}
build = {
   type = "builtin",
   modules = {
      easing = "easing.lua",
      timed = "timed.lua",
	  subscribable = "subscribable.lua"
   }
}
