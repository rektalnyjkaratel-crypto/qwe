local M = {}

local function executable(name)
  local path = vim.fn.exepath(name)
  if path ~= "" then return path end
  return vim.fn.stdpath("data") .. "/mason/bin/" .. name
end

local function project_root()
  return require("config.project").root()
end

function M.setup()
  local dap = require("dap")
  local dapui = require("dapui")

  dapui.setup()

  dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
  dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
  dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

  vim.fn.sign_define("DapBreakpoint", { text = "B", texthl = "DiagnosticSignError" })
  vim.fn.sign_define("DapBreakpointCondition", { text = "C", texthl = "DiagnosticSignWarn" })
  vim.fn.sign_define("DapStopped", { text = ">", texthl = "DiagnosticSignInfo", linehl = "Visual" })

  dap.adapters.go = {
    type = "server",
    host = "127.0.0.1",
    port = "${port}",
    executable = {
      command = executable("dlv"),
      args = { "dap", "-l", "127.0.0.1:${port}" },
    },
  }

  dap.configurations.go = {
    {
      type = "go",
      name = "Debug package",
      request = "launch",
      program = project_root,
    },
    {
      type = "go",
      name = "Debug file",
      request = "launch",
      program = "${file}",
    },
    {
      type = "go",
      name = "Debug test file",
      request = "launch",
      mode = "test",
      program = "${file}",
    },
    {
      type = "go",
      name = "Attach process",
      request = "attach",
      mode = "local",
      processId = require("dap.utils").pick_process,
    },
  }

  local js_adapter = {
    type = "server",
    host = "127.0.0.1",
    port = "${port}",
    executable = {
      command = executable("js-debug-adapter"),
      args = { "${port}" },
    },
  }
  dap.adapters["pwa-node"] = js_adapter
  dap.adapters["pwa-chrome"] = js_adapter

  local js_configurations = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch current file",
      program = "${file}",
      cwd = project_root,
      console = "integratedTerminal",
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach to Node process",
      processId = require("dap.utils").pick_process,
      cwd = project_root,
    },
    {
      type = "pwa-chrome",
      request = "launch",
      name = "Launch Vite Chrome",
      url = function() return vim.fn.input("URL: ", "http://localhost:5173") end,
      webRoot = project_root,
    },
  }

  dap.configurations.javascript = js_configurations
  dap.configurations.typescript = js_configurations
  dap.configurations.javascriptreact = js_configurations
  dap.configurations.typescriptreact = js_configurations

  dap.adapters.php = {
    type = "executable",
    command = executable("php-debug-adapter"),
  }

  dap.configurations.php = {
    {
      type = "php",
      request = "launch",
      name = "Listen for Xdebug",
      port = 9003,
    },
    {
      type = "php",
      request = "launch",
      name = "Listen for Xdebug Docker /app",
      port = 9003,
      pathMappings = {
        ["/app"] = "${workspaceFolder}",
      },
    },
  }
end

return M
