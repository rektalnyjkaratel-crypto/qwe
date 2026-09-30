-- Small navigation aid using conventional test declarations, no parser or runner.
local M = {}
local ns = vim.api.nvim_create_namespace("test_starts")
local attached = {}
local patterns = {
  go = {
    { [[\v^\s*func\s+%(\([^)]*\)\s+)?%(Test|Example)\w*\s*\(]], "T" },
    { [[\v^\s*func\s+Benchmark\w*\s*\(]], "B" },
    { [[\v^\s*t\.Run\s*\(]], "T" },
  },
  javascript = { { [[\v^\s*%(await\s+)?%(it|test)%(\.\w+)*\s*\(]], "T" } },
  python = { { [[\v^\s*%(async\s+)?def\s+test\w*\s*\(]], "T" } },
  php = {
    { [[\v^\s*public\s+%(static\s+)?function\s+test\w*\s*\(]], "T" },
    { [[\v^\s*%(it|test)\s*\(]], "T" },
  },
  lua = { { [=[\v^\s*it\s*\(?\s*['"]]=], "T" } },
  rust = {
    { [[\v^\s*#\s*\[\s*%(test|tokio::test|async_std::test)]], "T" },
    { [[\v^\s*#\s*\[\s*bench]], "B" },
  },
}
-- JSX and TypeScript use the same test calls as JavaScript.
patterns.javascriptreact = patterns.javascript
patterns.typescript = patterns.javascript
patterns.typescriptreact = patterns.javascript
patterns.svelte = patterns.javascript
for _, rules in pairs(patterns) do
  for _, rule in ipairs(rules) do rule.regex = rule.regex or vim.regex(rule[1]) end
end

function M.refresh(buf)
  if not vim.api.nvim_buf_is_loaded(buf) then return end
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  local ft = vim.bo[buf].filetype
  local rules = patterns[ft]
  if not rules or vim.bo[buf].buftype ~= "" then return end
  if ft == "go" and not vim.api.nvim_buf_get_name(buf):match("_test%.go$") then return end

  vim.api.nvim_buf_call(buf, function()
    for row, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
      for _, rule in ipairs(rules) do
        if rule.regex:match_str(line) then
          local col = line:find("%S") or 1
          local syntax = vim.fn.synIDattr(vim.fn.synID(row, col, true), "name"):lower()
          if not syntax:find("comment") and not syntax:find("string") then
            vim.api.nvim_buf_set_extmark(buf, ns, row - 1, 0, {
              sign_text = rule[2],
              sign_hl_group = rule[2] == "B" and "DiagnosticInfo" or "DiagnosticOk",
              priority = 20,
            })
          end
          break
        end
      end
    end
  end)
end

function M.jump(direction)
  local buf = vim.api.nvim_get_current_buf()
  M.refresh(buf)
  local marks = vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})
  if #marks == 0 then
    vim.notify("No test declarations in this file")
    return
  end
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local index = direction > 0 and 1 or #marks
  for i = 1, #marks do
    local j = direction > 0 and i or #marks - i + 1
    if (marks[j][2] - row) * direction > 0 then
      index = j
      break
    end
  end
  index = (index - 1 + direction * (vim.v.count1 - 1)) % #marks + 1
  vim.cmd("normal! m'")
  vim.api.nvim_win_set_cursor(0, { marks[index][2] + 1, 0 })
  vim.cmd("normal! ^zv")
end

function M.attach(buf)
  if attached[buf] then
    M.refresh(buf)
    return
  end
  attached[buf] = true
  vim.keymap.set("n", "]t", function() M.jump(1) end, { buffer = buf, desc = "Next test" })
  vim.keymap.set("n", "[t", function() M.jump(-1) end, { buffer = buf, desc = "Previous test" })
  vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave", "TextChanged" }, {
    buffer = buf,
    callback = function() M.refresh(buf) end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    once = true,
    callback = function() attached[buf] = nil end,
  })
  vim.schedule(function() M.refresh(buf) end)
end

return M
