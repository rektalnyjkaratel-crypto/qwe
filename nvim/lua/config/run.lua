local M = {}

local function open_terminal(command)
  vim.cmd("update")
  vim.cmd("botright 12split")
  vim.fn.termopen({ "sh", "-lc", "cd " .. vim.fn.shellescape(require("config.project").root()) .. " && " .. command })
  vim.cmd("startinsert")
end

local function go_package()
  local root = vim.fs.normalize(require("config.project").root())
  local file = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
  local dir = vim.fs.dirname(file)
  if not dir or dir == "" or not vim.startswith(dir, root) then return "./..." end
  if dir == root then return "." end
  return "./" .. dir:sub(#root + 2)
end

function M.command(command)
  return function() open_terminal(command) end
end

function M.go_test_package()
  open_terminal("go test " .. vim.fn.shellescape(go_package()))
end

return M
