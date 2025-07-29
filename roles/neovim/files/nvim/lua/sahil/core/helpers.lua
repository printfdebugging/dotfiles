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
------------------------------------------------follow link----------------------------------------------------------
local fn = vim.fn
local cmd = vim.cmd
local loop = vim.loop
local tsUtil = require("nvim-treesitter.ts_utils")
local treesitter = require("vim.treesitter")

function string:startswith(start)
    return self:sub(1, #start) == start
end

local os_name = loop.os_uname().sysname
local is_windows = os_name:startswith("Windows")
local is_macos = os_name == "Darwin"
local is_linux = os_name == "Linux"

local function getLinkDestination()
	local nodeAtCursor = tsUtil.get_node_at_cursor()
	local parentNode = nodeAtCursor:parent()
	if not (nodeAtCursor and parentNode) then
		return
	elseif nodeAtCursor:type() == "word" and parentNode:type() == "taglink" then
		return vim.split(treesitter.get_node_text(nodeAtCursor, 0), "\n")[1]
	elseif nodeAtCursor:type() == "taglink" then
		local childNodes = tsUtil.get_named_children(nodeAtCursor)
		for _, node in pairs(childNodes) do
			if node:type() == "word" then
				return vim.split(treesitter.get_node_text(node, 0), "\n")[1]
			end
		end
	else
		return
	end
end

local function isProgrammingFiletype(link)
  local extensions = {
    ".txt", ".md", ".markdown", ".rst", ".org", ".norg", ".adoc", ".json", ".yaml", ".yml", ".toml", ".ini", ".conf",
    ".cfg", ".env", ".rc",
    ".html", ".htm", ".css", ".scss", ".sass", ".less", ".xml", ".xhtml", ".js", ".ts", ".jsx", ".tsx", ".mjs", ".cjs",
    ".py", ".pyi", ".lua", ".sh", ".bash", ".zsh", ".ksh", ".fish", ".tmux", ".pl", ".awk", ".sed", ".c", ".h", ".cpp",
    ".cxx", ".cc", ".hpp", ".hxx", ".hh", ".ino",
    ".java", ".kt", ".kts", ".scala", ".rs", ".go", ".cs", ".php", ".phtml", ".rb", ".erb", ".rake", ".gemspec", ".pl",
    ".pm", ".t", ".swift", ".m", ".mm", ".h",
    ".lisp", ".el", ".cl", ".scm", ".rkt", ".ss", ".sld", ".hs", ".lhs", ".ml", ".mli", ".fs", ".fsi", ".fsx",
    ".fsscript", ".asm", ".s", ".S", ".nasm",
    ".sql", ".pgsql", ".psql", ".tex", ".sty", ".cls", ".bib", ".make", ".mk", ".mak", ".cmake", "Makefile",
    "CMakeLists.txt", ".dockerfile", "Dockerfile",
    ".gitignore", ".gitattributes", ".editorconfig", ".vim", ".vimrc", ".nvim", ".tmux.conf", ".bashrc", ".zshrc", ".zprofile",
    ".aliases", ".pandoc", ".mdx",
  }
  link = link:lower()
  for _, ext in ipairs(extensions) do
    if link:sub(-#ext) == ext or link:match(ext .. "$") then
      return true
    end
  end
  return false
end

local function resolveLink(link)
	if link:sub(1, 8) == [[https://]] or link:sub(1, 7) == [[http://]] or not isProgrammingFiletype(link) then
		return link, "mime"
  elseif link:sub(-4) == ".txt" then
    return link, "wiki"
	else
    return link, "local"
	end
end

local function followLocalLink(link)
  cmd("edit " .. fn.fnameescape(link))
end

local function followWikiLink(link)
  local link = link or ""
  pcall(cmd, "helptags .")
  local ok = pcall(cmd, "tag " .. link)
  if ok then return end

  local sep = package.config:sub(1,1)
  local date = os.date("%Y" .. sep .. "%m")
  local tmpLink = date .. sep .. link

  if not tmpLink or tmpLink == "" then return end
  if fn.filereadable(tmpLink) == 0 then
    local dir = fn.fnamemodify(tmpLink, ":h")
    if fn.isdirectory(dir) == 0 then
      fn.mkdir(dir, "p")
    end
    local f = io.open(tmpLink, "w")
    if f then
      f:write("*" .. link .. "*\n\n\n")
      f:write('vim:tw=80:ts=4:sw=4:noet:ft=help:norl:\n')
      f:close()
    end
  end
  cmd("edit " .. fn.fnameescape(tmpLink))
end

function followLink()
	local linkDestination = getLinkDestination()
	if linkDestination then
		local resolvedLink, linkType = resolveLink(linkDestination)
		if linkType == "local" then
			followLocalLink(resolvedLink)
    elseif linkType == 'wiki' then
			followWikiLink(resolvedLink)
		elseif linkType == "mime" then
			if is_linux then
				vim.fn.system("xdg-open " .. vim.fn.shellescape(resolvedLink))
			elseif is_macos then
				vim.fn.system("open " .. vim.fn.shellescape(resolvedLink))
			elseif is_windows then
				vim.fn.system('cmd.exe /c start "" ' .. vim.fn.shellescape(resolvedLink))
			end
		end
	end
end

vim.keymap.set('n', '<leader>oo', followLink, { noremap = true, silent = true })
