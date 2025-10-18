----------------------------------------------------------------------
-- MIT License
-- Copyright (c) 2025 Sahil Gautam <printfdebugging@gmail.com>
-- See LICENSE file in the project root for
----------------------------------------------------------------------

vim.deprecate = function() end

require("config.core.options")
require("config.lazy")
require("config.core.keymaps")
require("config.core.autocmds")
