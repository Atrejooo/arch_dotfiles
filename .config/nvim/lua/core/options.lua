-- Enable line numbers and relative line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Indentation
vim.opt.tabstop = 2 -- 1 tab = 4 spaces
vim.opt.shiftwidth = 2 -- Auto-indent uses 4 spaces
vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.smartindent = true

-- Line wrapping
vim.opt.wrap = false -- Disable line wrapping
vim.opt.linebreak = true -- Wrap at word boundaries (if wrap is enabled)

-- Search
vim.opt.ignorecase = true -- Case-insensitive search
vim.opt.smartcase = true -- Case-sensitive if search contains uppercase
vim.opt.hlsearch = true -- Highlight search results
vim.opt.incsearch = true -- Show matches while typing

-- Appearance
vim.opt.termguicolors = true -- Enable 24-bit RGB colors
vim.opt.signcolumn = "yes" -- Always show signcolumn (for LSP, git, etc.)
vim.opt.cursorline = false -- Highlight current line
vim.opt.scrolloff = 8 -- Keep 8 lines above/below cursor
vim.opt.sidescrolloff = 8 -- Keep 8 columns beside cursor

-- Behavior
vim.opt.mouse = "a" -- Enable mouse in all modes
vim.opt.clipboard = "unnamedplus" -- Sync with system clipboard
vim.opt.swapfile = false -- Disable swap files
vim.opt.undofile = true -- Persistent undo history
-- vim.opt.updatetime = 250     -- Faster completion (default 4000ms)
-- vim.opt.timeoutlen = 300     -- Timeout for key sequences (e.g., which-key)

-- Gloabal
vim.g.mapleader = " " --leader

-- custom tabline code in core/tabliny.lua
vim.opt.showtabline = 2

vim.api.nvim_set_var("float_border", {
	{ "+", "-", "+" },
	{ "|", " ", "|" },
	{ "+", "-", "+" },
})
