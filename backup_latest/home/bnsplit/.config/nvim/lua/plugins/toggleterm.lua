return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      shell = "zsh",
      start_in_insert = true,
      float_opts = {
        border = "curved",
        title_pos = "left",
      },
      direction = "float",
      autochdir = true,
      shade_terminals = false,
    })
  end,
}
