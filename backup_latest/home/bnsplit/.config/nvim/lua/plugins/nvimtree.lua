return {
  "nvim-tree/nvim-tree.lua",
  enabled = false,
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup({

      sort = {
        sorter = "case_sensitive",
      },
      view = {
        width = 50,
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = true,
      },
    })
  end,
}
