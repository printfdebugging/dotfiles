local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")

-- local helpers = require("helpers") -- for later

local wibox_container = require("wibox.container")
local wibox_widget = require("wibox.widget")
local dpi = beautiful.xresources.apply_dpi

function rrect(radius)
	return function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, radius)
	end
end

local some_func = function(args)
	return wibox_widget({
		{
			args.widget,
			margins = args.margins or dpi(0),
			widget = wibox_container.margin,
		},
		shape = rrect(4),
		bg = "#11111b",
		widget = wibox_container.background,
	})
end

local modkey = "Mod4"

local client_filter = function(t)
	return function(c)
		for _, v in ipairs(c:tags()) do
			if v == t then
				return true
			end
		end
		return false
	end
end

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end)
	-- awful.button({ }, 3, function()
	--                          awful.menu.client_list({ theme = { width = 250 } })
	--                      end)
	-- awful.button({ }, 4, function ()
	--                          awful.client.focus.byidx(1)
	--                      end),
	-- awful.button({ }, 5, function ()
	--                          awful.client.focus.byidx(-1)
	--                      end))
)

local tasklist = function(t)
	local s = awful.screen.focused()
	return awful.widget.tasklist({
		screen = s,
		filter = client_filter(t),
		buttons = tasklist_buttons,
		layout = {
			spacing_widget = nil,
			spacing = 1,
			layout = wibox.layout.fixed.vertical,
		},
		widget_template = {
			nil,
			{
				{
					id = "clienticon",
					forced_width = dpi(24),
					widget = awful.widget.clienticon,
				},
				widget = wibox.container.place,
				margins = 0,
			},
			{
				id = "background_role",
				forced_height = dpi(0),
				widget = wibox.container.background,
			},
			create_callback = function(self, c, index, objects) --luacheck: no unused args
				self:get_children_by_id("clienticon")[1].client = c
			end,
			layout = wibox.layout.align.vertical,
		},
	})
end

local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

local grid_layout = wibox.layout({
	forced_num_cols = 2,
	forced_num_rows = 1,
	orientation = "vertical",
	expand = true,
	homogeneous = false,
	layout = wibox.layout.grid,
})

local function adjust_grid_layout(s)
	local screen = s or awful.screen.focused()
	local is_vertical = screen.geometry.height < screen.geometry.width
	if is_vertical then
		return
	end

	local num_tags = 0
	for _, t in ipairs(screen.tags) do
		if t.selected or #t:clients() > 0 then
			num_tags = num_tags + 1
		end
	end

	if num_tags >= 4 then
		grid_layout.forced_num_cols = 4
		grid_layout.forced_num_rows = 2
	else
		grid_layout.forced_num_cols = math.max(num_tags, 1)
		grid_layout.forced_num_rows = 1
	end
end

local function create_taglist_callback(self, t, index, _)
	self:get_children_by_id("tasklist_placeholder")[1]:add(tasklist(t))
	self:get_children_by_id("index_role")[1].text = t.index
	adjust_grid_layout(t.screen)
end

local taglist = function(s)
	local custom_taglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		style = {
			shape = rrect(4),
		},
		layout = wibox.layout.fixed.vertical,
		widget_template = {
			{
				{
					{
						{
							id = "index_role",
							font = beautiful.font,
							align = "center",
							widget = wibox.widget.textbox,
						},
						left = dpi(7),
						top = dpi(5),
						bottom = dpi(5),
						right = dpi(7),
						widget = wibox.container.margin,
					},
					-- tasklist
					{
						id = "tasklist_placeholder",
						layout = wibox.layout.fixed.vertical,
						widget = wibox.container.margin,
					},
					-- spacing = dpi(8),
					layout = wibox.layout.fixed.vertical,
				},
				widget = wibox.container.margin,
				layout = wibox.layout.align.vertical,
			},
			id = "background_role",
			widget = wibox.container.background,
			shape = rrect(2),
			create_callback = create_taglist_callback,
		},
		buttons = taglist_buttons,
	})

	-- Update column and row number if vertical screen
	if not is_horizontal then
		tag.connect_signal("property::selected", function()
			adjust_grid_layout()
		end)
	end

	return some_func({
		widget = custom_taglist,
		margins = 2,
	})
end

return taglist
