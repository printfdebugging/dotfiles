---@diagnostic disable: undefined-global, lowercase-global
local beautiful = require("beautiful")
local awful = require("awful")
local gears = require("gears")

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)

--  Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end

	local cairo = require("lgi").cairo
	local default_icon = "/home/printfdebugging/.config/awesome/theme/assets/icons8-bash-48.png"
	if c and c.valid and not c.icon then
		local s = gears.surface(default_icon)
		local img = cairo.ImageSurface.create(cairo.Format.ARGB32, s:get_width(), s:get_height())
		local cr = cairo.Context(img)
		cr:set_source_surface(s, 0, 0)
		cr:paint()
		c.icon = img._native
	end
end)

