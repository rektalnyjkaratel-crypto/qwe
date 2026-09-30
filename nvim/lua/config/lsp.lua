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

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLsp", { clear = true }),
  callback = function(event)
    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
    end
    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gr", vim.lsp.buf.references, "References")
    map("gi", vim.lsp.buf.implementation, "Go to implementation")
    map("gy", vim.lsp.buf.type_definition, "Go to type definition")
    map("K", vim.lsp.buf.hover, "Documentation")
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>ca", function()
      require("fzf-lua").lsp_code_actions({
        silent = true,
        previewer = false,
        winopts = { width = 0.8, height = 0.35 },
      })
    end, "Code action")
    map("<leader>cf", function() format_buffer(event.buf, true) end, "Format buffer")

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
  settings = {
    gopls = {
      staticcheck = false,
      usePlaceholders = true,
      completeFunctionCalls = true,
      diagnosticsTrigger = "Save",
      directoryFilters = { "-.git", "-node_modules", "-vendor", "-dist", "-build" },
    },
  },
})

vim.lsp.config("ts_ls", {
  init_options = { disableAutomaticTypingAcquisition = true },
  root_dir = function(bufnr, on_dir)
    on_dir(vim.fs.root(bufnr, { "tsconfig.json", "jsconfig.json", "package.json", ".git" })
      or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
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
