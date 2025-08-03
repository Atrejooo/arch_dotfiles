local right = "]"
local left = "["

function CustomTabliny()
	local tabline = ""
	local current_buf = vim.api.nvim_get_current_buf()

	-- Get all buffers
	local buffers = {}
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			local name = vim.api.nvim_buf_get_name(buf)
			-- Extract just the filename
			name = name:match("^.+/(.+)$") or name
			-- Skip unnamed buffers
			if name ~= "" then
				table.insert(buffers, {
					id = buf,
					name = name,
					modified = vim.api.nvim_buf_get_option(buf, "modified"),
				})
			end
		end
	end

	-- Build the tabline
	for _, buf in ipairs(buffers) do
		local diagnostics = ""
		local modified_indicator = ""
		local is_current = buf.id == current_buf
		local hl_group = is_current and "TablinySel" or "Tabliny"

		-- Add modified indicator if buffer is modified
		if buf.modified then
			local mod_hl = is_current and "TablinyModifiedSel" or "TablinyModified"
			modified_indicator = " %#" .. mod_hl .. "#M%#" .. hl_group .. "#"
		end

		-- Get LSP diagnostics for this buffer
		local diag = vim.diagnostic.get(buf.id)
		if #diag > 0 then
			local errors = 0
			local warnings = 0

			for _, d in ipairs(diag) do
				if d.severity == vim.diagnostic.severity.ERROR then
					errors = errors + 1
				elseif d.severity == vim.diagnostic.severity.WARN then
					warnings = warnings + 1
				end
			end

			-- Only show warnings if there are no errors
			if errors > 0 then
				diagnostics = " %#"
					.. (is_current and "TablinyDiagnosticErrorSel" or "TablinyDiagnosticError")
					.. "#"
					.. errors
					.. "E%#"
					.. hl_group
					.. "#"
			elseif warnings > 0 then
				diagnostics = " %#"
					.. (is_current and "TablinyDiagnosticWarnSel" or "TablinyDiagnosticWarn")
					.. "#"
					.. warnings
					.. "W%#"
					.. hl_group
					.. "#"
			end
		end

		if is_current then
			-- Active buffer
			tabline = tabline .. "%#TablinySel# " .. left .. buf.name .. modified_indicator .. diagnostics .. right
		else
			-- Inactive buffer
			tabline = tabline .. "%#Tabliny# " .. left .. buf.name .. modified_indicator .. diagnostics .. right
		end

		-- Add separator between buffers
		tabline = tabline .. " "
	end

	-- End with TablinyFill to fill the rest of the line
	return tabline .. "%#TablinyFill#"
end

-- Set the tabline
vim.o.tabline = "%!v:lua.CustomTabliny()"

-- Refresh tabline when diagnostics change or buffer modification state changes
vim.api.nvim_create_autocmd({ "DiagnosticChanged", "BufModifiedSet" }, {
	callback = function()
		vim.cmd("redrawtabline")
	end,
})
