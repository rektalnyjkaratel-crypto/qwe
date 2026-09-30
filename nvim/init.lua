vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.wrap = false
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.splitbelow = true
opt.splitright = true
opt.undofile = true
opt.swapfile = false
opt.signcolumn = "auto:1-2"
opt.scrolloff = 5
opt.updatetime = 300
opt.timeoutlen = 1500
opt.ttimeoutlen = 50
-- Match Solarized Dark in the terminal, with distinct syntax colors.
opt.termguicolors = true
opt.background = "dark"
vim.cmd.colorscheme("solarized")
opt.laststatus = 3
opt.statusline = " %f %m%r%=%y  %l:%c  %p%% "

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = -28
vim.g.netrw_altv = 0
vim.g.netrw_browse_split = 0

-- Diagnostics stay quiet until requested with <space>d or [d / ]d.
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = true },
})

local map = vim.keymap.set
local function open_explorer()
  vim.cmd("Lexplore! " .. vim.fn.fnameescape(require("config.project").root()))
end

map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Diagnostic under cursor" })
map("n", "<leader>e", open_explorer, { desc = "Explorer right" })
map("n", "<leader>cL", function() require("config.info").lsp() end, { desc = "Show buffer LSP clients" })
map("n", "<leader>cF", function() require("config.info").formatters() end, { desc = "Show buffer formatters" })
map("n", "<leader>tt", "<cmd>botright 12split | terminal<cr>", { desc = "Terminal" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Leave terminal mode" })

require("config.lazy")

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserTestMarks", { clear = true }),
  pattern = { "go", "javascript", "javascriptreact", "typescript", "typescriptreact", "svelte", "php", "lua", "python", "rust" },
  callback = function(event) require("config.test_marks").attach(event.buf) end,
})
