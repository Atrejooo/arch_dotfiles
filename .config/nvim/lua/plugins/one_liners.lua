return {
	{ "nvim-tree/nvim-web-devicons" },
	{
		"brenoprata10/nvim-highlight-colors",
		config = function()
			require("nvim-highlight-colors").setup({
				---@usage 'background'|'foreground'|'virtual'
				render = "background",
			})
			require("nvim-highlight-colors").turnOn()
		end,
	},

	{ "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

	{ "tjdevries/colorbuddy.nvim" },

	-- Highlight TODO:, notes, etc in comments
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			-- * after: highlights after the keyword (todo text)
			highlight = {
				pattern = [[.*<(KEYWORDS)\s*]], -- pattern or table of patterns, used for highlighting (vim regex)
			},
			search = {
				command = "<leader>ft",
			},
		},
	},
}
