return {
  "williamboman/mason.nvim",
  opts = {
    ensure_installed = {
      -- For shell scripts
      "bash-language-server",
      "shellharden",
      "shellcheck",

      -- HTML CSS
      "html-lsp",
      "css-lsp",

      -- Rust
      "bacon",
      "rust-analyzer",
      "ast-grep",
    },
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗",
      },
      border = "rounded",
    },
  },
}
