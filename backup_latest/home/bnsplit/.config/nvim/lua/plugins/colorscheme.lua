return {
  {
    "BnSplits/tokyogruv.nvim",
    opts = {
      gamma = 0.9,
      terminal_colors = true,
      transparent_background = false,
    },
  },

  {
    "tiagovla/tokyodark.nvim",
    opts = {
      gamma = 0.9,
      terminal_colors = true,
      transparent_background = false,
    },
  },
  {
    "navarasu/onedark.nvim",
    opts = {
      style = "darker",
      transparent = false,
      term_colors = true,
      lualine = {
        transparent = false,
      },
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      term_colors = true,
      transparent_background = false,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = true,
        mini = {
          enabled = true,
          indentscope_color = "",
        },
      },
    },
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      styles = {
        bold = true,
        italic = true,
        transparency = false,
      },
    },
  },
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = true,
    opts = {
      terminal_colors = true,
      undercurl = true,
      underline = true,
      bold = true,
      italic = {
        strings = true,
        emphasis = true,
        comments = true,
        operators = false,
        folds = true,
      },
      strikethrough = true,
      invert_selection = false,
      invert_signs = false,
      invert_tabline = false,
      invert_intend_guides = false,
      inverse = false,
      contrast = "hard",
      palette_overrides = {},
      overrides = {},
      dim_inactive = false,
      transparent_mode = false,
    },
  },
  -- Set colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyogruv",
    },
  },
}
