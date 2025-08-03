-- Show a warning when arrow keys are used
local naughty_notify = function()
	vim.notify("Naughty! (Use hjkl instead)", vim.log.levels.WARN, {
		title = "Arrow Keys Are For Noobs",
		timeout = 1000,
		icon = ":(",
	})
end

-- Check if running in Neovim (avoid errors in other Lua contexts)
if vim then
	-- Define keymaps for arrow keys in Normal, Insert, and Visual modes
	local modes = { "n", "i", "v" }
	local keys = { "<Up>", "<Down>", "<Left>", "<Right>" }

	for _, mode in ipairs(modes) do
		for _, key in ipairs(keys) do
			vim.keymap.set(mode, key, function()
				naughty_notify()
				-- Optionally, still allow the keypress by returning the original key
				-- return key
			end, { expr = true, desc = "Naughty arrow key warning" })
		end
	end
end
