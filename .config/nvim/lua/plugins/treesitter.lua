return {
  { "nvim-treesitter/playground", cmd = "TSPlaygroundToggle" },

  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    main = "nvim-treesitter.configs", -- Lazy will do: require(main).setup(opts)
    opts = {
      ensure_installed = {
        "astro",
        "cmake",
        "cpp",
        "css",
        "fish",
        "gitignore",
        "go",
        "graphql",
        "http",
        "java",
        "php",
        "rust",
        "scss",
        "sql",
        "svelte",
        -- add these so playground/linter & MDX fallback behave well
        "markdown",
        "markdown_inline",
        "query",
      },

      -- https://github.com/nvim-treesitter/playground#query-linter
      query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { "BufWrite", "CursorHold" },
      },

      playground = {
        enable = true,
        disable = {},
        updatetime = 25,
        persist_queries = true,
        keybindings = {
          toggle_query_editor = "o",
          toggle_hl_groups = "i",
          toggle_injected_languages = "t",
          toggle_anonymous_nodes = "a",
          toggle_language_display = "I",
          focus_language = "f",
          unfocus_language = "F",
          update = "R",
          goto_node = "<cr>",
          show_help = "?",
        },
      },
    },

    -- no config() — keep MDX setup here; it doesn't require treesitter to be loaded
    init = function()
      vim.filetype.add({ extension = { mdx = "mdx" } })
      pcall(function()
        -- fallback: use markdown parser for mdx unless you install a real mdx parser
        vim.treesitter.language.register("markdown", "mdx")
      end)
    end,
  },
}
