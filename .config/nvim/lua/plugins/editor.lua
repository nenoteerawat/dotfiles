return {
  {
    enabled = false,
    "folke/flash.nvim",
    ---@type Flash.Config
    opts = {
      search = {
        forward = true,
        multi_window = false,
        wrap = false,
        incremental = true,
      },
    },
  },

  {
    "brenoprata10/nvim-highlight-colors",
    event = "BufReadPre",
    opts = {
      render = "background",
      enable_hex = true,
      enable_short_hex = true,
      enable_rgb = true,
      enable_hsl = true,
      enable_hsl_without_function = true,
      enable_ansi = true,
      enable_var_usage = true,
      enable_tailwind = true,
    },
  },

  {
    "dinhhuy258/git.nvim",
    event = "BufReadPre",
    opts = {
      keymaps = {
        -- Open blame window
        blame = "<Leader>gb",
        -- Open file/folder in git repository
        browse = "<Leader>go",
      },
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      "nvim-telescope/telescope-file-browser.nvim",
    },
    keys = {
      -- Disable default git commits keymap so conventional-commits.nvim can use <leader>gc
      { "<leader>gc", false },
      {
        "<leader>fP",
        function()
          require("telescope.builtin").find_files({
            cwd = require("lazy.core.config").options.root,
          })
        end,
        desc = "Find Plugin File",
      },
      {
        ";f",
        function()
          local builtin = require("telescope.builtin")
          builtin.find_files({
            no_ignore = false,
            hidden = true,
          })
        end,
        desc = "Lists files in your current working directory, respects .gitignore",
      },
      {
        ";r",
        function()
          local builtin = require("telescope.builtin")
          builtin.live_grep({
            additional_args = { "--hidden" },
          })
        end,
        desc = "Search for a string in your current working directory and get results live as you type, respects .gitignore",
      },
      {
        "\\\\",
        function()
          local builtin = require("telescope.builtin")
          builtin.buffers()
        end,
        desc = "Lists open buffers",
      },
      {
        ";t",
        function()
          local builtin = require("telescope.builtin")
          builtin.help_tags()
        end,
        desc = "Lists available help tags and opens a new window with the relevant help info on <cr>",
      },
      {
        ";;",
        function()
          local builtin = require("telescope.builtin")
          builtin.resume()
        end,
        desc = "Resume the previous telescope picker",
      },
      {
        ";e",
        function()
          local builtin = require("telescope.builtin")
          builtin.diagnostics()
        end,
        desc = "Lists Diagnostics for all open buffers or a specific buffer",
      },
      {
        ";s",
        function()
          local builtin = require("telescope.builtin")
          builtin.treesitter()
        end,
        desc = "Lists Function names, variables, from Treesitter",
      },
      {
        ";c",
        function()
          local builtin = require("telescope.builtin")
          builtin.lsp_incoming_calls()
        end,
        desc = "Lists LSP incoming calls for word under the cursor",
      },
      {
        "sf",
        function()
          local telescope = require("telescope")

          local function telescope_buffer_dir()
            return vim.fn.expand("%:p:h")
          end

          telescope.extensions.file_browser.file_browser({
            path = "%:p:h",
            cwd = telescope_buffer_dir(),
            respect_gitignore = false,
            hidden = true,
            grouped = true,
            previewer = false,
            initial_mode = "normal",
            layout_config = { height = 40 },
          })
        end,
        desc = "Open File Browser with the path of the current buffer",
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local fb_actions = require("telescope").extensions.file_browser.actions

      opts.defaults = vim.tbl_deep_extend("force", opts.defaults, {
        wrap_results = true,
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
        mappings = {
          n = {},
        },
      })
      opts.pickers = {
        diagnostics = {
          theme = "ivy",
          initial_mode = "normal",
          layout_config = {
            preview_cutoff = 9999,
          },
        },
      }
      opts.extensions = {
        file_browser = {
          theme = "dropdown",
          -- disables netrw and use telescope-file-browser in its place
          hijack_netrw = true,
          mappings = {
            -- your custom insert mode mappings
            ["n"] = {
              -- your custom normal mode mappings
              ["N"] = fb_actions.create,
              ["h"] = fb_actions.goto_parent_dir,
              ["/"] = function()
                vim.cmd("startinsert")
              end,
              ["<C-u>"] = function(prompt_bufnr)
                for i = 1, 10 do
                  actions.move_selection_previous(prompt_bufnr)
                end
              end,
              ["<C-d>"] = function(prompt_bufnr)
                for i = 1, 10 do
                  actions.move_selection_next(prompt_bufnr)
                end
              end,
              ["<PageUp>"] = actions.preview_scrolling_up,
              ["<PageDown>"] = actions.preview_scrolling_down,
            },
          },
        },
      }
      telescope.setup(opts)
      require("telescope").load_extension("fzf")
      require("telescope").load_extension("file_browser")
    end,
  },

  {
    "kazhala/close-buffers.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>th",
        function()
          require("close_buffers").delete({ type = "hidden" })
        end,
        "Close Hidden Buffers",
      },
      {
        "<leader>tu",
        function()
          require("close_buffers").delete({ type = "nameless" })
        end,
        "Close Nameless Buffers",
      },
    },
  },

  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        menu = {
          winblend = vim.o.pumblend,
        },
      },
      signature = {
        window = {
          winblend = vim.o.pumblend,
        },
      },
    },
  },
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      picker = "telescope",
      enable_builtin = true,
      default_merge_method = "squash",
    },
    keys = {
      { "<leader>opl", "<cmd>Octo pr list<cr>", desc = "List PRs" },
      { "<leader>ops", "<cmd>Octo pr search<cr>", desc = "Search PRs" },
      { "<leader>opc", "<cmd>Octo pr create<cr>", desc = "Create PR" },
      { "<leader>opo", "<cmd>Octo pr checkout<cr>", desc = "Checkout PR" },
      { "<leader>oil", "<cmd>Octo issue list<cr>", desc = "List Issues" },
      { "<leader>oic", "<cmd>Octo issue create<cr>", desc = "Create Issue" },
    },
  },

  {
    "zerbiniandrea/conventional-commits.nvim",
    cmd = "ConventionalCommit",
    config = function()
      require("conventional-commits").setup({
        -- Optional configuration here
      })
    end,
    keys = {
      { "<leader>gc", "<cmd>ConventionalCommit<cr>", desc = "Conventional Commit" },
    },
  },

  -- Diffget keymaps for merge conflict resolution (only active in diff mode)
  {
    "neovim/nvim-lspconfig",
    optional = true,
    init = function()
      local function set_diffget_keymaps()
        local buf = vim.api.nvim_get_current_buf()
        if vim.wo.diff then
          vim.keymap.set("n", "<leader>gl", "<cmd>diffget 1<cr>", { buffer = buf, desc = "Diffget LOCAL" })
          vim.keymap.set("n", "<leader>gb", "<cmd>diffget 2<cr>", { buffer = buf, desc = "Diffget BASE" })
          vim.keymap.set("n", "<leader>gr", "<cmd>diffget 3<cr>", { buffer = buf, desc = "Diffget REMOTE" })
        end
      end

      -- When nvim starts in diff mode (git mergetool with -d flag)
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          set_diffget_keymaps()
          if vim.wo.diff then
            local git_dir = vim.fn.system("git rev-parse --git-dir 2>/dev/null"):gsub("\n", "")
            local is_rebase = vim.fn.isdirectory(git_dir .. "/rebase-merge") == 1
              or vim.fn.isdirectory(git_dir .. "/rebase-apply") == 1

            local local_branch, remote_branch
            if is_rebase then
              local rebase_dir = vim.fn.isdirectory(git_dir .. "/rebase-merge") == 1
                  and "rebase-merge"
                or "rebase-apply"
              local head_name = vim.fn.readfile(git_dir .. "/" .. rebase_dir .. "/head-name")[1] or ""
              remote_branch = head_name:gsub("refs/heads/", "")
              local onto_hash = (vim.fn.readfile(git_dir .. "/" .. rebase_dir .. "/onto")[1] or ""):gsub("\n", "")
              -- Find local branch pointing at the onto commit
              local_branch = vim.fn.system(
                "git for-each-ref --points-at=" .. onto_hash .. " --format='%(refname:short)' refs/heads/ 2>/dev/null"
              ):gsub("\n", "")
              if local_branch == "" then
                -- Fallback: find the closest branch name
                local_branch = vim.fn.system(
                  "git branch --contains " .. onto_hash .. " --format='%(refname:short)' 2>/dev/null"
                ):gsub("\n.*", "")
              end
              if local_branch == "" then
                local_branch = onto_hash:sub(1, 7)
              end
            else
              local_branch = vim.fn.system("git rev-parse --abbrev-ref HEAD 2>/dev/null"):gsub("\n", "")
              remote_branch = vim.fn.system("git rev-parse --abbrev-ref MERGE_HEAD 2>/dev/null"):gsub("\n", "")
              if vim.v.shell_error ~= 0 then
                remote_branch = "unknown"
              end
            end

            local labels = {
              " LOCAL (" .. local_branch .. ")",
              " BASE",
              " REMOTE (" .. remote_branch .. ")",
              " MERGED",
            }
            for i, win in ipairs(vim.api.nvim_list_wins()) do
              if labels[i] then
                vim.wo[win].winbar = labels[i]
              end
            end
          end
        end,
      })
      -- When diff mode is toggled on later
      vim.api.nvim_create_autocmd("OptionSet", {
        pattern = "diff",
        callback = set_diffget_keymaps,
      })
    end,
  },
}
