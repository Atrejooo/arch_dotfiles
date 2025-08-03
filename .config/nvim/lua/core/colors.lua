local function enable_transparency()
	-- Define highlight groups to make transparent
	local transparent_groups = {
		-- Core UI
		"Normal",
		"NormalFloat",
		"LineNr",
		"SignColumn",

		-- Tabliny (doesn't really work rn dunno why)
		"TablinyDiagnosticErrorSel",
		"TablinyDiagnosticWarnSel",
		"TablinyModifiedSel",
		"TablinySel",
		"TabLine",
		"TabLineSel",
		"TabLineFill",

		-- Telescope
		"TelescopeNormal",
		"TelescopeBorder",
		"TelescopePromptNormal",
		"TelescopePromptBorder",
		"TelescopeResultsNormal",
		"TelescopePreviewNormal",

		-- Completion Menu
		"Pmenu",
		"PmenuSel",
		"PmenuSbar",

		-- MiniFiles
		"MiniFilesNormal",
		"MiniFilesBorder",
		"MiniFilesBorderModified",
		"MiniFilesCursorLine",
		"MiniFilesDirectory",
		"MiniFilesFile",
		"MiniFilesTitle",
		"MiniFilesTitleFocused",
	}

	-- Apply transparency to all groups while preserving existing attributes
	for _, group in ipairs(transparent_groups) do
		-- Get current highlight attributes (if group exists)
		local current_hl = vim.api.nvim_get_hl(0, { name = group, link = false })
		-- Merge with transparency while preserving existing attributes
		vim.api.nvim_set_hl(0, group, vim.tbl_extend("force", current_hl, { bg = "none" }))
	end
end

vim.cmd.colorscheme("gruvbuddy")

-- for transparent bg toggle this
enable_transparency()
