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

local telescope = require("telescope.builtin")
function G_telescope_resume()
	if G_telescope_last == 0 then
		G_telescope_last = 1
		telescope.live_grep()
	else
		telescope.resume()
	end
end
