vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})

local format_group = vim.api.nvim_create_augroup("UserLspFormat", { clear = true })

local function format_buffer(bufnr, async)
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format({
      bufnr = bufnr,
      async = async,
      timeout_ms = 2000,
      lsp_format = "fallback",
    })
  else
    vim.lsp.buf.format({ bufnr = bufnr, async = async, timeout_ms = 2000 })
  end
end

local function existing_root(bufnr, markers)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then return nil end

  local file = vim.uv.fs_realpath(name) or name
  local root = vim.fs.root(file, markers) or vim.fs.dirname(file)
  local stat = root and vim.uv.fs_stat(root)
  if stat and stat.type == "directory" then return root end
end

local function organize_imports()
  local kinds = {
    "source.removeUnusedImports.ts",
    "source.organizeImports.ts",
    "source.organizeImports",
  }

  local function apply_action(action, client)
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding or "utf-16")
    end

    local command = action.command
    if command then
      vim.lsp.buf.execute_command(type(command) == "table" and command or {
        command = command,
        arguments = action.arguments,
      })
    end
  end

  local function request_kind(index)
    local kind = kinds[index]
    if not kind then return end

    local params = vim.lsp.util.make_range_params(0, "utf-16")
    params.context = { only = { kind }, diagnostics = {} }
    vim.lsp.buf_request_all(0, "textDocument/codeAction", params, function(results)
      for client_id, result in pairs(results) do
        local client = vim.lsp.get_client_by_id(client_id)
        for _, action in ipairs(result.result or {}) do
          if client and action.kind == kind then
            apply_action(action, client)
            break
          end
        end
      end
      vim.defer_fn(function() request_kind(index + 1) end, 100)
    end)
  end

  request_kind(1)
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLsp", { clear = true }),
  callback = function(event)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = desc })
    end

    local code_actions = function()
      require("fzf-lua").lsp_code_actions({
        silent = true,
        previewer = false,
        winopts = { width = 0.8, height = 0.35 },
      })
    end

    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "gr", vim.lsp.buf.references, "References")
    map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
    map("n", "gy", vim.lsp.buf.type_definition, "Go to type definition")
    map("n", "K", vim.lsp.buf.hover, "Documentation")
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map({ "n", "x" }, "<leader>ca", code_actions, "Code action")
    map("n", "<leader>ci", organize_imports, "Organize imports")
    map("n", "<leader>cf", function() format_buffer(event.buf, true) end, "Format buffer")
    map("n", "<leader>ch", function()
      local filter = { bufnr = event.buf }
      local enabled = not vim.lsp.inlay_hint.is_enabled(filter)
      vim.lsp.inlay_hint.enable(enabled, filter)
      vim.notify("Inlay hints " .. (enabled and "enabled" or "disabled"))
    end, "Toggle inlay hints")

    if vim.tbl_contains({ "go", "rust" }, vim.bo[event.buf].filetype) then
      vim.api.nvim_clear_autocmds({ group = format_group, buffer = event.buf })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = format_group,
        buffer = event.buf,
        callback = function() format_buffer(event.buf, false) end,
        desc = "Format buffer before saving",
      })
    end
  end,
})

vim.lsp.config("gopls", {
  root_dir = function(bufnr, on_dir)
    local root = existing_root(bufnr, { "go.work", "go.mod", ".git" })
    if root then on_dir(root) end
  end,
  settings = {
    gopls = {
      usePlaceholders = true,
      completeFunctionCalls = true,
      diagnosticsTrigger = "Save",
      directoryFilters = { "-.git", "-**/node_modules", "-vendor", "-dist", "-build" },
      analyses = {
        nilness = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
      hints = {
        assignVariableTypes = false,
        compositeLiteralFields = true,
        compositeLiteralTypes = false,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = false,
      },
      codelenses = {
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = false,
        test = false,
        tidy = true,
        upgrade_dependency = true,
        vendor = false,
      },
    },
  },
})

vim.lsp.config("ts_ls", {
  init_options = {
    disableAutomaticTypingAcquisition = true,
    preferences = {
      importModuleSpecifierPreference = "shortest",
      includePackageJsonAutoImports = "auto",
      includeCompletionsForModuleExports = true,
      includeCompletionsForImportStatements = true,
      includeInlayParameterNameHints = "literals",
      includeInlayParameterNameHintsWhenArgumentMatchesName = false,
      includeInlayFunctionParameterTypeHints = false,
      includeInlayVariableTypeHints = false,
      includeInlayVariableTypeHintsWhenTypeMatchesName = false,
      includeInlayPropertyDeclarationTypeHints = true,
      includeInlayFunctionLikeReturnTypeHints = false,
      includeInlayEnumMemberValueHints = true,
    },
  },
  settings = {
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "literals",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionLikeReturnTypeHints = false,
        includeInlayVariableTypeHints = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
      preferences = {
        importModuleSpecifierPreference = "shortest",
        includePackageJsonAutoImports = "auto",
      },
    },
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "literals",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionLikeReturnTypeHints = false,
        includeInlayVariableTypeHints = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
      preferences = {
        importModuleSpecifierPreference = "shortest",
        includePackageJsonAutoImports = "auto",
      },
    },
  },
  root_dir = function(bufnr, on_dir)
    local root = existing_root(bufnr, { "tsconfig.json", "jsconfig.json", "package.json", ".git" })
    if root then on_dir(root) end
  end,
})

vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      checkOnSave = true,
      diagnostics = { enable = true },
    },
  },
})

vim.lsp.config("svelte", {
  root_dir = function(bufnr, on_dir)
    on_dir(vim.fs.root(bufnr, {
      "svelte.config.js",
      "svelte.config.mjs",
      "svelte.config.ts",
      "vite.config.js",
      "vite.config.mjs",
      "vite.config.ts",
      "package.json",
      ".git",
    }) or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
  end,
})

vim.lsp.config("eslint", {
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, {
      "eslint.config.js",
      "eslint.config.mjs",
      "eslint.config.cjs",
      ".eslintrc",
      ".eslintrc.js",
      ".eslintrc.cjs",
      ".eslintrc.json",
    })
    if root then on_dir(root) end
  end,
})

vim.lsp.config("emmet_language_server", {
  filetypes = { "html", "css", "scss", "javascriptreact", "typescriptreact", "svelte" },
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      hint = { enable = false },
      codeLens = { enable = false },
    },
  },
  on_init = function(client)
    local root = client.root_dir
    local config = vim.uv.fs_realpath(vim.fn.stdpath("config"))
    if not root or vim.uv.fs_realpath(root) ~= config then return end
    -- Only the Neovim config uses LuaJIT and the `vim` global.
    -- Ordinary Lua projects keep their own runtime and .luarc settings.
    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = { library = { vim.env.VIMRUNTIME .. "/lua" } },
    })
  end,
  root_dir = function(bufnr, on_dir)
    local file = vim.uv.fs_realpath(vim.api.nvim_buf_get_name(bufnr)) or vim.api.nvim_buf_get_name(bufnr)
    local config = vim.uv.fs_realpath(vim.fn.stdpath("config"))
    if config and vim.startswith(file, config .. "/") then
      on_dir(config)
    else
      on_dir(vim.fs.root(file, { ".luarc.json", ".luarc.jsonc", ".busted", ".git" }) or vim.fs.dirname(file))
    end
  end,
})

vim.lsp.config("psalm", {
  cmd = { "psalm", "--language-server" },
  root_markers = { "psalm.xml", "psalm.xml.dist" },
})

-- Only these servers can start, and only for matching file types.
vim.lsp.enable({
  "gopls",
  "ts_ls",
  "svelte",
  "eslint",
  "html",
  "cssls",
  "jsonls",
  "tailwindcss",
  "emmet_language_server",
  "intelephense",
  "psalm",
  "lua_ls",
  "ty",
  "rust_analyzer",
})
