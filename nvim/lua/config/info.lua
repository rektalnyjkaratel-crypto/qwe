local M = {}

local function buffer_filetype(bufnr)
  local ft = vim.bo[bufnr].filetype
  if ft == "" then return "none" end
  return ft
end

function M.lsp()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  if #clients == 0 then
    vim.notify("No LSP clients attached for " .. buffer_filetype(bufnr))
    return
  end

  local names = {}
  for _, client in ipairs(clients) do
    table.insert(names, client.name)
  end
  table.sort(names)
  vim.notify("LSP for " .. buffer_filetype(bufnr) .. ": " .. table.concat(names, ", "))
end

function M.formatters()
  local bufnr = vim.api.nvim_get_current_buf()
  local ok, conform = pcall(require, "conform")
  if not ok then
    vim.notify("conform.nvim is not loaded")
    return
  end

  local names = conform.list_formatters_for_buffer(bufnr)
  if #names == 0 then
    vim.notify("No formatters configured for " .. buffer_filetype(bufnr))
    return
  end

  vim.notify("Formatters for " .. buffer_filetype(bufnr) .. ": " .. table.concat(names, ", "))
end

return M
