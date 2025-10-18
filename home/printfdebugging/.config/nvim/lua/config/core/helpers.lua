----------------------------------------------------------------------
-- MIT License
-- Copyright (c) 2025 Sahil Gautam <printfdebugging@gmail.com>
-- See LICENSE file in the project root for
----------------------------------------------------------------------

local M = {}

local function live_multigrep(opts)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local make_entry = require("telescope.make_entry")
  local conf = require("telescope.config").values

  opts = opts or {}
  opts.cwd = opts.cwd or vim.uv.cwd()
  local finder = finders.new_async_job({
    command_generator = function(prompt)
      if not prompt or prompt == "" then
        return nil
      end

      local pieces = vim.split(prompt, "  ")
      local args = { "rg" }
      if pieces[1] then
        table.insert(args, "-e")
        table.insert(args, pieces[1])
      end

      if pieces[2] then
        table.insert(args, "-g")
        table.insert(args, pieces[2])
      end
      return vim.tbl_flatten({
        args,
        { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" },
      })
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  })

  pickers
    .new(opts, {
      debounce = 100,
      prompt_title = "Multi Grep",
      finder = finder,
      previewer = conf.grep_previewer(opts),
      sorter = require("telescope.sorters").empty(),
    })
    :find()
end




telescope_last = 0
function M.telescope_resume()
  if telescope_last == 0 then
    telescope_last = 1
    live_multigrep()
  else
    require("telescope.builtin").resume()
  end
end




function M.show_man_page()
  local name = vim.fn.input("man: ")
  if
      name == "" or
      pcall(vim.cmd, "tab Man 3p" .. name) or
      pcall(vim.cmd, "tab Man " .. name) then
    return
  end
end




function M.man_or_hover_doc()
  local word_under_cursor = vim.fn.expand("<cword>")
  if
      word_under_cursor == "" or
      pcall(vim.cmd, "tab Man 3p" .. word_under_cursor) or
      pcall(vim.cmd, "tab Man " .. word_under_cursor) or
      vim.cmd("Lspsaga hover_doc")
  then
    return
  end
end




function M.custom_tabclose()
  if vim.fn.tabpagenr() == 1 then
    print("You cannot close the first tab!")
  else
    vim.cmd("tabclose")
  end
end




function M.follow_wiki_link()
  local word = vim.fn.expand("<cword>")
  if word == nil then
    print("word under cursor nil")
    return
  end


  local ok = pcall(vim.cmd, "helptags .")
  if not ok then
    print("helptags failed ")
    return
  end


  ok = pcall(vim.cmd, "tag " .. word)
  if ok then
    print("found tag " .. word)
    return
  end

  local sep = package.config:sub(1, 1)
  local date = os.date("%Y" .. sep .. "%m")
  local path = date .. sep .. word

  if vim.fn.filereadable(path) == 0 then
    local dir = vim.fn.fnamemodify(path, ":h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end

    local file = io.open(path, "w")
    if file then
      file:write("----------------------------------------------------------------------\n")
      file:write("*" .. word .. "*\n\n\n")
      file:write("vim:tw=70:ts=4:sw=4:et:ft=help:norl:iskeyword+=-,.:")
      file:close()
    end
  end

  vim.cmd("edit " .. vim.fn.fnameescape(path))
end




function M.build_project()
  local pwd = vim.fn.getcwd()
  if vim.uv.fs_stat(pwd .. "/Makefile") or vim.uv.fs_stat(pwd .. "/makefile") then
    vim.cmd([[
      :cgetexpr systemlist('make')
      :copen
    ]])
  elseif vim.uv.fs_stat(pwd .. "/CMakeLists.txt") then
    vim.cmd([[
      :cgetexpr systemlist('cmake -B build && make -C build')
      :copen
    ]])
  else
    print("ERROR: neither Makefile nor CMakeLists.txt found")
  end
end



function M.run_project()
  local pwd = vim.fn.getcwd()
  if vim.uv.fs_stat(pwd .. "/Makefile") or vim.uv.fs_stat(pwd .. "/makefile") then
    vim.cmd([[
      :cgetexpr systemlist('make run')
      :copen
      ]])
  elseif vim.uv.fs_stat(pwd .. "/CMakeLists.txt") then
    vim.cmd([[
      :cgetexpr systemlist('make -C build run')
      :copen
      ]])
  else
    print("ERROR: neither Makefile nor CMakeLists.txt found")
  end
end


function M.clean_project()
  local pwd = vim.fn.getcwd()
  if vim.uv.fs_stat(pwd .. "/Makefile") or vim.uv.fs_stat(pwd .. "/makefile") then
    vim.cmd([[
      :cgetexpr systemlist('make clean')
      :copen
      ]])
  elseif vim.uv.fs_stat(pwd .. "/CMakeLists.txt") then
    vim.cmd([[
      :cgetexpr systemlist('rm -rf build')
      :copen
      ]])
  else
    print("ERROR: neither Makefile nor CMakeLists.txt found")
  end
end



return M
