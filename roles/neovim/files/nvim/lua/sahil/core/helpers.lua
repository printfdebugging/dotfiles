---@diagnostic disable-next-line: lowercase-global
function saveToReadmeFile()
	-- function to save the source code from codefile to a readme
	local file_extension = vim.fn.expand("%:e")
	-- if file_extension == "md" or file_extension == "go" then -- don't touch markdown files
	-- 	return
	-- end
	local sourceFile = vim.fn.expand("%") -- full file path
	local tailFilename = vim.fn.expand("%:t")
	local readmeFile = "/home/printfdebugging/repos/files/sourcecode.md"
	--[[ string.gsub(sourceFile, tailFilename, "readme.md") ]]
	vim.cmd("!echo '```" .. file_extension .. "' >> " .. readmeFile)
	vim.cmd("!cat " .. sourceFile .. " >> " .. readmeFile)
	vim.cmd("!echo '```' >> " .. readmeFile)
	vim.cmd("!echo '' > %")
end

function ExecuteCurrentFileProgram()
	local file_extension = vim.fn.expand("%:e")

	if file_extension == "cpp" then
		vim.cmd(
			"!g++ -std=c++20 -Wall -Weffc++ -Wextra -Wconversion -Wsign-conversion -Wshadow -pedantic-errors  % -o exe && ./exe"
		)
	elseif file_extension == "c" then
		vim.cmd("!gcc -Wall -Wextra -Wconversion -Wsign-conversion -Wshadow -pedantic-errors  % -o exe && ./exe")
	elseif file_extension == "cxx" then
		vim.cmd(
			"!g++ -std=c++20 -Wall -Weffc++ -Wextra -Wconversion -Wsign-conversion -Wshadow -pedantic-errors  % -o exe && ./exe"
		)
	elseif file_extension == "py" then
		vim.cmd("!python %")
	elseif file_extension == "lua" then
		vim.cmd("!lua %")
	elseif file_extension == "go" then
		vim.cmd("!go run .")
	elseif file_extension == "sh" then
		vim.cmd("!sh %")
	elseif file_extension == "js" then
		vim.cmd("!node %")
	elseif file_extension == "yaml" then
		vim.cmd("!yaml-parser %")
	elseif file_extension == "yml" then
		vim.cmd("!yaml-parser %")
	elseif file_extension == "md" then
		vim.cmd(":MdEval")
	elseif file_extension == "java" then
		-- get the filename
		local filename = vim.fn.expand("%:t")
		-- replace extension with "" for java
		local bytecode = string.gsub(filename, ".java", "")
		-- execute and cleanup
		vim.cmd("!cd code/ && javac %:t && java " .. bytecode .. " && rm *.class")
	else
		print("Unsupported file type")
	end
end



-- multigrep
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

local telescope = require("telescope.builtin")
function G_telescope_resume()
	if G_telescope_last == 0 then
		G_telescope_last = 1
    live_multigrep()
	else
		telescope.resume()
	end
end

local function show_man_page()
  local name = vim.fn.input("man: ")
  if name == "" then return end
  local ok = pcall(vim.cmd, "Man 3p " .. name)
  if ok then return end;
  pcall(vim.cmd, "Man " .. name)
end

vim.keymap.set('n', '<leader>fm', show_man_page, { noremap = true, silent = true })
