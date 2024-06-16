local dap = require("dap")
dap.adapters.delve = {
	type = "server",
	port = "${port}",
	executable = {
		command = "dlv",
		args = { "dap", "-l", "127.0.0.1:${port}" },
	},
}

-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
-- dap.configurations.go = {
-- 	{
-- 		type = "delve",
-- 		name = "Debug",
-- 		request = "launch",
-- 		program = "${file}",
-- 	},
-- 	{
-- 		type = "delve",
-- 		name = "Debug test", -- configuration for debugging test files
-- 		request = "launch",
-- 		mode = "test",
-- 		program = "${file}",
-- 	},
-- 	-- works with go.mod packages and sub packages
-- 	{
-- 		type = "delve",
-- 		name = "Debug test (go.mod)",
-- 		request = "launch",
-- 		mode = "test",
-- 		program = "./${relativeFileDirname}",
-- 	},
-- }
-- cpp
dap.adapters.gdb = {
	type = "executable",
	command = "gdb",
	args = { "-i", "dap" },
}

-- local VCL_PLUGIN = "-env:SAL_USE_VCLPLUGIN="
dap.configurations.cpp = {
	{
		name = "Launch",
		type = "gdb",
		request = "launch",
		program = function()
			if string.find(vim.fn.expand("%:p"), "libreoffice") then
				return "/home/printf/repos/libreoffice/instdir/program/soffice.bin"
			end
			-- return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
		end,

		-- args = function()
		-- 	return VCL_PLUGIN .. vim.fn.input("VCL: ")
		-- end,

		cwd = "${workspaceFolder}",

		stopAtBeginningOfMainSubprogram = false,
	},
}
dap.configurations.c = {
	{
		name = "Launch",
		type = "gdb",
		request = "launch",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopAtBeginningOfMainSubprogram = false,
	},
}
dap.configurations.lua = {
	{
		type = "nlua",
		request = "attach",
		name = "Attach to running Neovim instance",
	},
}
dap.configurations.lua = {
	{
		type = "nlua",
		request = "attach",
		name = "Attach to running Neovim instance",
	},
}

dap.adapters.nlua = function(callback, config)
	callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
end
