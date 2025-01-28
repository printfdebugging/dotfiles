---@diagnostic disable: undefined-global, lowercase-global

local beautiful = require("beautiful")

terminal = "st"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"

function rrect(radius)
	return function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, radius)
	end
end

beautiful.border_radius = 0
beautiful.systray_icon_spacing = 4
-- beautiful.taglist_bg_empty = "#ff0000"
-- beautiful.taglist_bg_occupied = "#ff00ff"
beautiful.taglist_bg_focus = "#68E5FD20"
-- beautiful.taglist_bg_volatile = "#00000000"
-- beautiful.taglist_bg_urgent = "#00000000"
