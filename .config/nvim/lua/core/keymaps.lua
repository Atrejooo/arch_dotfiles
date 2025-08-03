----------------------
--- FIND STUFF YAY ---
----------------------
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[f]ind [h]elp" })
vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[f]ind [k]eymaps" })
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[f]ind [f]iles" })
vim.keymap.set("n", "<leader>fs", builtin.builtin, { desc = "[f]ind [s]elect Telescope" })
vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[f]ind current [w]ord" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[f]ind by [g]rep" })
vim.keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = '[f]ind recent files ("." for repeat)' })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[f]ind existing [b]uffers" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[f]ind existing [b]uffers" })
vim.keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", {
	desc = "[f]ind [t]odos",
})
-- Git (requires fugitive or similar)
vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "[g]it [c]ommits" })
vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "[g]it [s]tatus" })

-- Slightly advanced example of overriding default behavior and theme
vim.keymap.set("n", "<leader>/", function()
	-- You can pass additional configuration to Telescope to change the theme, layout, etc.
	builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		previewer = false,
	}))
end, { desc = "[/] fuzzily find in buffer" })

-- It's also possible to pass additional configuration options.
--  See `:help telescope.builtin.live_grep()` for information about particular keys
vim.keymap.set("n", "<leader>f/", function()
	builtin.live_grep({
		grep_open_files = true,
		prompt_title = "Live Grep in Open Files",
	})
end, { desc = "[f]ind [/] in Open Files" })

----------------------
--- WINDOW CONTROL ---
----------------------
vim.keymap.set("n", "<leader>W", "<C-w>", { desc = "[W]indow stuff" })

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

----------------------
--- BUFFER CONTROL ---
----------------------
-- Switch to previous/next buffer (native nvim)
vim.keymap.set("n", "H", "<cmd>bprevious<cr>", { desc = "previous buffer" })
vim.keymap.set("n", "L", "<cmd>bnext<cr>", { desc = "next buffer" })
vim.keymap.set("n", "<leader>bh", "<cmd>bprevious<cr>", { desc = "[h] previous buffer" })
vim.keymap.set("n", "<leader>bl", "<cmd>bnext<cr>", { desc = "[l] next buffer" })
-- vim.keymap.set("n", "H", "<cmd>BufferPrevious<cr>", { desc = "previous buffer" })
-- vim.keymap.set("n", "L", "<cmd>BufferNext<cr>", { desc = "next buffer" })
-- vim.keymap.set("n", "<leader>bh", "<cmd>BufferPrevious<cr>", { desc = "[h] previous buffer" })
-- vim.keymap.set("n", "<leader>bl", "<cmd>BufferNext<cr>", { desc = "[l] next buffer" })

-- Buffer deletion
vim.keymap.set("n", "<leader>bdd", "<cmd>bd<cr>", { desc = "[d]elete this buffer" })
vim.keymap.set("n", "<leader>bdo", function()
	local current = vim.fn.bufnr()
	for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
		if buf.bufnr ~= current then
			vim.cmd("bd " .. buf.bufnr)
		end
	end
end, { desc = "[d]elete [o]ther buffers" })

-- write all buffers
vim.keymap.set("n", "<leader>bw", function()
	local count = 0
	local buffers = vim.fn.getbufinfo({ buflisted = 1 })

	for _, buf in ipairs(buffers) do
		if buf.changed == 1 then
			-- Switch to the buffer temporarily to write it
			vim.api.nvim_buf_call(buf.bufnr, function()
				vim.cmd("silent write!")
			end)
			count = count + 1
		end
	end

	if count > 0 then
		vim.notify("Written " .. count .. " buffer" .. (count == 1 and "" or "s"), vim.log.levels.INFO)
	else
		vim.notify("No buffers needed writing", vim.log.levels.INFO)
	end
end, { desc = "[b]uffers [w]rite all" })

-- write buffer
vim.keymap.set("n", "<leader>w", ":write<CR>", { desc = "[w]rite" })

---------------
--- TOGGELS ---
---------------
-- Toggle tabline
vim.keymap.set("n", "<leader>tt", function()
	local new_state = vim.opt.showtabline:get() == 0 and 2 or 0
	vim.opt.showtabline = new_state
	vim.notify("Tabline " .. (new_state == 2 and "SHOWN" or "HIDDEN"))
end, { desc = "[t]oggle [t]abline" })

-- Toggle LSP progress notifications (bottom-right popups)
local lsp_progress_enabled = true
-- Function to toggle LSP progress messages
local toggle_lsp_progress = function()
	lsp_progress_enabled = not lsp_progress_enabled
	if lsp_progress_enabled then
		-- Restore default progress handler
		vim.lsp.handlers["$/progress"] = vim.lsp.with(vim.lsp.handlers["$/progress"], {})
		print("LSP progress notifications: ON")
	else
		-- Disable progress notifications by overriding the handler
		vim.lsp.handlers["$/progress"] = function() end
		print("LSP progress notifications: OFF")
	end
end
-- Keybind to toggle
vim.keymap.set("n", "<leader>tl", toggle_lsp_progress, { desc = "[t]oggle [L]SP notifications" })

-- toggels comments
vim.keymap.set({ "n", "v" }, "<leader>tc", "gcc", { remap = true, desc = "[t]oggle line [c]omment" })
vim.keymap.set({ "n", "v" }, "<leader>cc", "gcc", { remap = true, desc = "[c]ode toggle [c]omment" })

-- toggel wrapping
vim.keymap.set("n", "<leader>tw", function()
	vim.wo.wrap = not vim.wo.wrap
	if vim.wo.wrap then
		print("Line wrapping enabled")
	else
		print("Line wrapping disabled")
	end
end, { desc = "[t]oggle line [w]rapping" })

---------------
--- GENERAL ---
---------------
-- Clear search highlights when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

vim.keymap.set("n", "<Leader>e", function()
	MiniFiles.open()
end, { desc = "[e]xplorer" })

--WARN code/lsp related keymaps are located under lsp.lua !!!
