# UPower Battery Widget

This is my re-implementation of the [awesome-upower-battery][awesome-upower-battery-repository] by [berlam][berlam]. This widget has a lot of potencial for the [Awesome WM][AwesomeWM] and I wanted to hack it a bit for my personal use.

UPower is an abstraction for power devices. You can use it to access advanced statistics about your power devices.
UPowerGlib is a Glib interface to access data exposed by UPower.
The Awesome WM uses LGI as an interpolation layer for Glib with Lua. So, you can access the UPowerGlib interface directly from your lua code.

Thanks to this, we can write battery widget relaying on realtime data pushed from the UPower daemon itself. So the battery widget as no charge on the system (no need to pull data every X seconds) and provides more accurate data to the user.

## Usage

When creating an instance of this widget, you can specify the `widget_template` you want to use and how the widget updates. It gives you the control on how the widget should display the battery status.

You can generate the API documentation with [ldoc][ldoc].

```sh
ldoc -c config.ld init.lua
```

Here is an example of implementation using a [`wibox.widget.textbox`][awesome-api-wibox.widget.textbox] widget to display the battery percentage:

```lua
-- Load the module:
local battery_widget = require 'battery_widget'

-- Create the battery widget:
local my_battery_widget = battery_widget {
    screen = screen,
    use_display_device = true,
    widget_template = wibox.widget.textbox
}

-- When UPower updates the battery status, the widget is notified
-- and calls a signal you need to connect to:
my_battery_widget:connect_signal('upower::update', function (widget, device)
    widget.text = string.format('%3d', device.percentage) .. '%'
end)
```

### Using different devices

With the parameter `use_display_device = true`, the battery widget will automatically monitor the _display device_.

If you want to manually set which device to monitor, you can use the `device_path` parameter.

```lua
local my_battery_widget = battery_widget{
    screen = s,
    device_path = '/org/freedesktop/UPower/devices/battery_BAT0',
    widget_template = wibox.widget.textbox
}
```

You can check the API documentation to read more about statics function to help you to identify your devices.

### Battery widget not appearing

When creating a new instance of `battery_widget`, the widget will not be shown. The widget waits an update from UPower to call the "upower::update" signal and use your attached callback to update (and draw) the widget.

You can however use one of the following method to force the widget to be drawn at its creation:

* Use the parameter `instant_update` to explicitly ask the battery_widget to call the "upower::update" signal at the next Awesome WM cycle.
* Use the parameter `create_callback` to use your own code to initialize the widget. (This callback await the same arguments than the "upower::update" signal)

You can read more about these parameters in the API documentation.

## Dependencies

* [Awesome WM][AwesomeWM]
* [UPower][UPower]
* [UPowerGlib][UPowerGlib]

## Acknowledgment

Thanks a lot to [berlam][berlam] for the initial code and the idea to use the UPowerGlib interface 🚀.

[awesome-upower-battery-repository]: https://github.com/berlam/awesome-upower-battery
[berlam]: https://github.com/berlam
[AwesomeWM]: https://awesomewm.org/
[awesome-api-wibox.widget.textbox]: https://awesomewm.org/apidoc/widgets/wibox.widget.textbox.html
[UPower]: https://upower.freedesktop.org/
[UPowerGlib]: https://lazka.github.io/pgi-docs/UPowerGlib-1.0/index.html
[ldoc]: https://stevedonovan.github.io/ldoc/
