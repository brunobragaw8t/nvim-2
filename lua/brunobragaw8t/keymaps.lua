-- Map Space as Leader
vim.g.mapleader = " "

-- Don't yank on paste
vim.keymap.set("v", "p", '"_dP')

-- Clear search highlight on Escape
vim.keymap.set("n", "<Esc>", ":nohls<CR>", { silent = true })

-- Save with Ctrl+S
vim.keymap.set({"i", "n", "v", "x"}, "<C-s>", vim.cmd.write, { silent = true })

-- Move lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
