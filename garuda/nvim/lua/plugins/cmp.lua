local kind_icons = {
  Text = "󰉿",
  Method = "󰆧",
  Function = "󰊕",
  Constructor = "",
  Field = "󰜢",
  Variable = "󰀫",
  Class = "󰠱",
  Interface = "",
  Module = "",
  Property = "󰜢",
  Unit = "󰑭",
  Value = "󰎠",
  Enum = "",
  Keyword = "󰌋",
  Snippet = "",
  Color = "󰏘",
  File = "󰈙",
  Reference = "󰈇",
  Folder = "󰉋",
  EnumMember = "",
  Constant = "󰏿",
  Struct = "󰙅",
  Event = "",
  Operator = "󰆕",
  TypeParameter = "󰊄",
}

return {
  "Saghen/blink.cmp",
  dependencies = {
    "rafamadriz/friendly-snippets",
    { "nvim-mini/mini.nvim", version = false },
    { "nvim-mini/mini.icons", version = false },
    "onsails/lspkind.nvim",
  },
  version = "1.*",
  --@module 'blink.cmp'
  --@type blink.cmp.config
  opts = {
    keymap = {
      preset = "none",

      ["<C-n>"] = { "select_next" },
      ["<C-p>"] = { "select_prev" },
      ["<C-y>"] = { "accept" },
    },
    signature = { enabled = true },
    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
        window = {
          border = "rounded",
          winblend = 0,
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          max_width = 80,
          max_height = 20,
        },
      },
      menu = {
        enabled = true,
        scrollbar = true,
        winblend = 0,
        min_width = 30,
        max_height = 12,
        border = "rounded",
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
        draw = {
          padding = { 1, 2 },
          gap = 2,
          columns = {
            { "kind_icon", gap = 1 },
            { "label", gap = 1 },
            { "label_description", gap = 1 },
            { "kind", gap = 1 },
          },
          components = {
            kind_icon = {
              text = function(ctx)
                return kind_icons[ctx.kind] or "󰈚"
              end,
              highlight = function(ctx)
                return "CmpItemKind" .. ctx.kind
              end,
              width = { fixed = 2 },
            },
            label = {
              width = { fill = true, max = 30 },
              highlight = "CmpItemAbbr",
            },
            label_description = {
              width = { fill = true, max = 20 },
              highlight = "CmpItemAbbrDeprecated",
            },
            kind = {
              text = function(ctx)
                return ctx.kind
              end,
              highlight = function(ctx)
                return "CmpItemKind" .. ctx.kind
              end,
              width = { fill = true, max = 12 },
            },
          },
        },
      },
      -- Additional UI improvements
      ghost_text = {
        enabled = false,
      },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      per_filetype = {
        sql = { "snippets", "dadbod", "buffer" },
      },
      providers = {
        dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
      },
    },
  },
  opts_extend = { "sources.default" },
}
