return {
    "Saghen/blink.cmp",
    dependencies = {
        "rafamadriz/friendly-snippets",
        { "echasnovski/mini.nvim",  version = false },
        { "echasnovski/mini.icons", version = false },
    },
    version = "1.*",
    --@module 'blink.cmp'
    --@type blink.cmp.config
    opts = {
        keymap = { preset = "default" },
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
                    -- Better padding: left, right (increased from 3,3)
                    padding = { 1, 2 },
                    -- Gap between columns for better separation
                    gap = 2,
                    -- Reorganized columns with explicit spacing
                    columns = {
                        { "kind_icon",         gap = 1 },
                        { "label",             gap = 1 },
                        { "label_description", gap = 1 },
                        { "kind",              gap = 1 },
                    },
                    components = {
                        kind_icon = {
                            text = function(ctx)
                                local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                                return kind_icon or "●"
                            end,
                            highlight = function(ctx)
                                local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                                return hl
                            end,
                            -- Add fixed width for consistent alignment
                            width = { fixed = 2 },
                        },
                        label = {
                            width = { fill = true, max = 30 },
                            -- Add custom highlight for better visibility
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
                                local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                                return hl
                            end,
                            width = { fill = true, max = 12 },
                        },
                    },
                },
            },
            -- Additional UI improvements
            ghost_text = {
                enabled = true,
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
