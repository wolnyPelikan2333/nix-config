-- Core editor options
-- Keep this file boring and predictable

-- UI
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.termguicolors = true

-- Editing
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.smartindent = true

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true

-- UX / performance
vim.o.updatetime = 300
vim.o.timeoutlen = 500

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.opt.number = true
    vim.opt.relativenumber = true
  end,
})

