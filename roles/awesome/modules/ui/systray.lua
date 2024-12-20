local awful_screen = require("awful.screen")
local only_on_screen = require("awful.widget.only_on_screen")
local beautiful = require("beautiful")
local wibox_container = require("wibox.container")
local wibox_widget = require("wibox.widget")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi
local wibox = require("wibox")

local focused_screen = awful_screen.focused({
	mouse = true,
})

local tray = wibox_widget({
	base_size = 24,
	horizontal = true,
	screen = focused_screen,
	widget = wibox_widget.systray,
})

function rrect(radius)
	return function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, radius)
	end
end

local systray = wibox_widget({
	{
		{
			{
				tray,
				margins = dpi(1),
				layout = wibox.layout.align.horizontal,
				widget = wibox_container.margin,
			},
			widget = wibox_container.place,
		},
		id = "background",
		-- shape = rrect(beautiful.border_radius),
		widget = wibox_container.background,
	},
	screen = focused_screen,
	widget = only_on_screen,
})

systray:connect_signal("mouse::enter", function()
	systray.background.bg = beautiful.focus
	beautiful.bg_systray = beautiful.focus
end)

systray:connect_signal("mouse::leave", function()
	systray.background.bg = beautiful.transparent
	beautiful.bg_systray = beautiful.wibar_bg
end)

client.connect_signal("focus", function()
	local focused_screen = awful_screen.focused()
	beautiful.systray_max_rows = 9
	tray.base_size = 24

	tray.screen = focused_screen
	systray.screen = focused_screen
end)

return {
	systray,
	left = dpi(4),
	right = dpi(10),
	widget = wibox_container.margin,
	-- margins = dpi(4),
}
