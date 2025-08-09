-- telescope multigrep
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local conf = require"telescope.config".values

local live_multigrep = function(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or vim.uv.cwd()
  local finder = finders.new_async_job({
    command_generator = function(prompt)
      if not prompt or prompt == "" then
        return nil
      end

      local pieces = vim.split(prompt, "  ")
      local args = { 'rg' }
      if pieces[1] then
        table.insert(args, '-e')
        table.insert(args, pieces[1])
      end

      if pieces[2] then
        table.insert(args, '-g')
        table.insert(args, pieces[2])
      end
      return vim.tbl_flatten {
        args,
        { '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case' }
      }
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  })

  pickers.new(opts, {
    debounce = 100,
    prompt_title = "Multi Grep",
    finder = finder,
    previewer = conf.grep_previewer(opts),
    sorter = require"telescope.sorters".empty(),
  }):find()
end


-- resume the last string search
local builtin = require "telescope.builtin"
function telescope_resume()
	if G_telescope_last == 0 then
		G_telescope_last = 1
    live_multigrep()
	else
    builtin.resume()
	end
end
G_telescope_last = 0


-- prefer man(3) pages
function show_man_page()
  local name = vim.fn.input("man: ")
  if name == "" then return end
  local ok = pcall(vim.cmd, "Man 3p " .. name)
  if ok then return end;
  pcall(vim.cmd, "Man " .. name)
end


-- don't close the first tab
function custom_tabclose()
	if vim.fn.tabpagenr() == 1 then
		print("You cannot close the first tab!")
	else
		vim.cmd("tabclose")
	end
end

