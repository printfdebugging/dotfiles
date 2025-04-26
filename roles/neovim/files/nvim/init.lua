require("sahil.core")
require("sahil.lazy")
require("sahil.core.keymaps")
require("sahil.core.autocmds")

local orig_notify = vim.notify

local filter_notify = function(text, level, opts)
  if type(text) == "string" and string.find(text, ":checkhealth", 1, true) then
    return
  end

  orig_notify(text, level, opts)
end

vim.notify = filter_notify
