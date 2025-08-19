-- Using lazy.nvim
return {
  "metalelf0/black-metal-theme-neovim",
  lazy = false,
  priority = 1000,
  config = function()
    -- 2. Setup and load the theme with transparency for the main bg only
    require("black-metal").setup({
      theme = "gorgoroth", -- choose your desired variant
      variant = "dark",
      transparent = true, -- main editor background transparent
      plain_float = false, -- keep floats opaque
      alt_bg = false,   -- no alternate (lighter) background
      term_colors = true, -- use terminal colors
      cursorline_gutter = true,
      dark_gutter = true,
      favor_treesitter_hl = false,
      colored_docstrings = true,
      show_eob = true,
      diagnostics = {
        darker = true,
        undercurl = true,
        background = true,
      },
      code_style = {
        comments = "italic",
        conditionals = "none",
        functions = "none",
        keywords = "none",
        headings = "bold",
        operators = "none",
        keyword_return = "none",
        strings = "none",
        variables = "none",
      },
      plugin = {
        lualine = { bold = true, plain = false },
        cmp = { plain = false, reverse = false },
      },
      colors = {},
      highlights = {},
    })
    require("black-metal").load()

    -- now apply custom highlights
    vim.defer_fn(function()
      local float_bg = "#1d1a23"
      local set_hl = vim.api.nvim_set_hl

      set_hl(0, "NormalFloat", { bg = float_bg })
      set_hl(0, "FloatBorder", { bg = float_bg })

      -- Telescope
      set_hl(0, "TelescopeNormal", { bg = float_bg })
      set_hl(0, "TelescopeBorder", { bg = float_bg })
      set_hl(0, "TelescopePromptNormal", { bg = float_bg })
      set_hl(0, "TelescopePromptBorder", { bg = float_bg })
      set_hl(0, "TelescopeResultsNormal", { bg = float_bg })
      set_hl(0, "TelescopeResultsBorder", { bg = float_bg })
      set_hl(0, "TelescopePreviewNormal", { bg = float_bg })
      set_hl(0, "TelescopePreviewBorder", { bg = float_bg })

      -- Completion menu
      set_hl(0, "Pmenu", { bg = float_bg })
      set_hl(0, "PmenuSel", { bg = "#3e3a45" })
      set_hl(0, "PmenuSbar", { bg = float_bg })
      set_hl(0, "PmenuThumb", { bg = "#5a4e66" })

      -- LSP
      set_hl(0, "LspFloatWinNormal", { bg = float_bg })
      set_hl(0, "LspFloatWinBorder", { bg = float_bg })

      -- Yazi.nvim integration (floating file picker UI)
      set_hl(0, "YaziNormalFloat", { bg = float_bg })
      set_hl(0, "YaziBorder", { bg = float_bg })
      -- Mason floating window + border
      set_hl(0, "MasonNormal", { bg = float_bg })
      set_hl(0, "MasonBorder", { bg = float_bg })

      -- Optional: accent colors (you can tweak)
      set_hl(0, "MasonHeader", { fg = "#9b8d7f", bg = float_bg, bold = true })
      set_hl(0, "MasonHeading", { fg = "#9b8d7f", bg = float_bg, bold = true })

      set_hl(0, "MasonHighlight", { fg = "#9b8d7f", bg = float_bg })
      set_hl(0, "MasonHighlightBlock", { fg = "#222222", bg = "#9b8d7f", bold = true })
      set_hl(0, "MasonHighlightBlockBold", { fg = "#222222", bg = "#9b8d7f", bold = true })
      set_hl(0, "MasonHighlightSecondary", { fg = "#ff9a9e", bg = float_bg })

      -- Cursor highlight overrides
      set_hl(0, "CursorLine", { bg = "#2e2a33" }) -- slightly lighter than float_bg
      set_hl(0, "CursorLineNr", { fg = "#ff9a9e", bg = "#2e2a33", bold = true })
      set_hl(0, "CursorColumn", { bg = "#2e2a33" })

      -- Visual selection (opaque highlight)
      set_hl(0, "Visual", { bg = "#3e3a45" })

      -- Muted/secondary text
      set_hl(0, "MasonMuted", { fg = "#5a4e66", bg = float_bg })
      set_hl(0, "MasonMutedBlock", { fg = "#5a4e66", bg = float_bg })
    end, 10) -- small delay to avoid being overwritten
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        vim.defer_fn(function()
          vim.cmd("lua require('yazi').apply_custom_highlights()")
        end, 10)
      end,
    })
  end,
}
