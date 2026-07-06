-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- ─── IDE-like shortcuts ───

-- Ctrl+S: Save
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Ctrl+A: Select all
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select all" })

-- Ctrl+F: Find in current buffer
vim.keymap.set("n", "<C-f>", function()
  Snacks.picker.lines()
end, { desc = "Find in file" })

-- Ctrl+H: Find and replace in file
vim.keymap.set("n", "<C-h>", ":%s/", { desc = "Find and replace" })

-- Ctrl+Z: Undo (insert mode)
vim.keymap.set("i", "<C-z>", "<C-o>u", { desc = "Undo" })

-- Ctrl+/: Toggle comment (normal and visual)
vim.keymap.set({ "n", "v" }, "<C-/>", "gcc", { desc = "Toggle comment", remap = true })
vim.keymap.set({ "n", "v" }, "<C-_>", "gcc", { desc = "Toggle comment", remap = true })

-- Ctrl+C: Copy to system clipboard (visual)
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy to clipboard" })

-- Ctrl+X: Cut to system clipboard (visual)
vim.keymap.set("v", "<C-x>", '"+d', { desc = "Cut to clipboard" })

-- Ctrl+V: Paste from system clipboard (insert and normal)
vim.keymap.set({ "n", "i" }, "<C-v>", '<C-r>+', { desc = "Paste from clipboard" })

-- Ctrl+D: Duplicate current line
vim.keymap.set("n", "<C-S-d>", "yyp", { desc = "Duplicate line" })
vim.keymap.set("v", "<C-S-d>", "y`>pgv", { desc = "Duplicate selection" })
