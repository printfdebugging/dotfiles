---@diagnostic disable-next-line: lowercase-global
function saveToReadmeFile()
	-- function to save the source code from codefile to a readme
	local file_extension = vim.fn.expand("%:e")
	-- if file_extension == "md" or file_extension == "go" then -- don't touch markdown files
	-- 	return
	-- end
	local sourceFile = vim.fn.expand("%") -- full file path
	local tailFilename = vim.fn.expand("%:t")
	local readmeFile = "/home/printf/repos/files/sourcecode.md"
	--[[ string.gsub(sourceFile, tailFilename, "readme.md") ]]
	vim.cmd("!echo '```" .. file_extension .. "' >> " .. readmeFile)
	vim.cmd("!cat " .. sourceFile .. " >> " .. readmeFile)
	vim.cmd("!echo '```' >> " .. readmeFile)
	vim.cmd("!echo '' > %")
end

---@diagnostic disable-next-line: lowercase-global
function today()
	-- Check if tmp file exists in the notes directory
	local notes_dir = "/home/sahil/files/notes"
	local tmp_file = notes_dir .. "/tmp"

	local test = io.open(tmp_file, "r")
	if test == nil then
		return
	end

	local date_today = os.date("%Y.%m.%d")
	local entry_name = notes_dir .. "/" .. date_today .. ".md"

	test = io.open(entry_name, "r")
	if test == nil then
		-- File doesn't exist (then create the file)
		test = io.open(entry_name, "w")
		if test ~= nil then
			test:close()
		else
			print("Error creating file: " .. entry_name)
			return
		end
	end

	-- Open the file in Neovim
	local nvim_command = string.format("e %s", entry_name)
	vim.cmd(nvim_command)
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

local telescope = require("telescope.builtin")
function G_telescope_resume()
	if G_telescope_last == 0 then
		G_telescope_last = 1
		telescope.live_grep()
	else
		telescope.resume()
	end
end
