---@diagnostic disable: undefined-global, lowercase-global

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

require("awful.autofocus")
require("awful.hotkeys_popup.keys")

require("modules.initialize")
require("modules.variables")

require("modules.keymaps")
require("modules.rules")
require("modules.ui") -- and signals
