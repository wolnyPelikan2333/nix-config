-- Core keymaps
-- Add mappings only when you actually use them

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- intentionally empty for now

-- fzf-lua
map("n", "<leader>f", "<cmd>FzfLua files<cr>", opts)   -- pliki
map("n", "<leader>g", "<cmd>FzfLua live_grep<cr>", opts) -- grep
map("n", "<leader>b", "<cmd>FzfLua buffers<cr>", opts) -- bufory

