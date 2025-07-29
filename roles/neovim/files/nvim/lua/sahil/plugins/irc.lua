return {
  'shadmansaleh/IRC.nvim',
  rocks = 'openssl',
  config = function()
    require 'irc'.setup({
      servers = {
        libera = {
          nick = 'printfdebuggings',
          username = 'printfdebuggings',
          server = 'irc.libera.chat',
          port = 6667,
          use_ssl = false,
        },
      },
      statusline = true,
    })
  end,
}
