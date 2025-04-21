-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>bq", "<CMD>quit<CR>", { desc = "Quit focused buffer" })
vim.keymap.set("n", "<leader>\\", "<CMD>split<CR>", { desc = "Split Window Below" })

-- <leader>k - Run in kitty with persistent window
vim.keymap.set({ "n", "v" }, "<leader>k", function()
  local current_file = vim.api.nvim_buf_get_name(0)
  local cmd = string.format(
    'kitty --class float-nvim-runner sh -c \'~/.config/bnsplit/scripts/code_run.sh "%s"; echo; echo -n "Press enter to exit... "; read -n 1 -s -r && exit || echo; echo -n "Command failed (status $?). Press enter to exit... "; read -n 1 -s -r && exit\' &',
    current_file:gsub("'", "'\\''")
  )
  vim.fn.system(cmd)
end, {
  desc = "Run code in kitty with code_runner",
  silent = true,
  noremap = true,
})

-- - - Launch Oil in a floating panel
vim.keymap.set("n", "-", "<CMD>Oil --float<CR>", { desc = "Open oil" })

-- <C-t> - Toggle main terminal
vim.keymap.set({ "n", "v", "t" }, "<C-t>", "<cmd>1ToggleTerm direction=float name=Main <cr>", {
  desc = "Toggle main terminal",
  silent = true,
  noremap = true,
})

-- <leader>uC - Colorscheme selector with snacks (Rebind)
vim.keymap.set(
  { "n", "v" },
  "<leader>uC",
  "<cmd> lua Snacks.picker.colorschemes() <CR>",
  { desc = "Colorscheme with Preview" }
)

-- <leader>_ - Launch snacks filepicker
vim.keymap.set({ "n", "v" }, "<leader>_", function()
  Snacks.picker.files()
end, { desc = "Find Files (CWD)" })

-- Toggle Dashboard
-- vim.keymap.set(
--   "n",
--   "<leader>;",
--   [[
--   :lua if vim.bo.filetype ~= "snacks_dashboard" then Snacks.dashboard() end<CR>
-- ]],
--   { noremap = true, silent = true }
-- )
