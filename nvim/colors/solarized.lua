-- Solarized Dark: same palette as the Ubuntu profile in Windows Terminal.
-- Use explicit RGB colors: Solarized's bright ANSI slots contain grey shades.
vim.cmd.highlight("clear")
if vim.g.syntax_on then vim.cmd("syntax reset") end
vim.g.colors_name = "solarized"

local p = {
  bg = "#002b36", surface = "#073642", muted = "#586e75", comment = "#657b83",
  fg = "#839496", light = "#93a1a1", white = "#eee8d5", bright = "#fdf6e3",
  red = "#dc322f", orange = "#cb4b16", green = "#859900", yellow = "#b58900",
  blue = "#268bd2", magenta = "#d33682", violet = "#6c71c4", cyan = "#2aa198",
}

local groups = {
  Normal = { fg = p.fg, bg = p.bg },
  NormalNC = { link = "Normal" },
  NormalFloat = { fg = p.fg, bg = p.surface },
  FloatBorder = { fg = p.comment, bg = p.surface },
  Cursor = { fg = p.bg, bg = "#ffffff" },
  CursorLine = { bg = p.surface },
  CursorLineNr = { fg = p.light, bold = true },
  LineNr = { fg = p.muted },
  SignColumn = { link = "Normal" },
  FoldColumn = { fg = p.comment, bg = p.bg },
  Folded = { fg = p.comment, bg = p.surface },
  NonText = { fg = p.muted },
  Whitespace = { link = "NonText" },
  EndOfBuffer = { link = "NonText" },
  Visual = { fg = p.light, bg = p.surface },
  StatusLine = { fg = p.light, bg = p.surface },
  StatusLineNC = { fg = p.comment, bg = p.surface },
  WinSeparator = { fg = p.muted, bg = p.bg },
  Pmenu = { fg = p.fg, bg = p.surface },
  PmenuSel = { fg = p.bg, bg = p.blue },
  PmenuSbar = { bg = p.surface },
  PmenuThumb = { bg = p.comment },
  Search = { fg = p.yellow, bg = p.surface, underline = true },
  IncSearch = { fg = p.bg, bg = p.yellow },
  CurSearch = { link = "IncSearch" },
  MatchParen = { fg = p.orange, bg = p.surface, bold = true },
  Comment = { fg = p.comment, italic = true },
  Constant = { fg = p.cyan },
  String = { fg = p.green },
  Character = { fg = p.cyan },
  Number = { fg = p.magenta },
  Boolean = { fg = p.magenta },
  Float = { link = "Number" },
  Identifier = { fg = p.blue },
  Function = { fg = p.blue },
  Statement = { fg = p.yellow },
  Operator = { fg = p.light },
  PreProc = { fg = p.orange },
  Type = { fg = p.yellow },
  Special = { fg = p.red },
  Underlined = { fg = p.violet, underline = true },
  Directory = { fg = p.blue },
  Title = { fg = p.blue, bold = true },
  Todo = { fg = p.yellow, bg = p.surface, bold = true },
  Error = { fg = p.red },
  ErrorMsg = { fg = p.red },
  WarningMsg = { fg = p.yellow },
  DiffAdd = { fg = p.green, bg = p.surface },
  DiffChange = { fg = p.yellow, bg = p.surface },
  DiffDelete = { fg = p.red, bg = p.surface },
  DiffText = { fg = p.bg, bg = p.yellow },
}
for name, spec in pairs(groups) do vim.api.nvim_set_hl(0, name, spec) end
for severity, color in pairs({ Error = p.red, Warn = p.yellow, Info = p.blue, Hint = p.cyan, Ok = p.green }) do
  vim.api.nvim_set_hl(0, "Diagnostic" .. severity, { fg = color })
  vim.api.nvim_set_hl(0, "DiagnosticUnderline" .. severity, { sp = color, undercurl = true })
end

local terminal = {
  p.bg, p.red, p.green, p.yellow, p.blue, p.magenta, p.cyan, p.white,
  p.surface, p.orange, p.muted, p.comment, p.fg, p.violet, p.light, p.bright,
}
for i, color in ipairs(terminal) do vim.g["terminal_color_" .. (i - 1)] = color end
