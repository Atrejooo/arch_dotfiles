require("colorbuddy").colorscheme("gruvbuddy")

local colorbuddy = require("colorbuddy")
local Color = colorbuddy.Color
local Group = colorbuddy.Group
local c = colorbuddy.colors
local g = colorbuddy.groups
local s = colorbuddy.styles

local function groupy(groups, fg, bg, style)
	-- Handle single group (string) or multiple groups (table)
	if type(groups) == "string" then
		groups = { groups }
	elseif not (type(groups) == "table") then
		vim.notify("groupy: expected string or table, got " .. type(groups), vim.log.levels.ERROR)
		return
	end

	-- Resolve style if provided
	local s = require("colorbuddy").styles
	local highlight_style = style and s[style] or nil

	-- Apply to all groups
	for _, group in ipairs(groups) do
		require("colorbuddy").Group.new(group, fg, bg, highlight_style)
	end
end

Color.new("white", "#cfdfff") -- @@txt_white@@
Color.new("red", "#c62e60") -- @@txt_red@@
Color.new("pink", "#aaccff") -- @@txt_highlight@@
Color.new("green", "#83edb6") -- @@txt_green@@
Color.new("yellow", "#FFB785") -- @@txt_yellow@@
Color.new("blue", "#6287FC") -- @@txt_blue@@
Color.new("cyan", "#82d4fC") -- @@txt_cyan@@
Color.new("purple", "#8351FC") -- @@txt_purple@@
Color.new("orange", "#dF6350") -- @@txt_orange@@

Color.new("normal", "#909acb") -- @@txt_main@@
Color.new("superwhite", "#cfdfff") -- @@txt_white@@
Color.new("sel", "#bbabff") -- @@txt_sel@@
Color.new("pale", "#708a9b") -- @@txt_pale@@
Color.new("bg", "#111111") -- @@dark_main@@
Color.new("fg", "#47476a") -- @@light_base@@
Color.new("dark", "#000000") -- @@dark_base@@

-- normal ui and stuff
groupy({
	"Normal",
	"NormalFloat",
	"SignColumn",
	-- mini
	"MiniFilesNormal",
	"MiniFilesBorder",
	"MiniFilesBorderModified",
	"MiniFilesCursorLine",
	"MiniFilesDirectory",
	"MiniFilesFile",
	"MiniFilesTitle",
	"MiniFilesTitleFocused",
}, c.normal, c.bg)

-- selections
groupy({
	"Visual",
	"TelescopeSelection",
	"PmenuSel",
}, nil, c.sel)

groupy({ "Search" }, nil, c.orange)
Group.new("Cursor", nil, nil, s.reverse)

-- Status line
groupy({
	"StatusLine",
	"StatusLineSeparator",
}, c.normal, c.fg)
groupy("StatusLineNC", c.pale, c.bg)
-- Tabliny
groupy({ "TablinyFill", "Tabliny" }, c.pale, c.dark)
groupy("TablinySel", c.normal, c.bg)

groupy("TablinyModifiedSel", c.green, c.bg)
groupy("TablinyModified", c.green, c.dark)

groupy("TablinyDiagnosticErrorSel", c.red, c.bg)
groupy("TablinyDiagnosticWarnSel", c.yellow, c.bg)

groupy("TablinyDiagnosticError", c.red, c.dark)
groupy("TablinyDiagnosticWarn", c.yellow, c.dark)
-- pale
groupy("LineNr", c.pale, c.bg)

groupy({
	"LspInlayHint",
	"Comment",
	"EndOfBuffer",
}, c.pale)

-- Diagnostics
groupy({
	"DiagnosticError",
	"DiagnosticUnderlineError",
	"DiagnosticFloatingError",
	"DiagnosticUnderlineError",
	"DiagnosticVirtualTextError",
	"LspDiagnosticsDefaultError",
	"LspDiagnosticsUnderlineError",
}, c.red)
groupy({
	"DiagnosticWarn",
	"DiagnosticUnderlineWarn",
	"DiagnosticSignWarn",
	"DiagnosticFloatingWarn",
	"DiagnosticVirtualTextWarn",
	"LspDiagnosticsDefaultWarning",
	"LspDiagnosticsUnderlineWarning",
}, c.yellow)
groupy({
	"DiagnosticInfo",
}, c.blue)
groupy({
	"DiagnosticHint",
}, c.cyan)

-- Tree sitter
groupy({
	"@punctuation.bracket",
	"@punctuation.delimiter",
	"@function.bracket",
}, c.normal)
groupy({
	"@constant",
}, c.purple)
groupy({
	"@string",
	"@character",
}, c.cyan)
groupy("@string.escape", c.normal)
groupy({
	"@number",
	"@boolean",
	"@number.float",
}, c.white)

groupy({
	"@constant.macro",
	"@annotation",
}, c.yellow)

groupy({
	"@keyword",
	"@keyword.function",
	"@keyword.operator",
	"@keyword.conditional",
	"@keyword.repeat",
	"@keyword.exception",
	"@keyword.include",
}, c.pink)

Group.new("@keyword.faded", c.pink:light())

groupy({
	"@operator",
	"@function",
	"constructor",
	"@function.method",
}, c.blue)

groupy("@type", c.purple)
Group.new("@property", c.blue)

groupy({
	"@error",
	"@exception",
}, c.red)

groupy({
	"@variable",
	"@lsp.type.namespace",
}, c.normal)
groupy({ "@variable.builtin" }, c.pink)
