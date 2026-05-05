return {
  -- Using Lazy
  {
    "navarasu/onedark.nvim",
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("onedark").setup({
        style = "deep",
        transparent = true,
      })
      vim.cmd([[colorscheme onedark]])
    end,
  },
  {
    "vague2k/vague.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other plugins
    config = function()
      require("vague").setup({
        transparent = false,
        plugins = {
          cmp = {
            match = "bold",
            match_fuzzy = "bold",
          },
          dashboard = {
            footer = "italic",
          },
          lsp = {
            diagnostic_error = "bold",
            diagnostic_hint = "none",
            diagnostic_info = "italic",
            diagnostic_ok = "none",
            diagnostic_warn = "bold",
          },
          neotest = {
            focused = "bold",
            adapter_name = "bold",
          },
          telescope = {
            match = "bold",
          },
        },
        on_highlights = function(highlights, colors) end,
        colors = {
          bg = "#141415",
          inactiveBg = "#1a1a1d",
          fg = "#c0c0c0",
          floatBorder = "#6e6e6e",
          line = "#202027",
          comment = "#5a5a68",
          builtin = "#9bb3af",
          func = "#b28c8c",
          string = "#bfa98a", -- softer beige, less “banana yellow”
          number = "#b6936a", -- muted tan
          property = "#b8b8c6",
          constant = "#a4a4bb",
          parameter = "#a98fa9",
          visual = "#2c2f30",
          error = "#c06a7a",
          warning = "#c7a472", -- toned-down ochre, not neon
          hint = "#7a8db8",
          operator = "#8994a3",
          keyword = "#6a8399",
          type = "#8ea3a9",
          search = "#38404e",
          plus = "#6d8a63",
          delta = "#c7a472", -- reusing dull ochre
        },
      })
    end,
  },
}
