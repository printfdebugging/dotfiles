---@diagnostic disable: undefined-global, lowercase-global

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c, { size = 30 }):setup({
		{ -- Left
			{
				awful.titlebar.widget.iconwidget(c),
				buttons = buttons,
				layout = wibox.layout.fixed.horizontal,
			},

			top = 2,
			bottom = 2,
			left = 2,
			right = 2,
			widget = wibox.container.margin,
		},
		{ -- Middle
			{ -- Title
				align = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			{

				awful.titlebar.widget.floatingbutton(c),
				awful.titlebar.widget.maximizedbutton(c),
				awful.titlebar.widget.stickybutton(c),
				awful.titlebar.widget.ontopbutton(c),
				awful.titlebar.widget.closebutton(c),
				layout = wibox.layout.fixed.horizontal(),
			},
			top = 2,
			bottom = 2,
			left = 2,
			right = 2,
			widget = wibox.container.margin,
		},
		layout = wibox.layout.align.horizontal,
	})
end)
