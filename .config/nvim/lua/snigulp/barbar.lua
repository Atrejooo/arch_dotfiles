return {
	{
		"romgrk/barbar.nvim",
		dependencies = {
			"lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
			"nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
		},
		init = function()
			vim.g.barbar_auto_setup = false
		end,
		opts = {
			-- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
			animation = false,
			auto_hide = false,
			clickable = false,
			insert_at_end = true,
			-- insert_at_start = true,
			-- …etc.
			icons = {
				button = "",
				separator = { left = "[", right = "]" },
				separator_at_end = false,
				diagnostics = {
					enabled = true,
					[vim.diagnostic.severity.ERROR] = { enabled = true, icon = "E" },
					[vim.diagnostic.severity.WARN] = { enabled = false, icon = "W" },
					[vim.diagnostic.severity.INFO] = { enabled = false, icon = "I" },
					[vim.diagnostic.severity.HINT] = { enabled = true, icon = "H" },
				},
				modified = { button = "M" },
			},
			filetype = { enabled = false },
			maximum_padding = 1,
			minimum_padding = 1,
			-- highlight_visible = true,
		},
	},
}
