local function pick(name)
  return function()
    require("fzf-lua")[name]({ cwd = require("config.project").root() })
  end
end

local function test(command)
  return function()
    vim.cmd("update")
    vim.g["test#project_root"] = require("config.project").root()
    vim.cmd(command)
  end
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    opts = {
      install_dir = vim.fn.stdpath("data") .. "/site",
      parsers = {
        "bash",
        "css",
        "go",
        "gomod",
        "html",
        "javascript",
        "javascriptreact",
        "json",
        "lua",
        "markdown",
        "php",
        "python",
        "rust",
        "svelte",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },
      filetypes = {
        "bash",
        "css",
        "go",
        "gomod",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "php",
        "python",
        "rust",
        "svelte",
        "toml",
        "typescript",
        "typescriptreact",
        "vim",
        "vimdoc",
        "yaml",
      },
    },
    config = function(_, opts)
      require("nvim-treesitter").setup({ install_dir = opts.install_dir })

      vim.api.nvim_create_user_command("TSInstallConfigured", function()
        require("nvim-treesitter").install(opts.parsers)
      end, { desc = "Install configured Treesitter parsers" })

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
        pattern = opts.filetypes,
        callback = function()
          if pcall(vim.treesitter.start) then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      require("nvim-treesitter-textobjects").setup({
        move = { set_jumps = true },
      })

      local move = require("nvim-treesitter-textobjects.move")
      vim.keymap.set({ "n", "x", "o" }, "]m", function()
        move.goto_next_start("@function.outer", "textobjects")
      end, { desc = "Next function or method" })
      vim.keymap.set({ "n", "x", "o" }, "[m", function()
        move.goto_previous_start("@function.outer", "textobjects")
      end, { desc = "Previous function or method" })
      vim.keymap.set({ "n", "x", "o" }, "]T", function()
        move.goto_next_start("@class.outer", "textobjects")
      end, { desc = "Next type" })
      vim.keymap.set({ "n", "x", "o" }, "[T", function()
        move.goto_previous_start("@class.outer", "textobjects")
      end, { desc = "Previous type" })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "]h", function() require("gitsigns").nav_hunk("next") end, desc = "Next git hunk" },
      { "[h", function() require("gitsigns").nav_hunk("prev") end, desc = "Previous git hunk" },
      { "<leader>gp", function() require("gitsigns").preview_hunk() end, desc = "Preview git hunk" },
      { "<leader>gs", function() require("gitsigns").stage_hunk() end, desc = "Stage git hunk" },
      { "<leader>gr", function() require("gitsigns").reset_hunk() end, desc = "Reset git hunk" },
      { "<leader>gb", function() require("gitsigns").blame_line({ full = true }) end, desc = "Git blame line" },
    },
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "^" },
        changedelete = { text = "~" },
        untracked = { text = "+" },
      },
      sign_priority = 10,
      current_line_blame = false,
    },
  },
  {
    "stevearc/conform.nvim",
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact", "svelte", "html", "css", "scss", "json", "jsonc", "yaml", "markdown" },
    opts = function()
      local util = require("conform.util")
      return {
        formatters = {
          prettier = {
            cwd = util.root_file({ "package.json", ".prettierrc", "prettier.config.js", "prettier.config.mjs", "prettier.config.cjs" }),
            require_cwd = true,
          },
        },
        formatters_by_ft = {
          javascript = { "prettier" },
          javascriptreact = { "prettier" },
          typescript = { "prettier" },
          typescriptreact = { "prettier" },
          svelte = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          scss = { "prettier" },
          json = { "prettier" },
          jsonc = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
        },
        format_on_save = function(bufnr)
          local enabled = {
            javascript = true,
            javascriptreact = true,
            typescript = true,
            typescriptreact = true,
            svelte = true,
            html = true,
            css = true,
            scss = true,
            json = true,
            jsonc = true,
          }
          if not enabled[vim.bo[bufnr].filetype] then return end
          return { timeout_ms = 2000, lsp_format = "never" }
        end,
      }
    end,
  },
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    keys = {
      { "<leader>ff", pick("files"), desc = "Find files" },
      { "<leader>fg", pick("live_grep"), desc = "Search project text" },
      { "<leader>fb", pick("buffers"), desc = "Open buffers" },
      { "<leader>fs", pick("lsp_document_symbols"), desc = "Functions and symbols" },
      { "<leader>fw", pick("grep_cword"), desc = "Search word under cursor" },
      { "<leader>?", "<cmd>FzfLua keymaps<cr>", desc = "Find a key binding" },
    },
    opts = {
      file_icons = false,
      git_icons = false,
      color_icons = false,
      winopts = { treesitter = { enabled = false }, preview = { layout = "flex" } },
      previewers = { builtin = { syntax = true, treesitter = { enabled = false } } },
      files = { rg_opts = "--files --hidden --glob !.git" },
      grep = { rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --glob !.git -e" },
    },
  },
  {
    "folke/flash.nvim",
    keys = {
      { "s", function() require("flash").jump() end, mode = { "n", "x", "o" }, desc = "Jump to text" },
    },
    opts = { modes = { char = { enabled = false }, search = { enabled = false } } },
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      map_cr = false,
      disable_filetype = { "TelescopePrompt", "spectre_panel", "snacks_picker_input" },
    },
  },
  {
    "ThePrimeagen/refactoring.nvim",
    cmd = "Refactor",
    keys = {
      {
        "<leader>Re",
        function() return require("refactoring").extract_func() end,
        mode = { "n", "x" },
        desc = "Extract function",
        expr = true,
      },
      {
        "<leader>RE",
        function() return require("refactoring").extract_func_to_file() end,
        mode = { "n", "x" },
        desc = "Extract function to file",
        expr = true,
      },
      {
        "<leader>Rv",
        function() return require("refactoring").extract_var() end,
        mode = { "n", "x" },
        desc = "Extract variable",
        expr = true,
      },
      {
        "<leader>Ri",
        function() return require("refactoring").inline_var() end,
        mode = { "n", "x" },
        desc = "Inline variable",
        expr = true,
      },
      {
        "<leader>RI",
        function() return require("refactoring").inline_func() end,
        mode = { "n", "x" },
        desc = "Inline function",
        expr = true,
      },
      {
        "<leader>Rs",
        function() require("refactoring").select_refactor() end,
        mode = { "n", "x" },
        desc = "Select refactor",
      },
    },
    dependencies = { "lewis6991/async.nvim" },
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    opts = {
      keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },
      completion = {
        list = { selection = { preselect = false, auto_insert = false } },
        menu = { draw = { columns = { { "label", "label_description", gap = 1 }, { "kind" } } } },
        documentation = { auto_show = true, auto_show_delay_ms = 250 },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          lsp = { fallbacks = {} },
          buffer = { score_offset = -5 },
          snippets = {
            opts = {
              friendly_snippets = false,
              search_paths = { vim.fn.stdpath("config") .. "/snippets" },
            },
          },
        },
      },
      -- No compiler, binary download, or separate snippet engine required.
      fuzzy = { implementation = "lua" },
    },
  },
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" },
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    ft = {
      "go",
      "gomod",
      "gowork",
      "gotmpl",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "svelte",
      "html",
      "css",
      "scss",
      "json",
      "jsonc",
      "php",
      "lua",
      "python",
      "rust",
    },
    dependencies = { "mason-org/mason.nvim", "saghen/blink.cmp" },
    config = function() require("config.lsp") end,
  },
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug continue" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug step into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Debug step out" },
      { "<leader>Db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>DB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Conditional breakpoint" },
      { "<leader>Dc", function() require("dap").continue() end, desc = "Debug continue" },
      { "<leader>Di", function() require("dap").step_into() end, desc = "Debug step into" },
      { "<leader>Do", function() require("dap").step_over() end, desc = "Debug step over" },
      { "<leader>DO", function() require("dap").step_out() end, desc = "Debug step out" },
      { "<leader>Dq", function() require("dap").terminate() end, desc = "Debug terminate" },
      { "<leader>Dr", function() require("dap").repl.toggle() end, desc = "Debug REPL" },
      { "<leader>Du", function() require("dapui").toggle() end, desc = "Debug UI" },
    },
    dependencies = {
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
    },
    config = function() require("config.dap").setup() end,
  },
  {
    "vim-test/vim-test",
    cmd = { "TestNearest", "TestFile", "TestSuite", "TestLast", "TestVisit" },
    keys = {
      { "<leader>tn", test("TestNearest"), desc = "Test nearest to cursor" },
      { "<leader>tf", test("TestFile"), desc = "Test current file" },
      { "<leader>ts", test("TestSuite"), desc = "Test suite" },
      { "<leader>tl", "<cmd>update | TestLast<cr>", desc = "Repeat last test" },
    },
    config = function()
      vim.g["test#strategy"] = "neovim"
      vim.g["test#neovim#term_position"] = "botright 12"
      vim.g["test#neovim#start_normal"] = 1
      vim.g["test#go#runner"] = "gotest"
      vim.g["test#rust#runner"] = "cargo"
      vim.g["test#python#runner"] = "pytest"
      vim.g["test#javascript#nodetest#options"] = { suite = "--test" }
    end,
  },
}
