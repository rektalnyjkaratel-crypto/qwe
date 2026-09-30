local M = {}

-- The closest package wins, including packages inside a monorepo.
function M.root()
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" or vim.bo.buftype ~= "" then
    return vim.fn.getcwd()
  end
  local config = vim.uv.fs_realpath(vim.fn.stdpath("config"))
  local file = vim.uv.fs_realpath(name) or name
  if config and vim.startswith(file, config .. "/") then
    return config
  end
  return vim.fs.root(name, {
    "go.mod", "go.work", "package.json", "composer.json", "Cargo.toml",
    "pyproject.toml", "pytest.ini", "setup.cfg", "setup.py", "requirements.txt",
    ".busted", ".luarc.json", ".luarc.jsonc", ".git",
  }) or vim.fs.dirname(name)
end

return M
