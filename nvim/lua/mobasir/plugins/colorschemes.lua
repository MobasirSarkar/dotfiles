return {
    {
        "glepnir/oceanic-material",
        lazy = false,
        priority = 1000,
        config = function()
            local ui = vim.g
            ui.oceanic_material_allow_italic = 1
            ui.oceanic_material_allow_underline = 1
            ui.oceanic_material_transparent_background = 1
            ui.oceanic_material_background = "ocean"
            ui.oceanic_material_allow_undercurl = 1
            ui.oceanic_material_allow_bold = 1
        end,
    },
    {
        "ellisonleao/gruvbox.nvim",
    },
    {
        "sainnhe/gruvbox-material",
        config = function()
            vim.g.gruvbox_material_background = "hard"
            vim.g.gruvbox_material_transparent_background = 2
        end,
    },
    {
        "Tsuzat/NeoSolarized.nvim",
        lazy = false,
        priority = 1000,
        options = {
            style = "dark",
            transparent = true,
            enable_italics = true,
            styles = {
                comments = { italic = true },
                keywords = { bold = true },
                functions = { italic = true },
                variables = {},
                string = { italic = true },
                underline = true,
                undercurl = true,
            },
        },
        config = function()
            require("NeoSolarized").setup()
        end,
    },
    {
        "neanias/everforest-nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("everforest").setup({
                background = "hard",
                transparent_background_level = 1,
                italics = true,
                ui_contrast = "high",
                diagnostic_virtual_text = "colored",
            })
        end,
    },
    {
        "craftzdog/solarized-osaka.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            style = "dark",
            transparent = true,
            enable_italics = true,
            styles = {
                comments = { italic = true },
                keywords = { bold = true },
                functions = { italic = true },
                variables = {},
                string = { italic = true },
                underline = true,
                undercurl = true,
            },
        },
        config = function()
            require("solarized-osaka").setup()
        end,
    },
    {
        "HoNamDuong/hybrid.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
        config = function()
            require("hybrid").setup({
                terminal_colors = true,
                undercurl = true,
                underline = true,
                bold = true,
                italic = {
                    strings = false,
                    emphasis = true,
                    comments = true,
                    folds = true,
                },
                strikethrough = true,
                inverse = true,
                transparent = true,
            })
        end,
    },
    {
        "sho-87/kanagawa-paper.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
        config = function()
            require("kanagawa-paper").setup({
                undercurl = true,
                transparent = true,
                commentStyle = { italic = true },
                functionStyle = { italic = true },
                color_offset = {
                    canvas = { brightness = 1, saturation = 1 },
                },
            })
        end,
    },
    {
        "AlexvZyl/nordic.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("nordic").setup({
                bold_keywords = false,
                italic_comments = true,
                transparent = {
                    bg = false,
                    float = false,
                },
            })
        end,
    },
    {
        "rose-pine/neovim",
        lazy = false,
        priority = 1000,
        config = function()
            require("rose-pine").setup({
                variant = "moon",
                dark_variant = "moon",
                styles = {
                    transparency = true,
                    italic = true,
                },
                highlight_groups = {
                    NormalFloat = { bg = "base", blend = 0 }, -- Set background for floating windows
                    Pmenu = { bg = "base" },
                    PmenuSel = { bg = "overlay", fg = "love" },
                    PmenuBorder = { bg = "base", fg = "highlight_high" },
                    TelescopeBorder = { fg = "highlight_high", bg = "base" },
                    TelescopeNormal = { bg = "base" },
                    TelescopePromptNormal = { bg = "base" },
                    TelescopeResultsNormal = { fg = "subtle", bg = "base" },
                    TelescopeSelection = { fg = "text", bg = "base" },
                },
            })
        end,
    },
    {
        "talha-akram/noctis.nvim",
        lazy = false,
        priority = 1000,
        config = function() end,
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            style = "storm",
            transparent = true,
            styles = { sidebars = "transparent" },
        },

        config = function(_, opts)
            require("tokyonight").setup(opts)
        end,
    },
    {
        "rebelot/kanagawa.nvim",
        lazy = true,
        priority = 1000,
        config = function()
            -- Default options:
            require("kanagawa").setup({
                compile = true, -- enable compiling the colorscheme
                undercurl = true, -- enable undercurls
                commentStyle = { italic = true },
                functionStyle = {},
                keywordStyle = { italic = true },
                statementStyle = { bold = true },
                typeStyle = {},
                transparent = true, -- do not set background color
                dimInactive = false, -- dim inactive window `:h hl-NormalNC`
                terminalColors = true, -- define vim.g.terminal_color_{0,17}
                theme = "dragon", -- Load "wave" theme
                background = { -- map the value of 'background' option to a theme
                    dark = "dragon", -- try "dragon" !
                    light = "lotus",
                },
            })
        end,
    },
    -- Using lazy.nvim
    {
        "metalelf0/black-metal-theme-neovim",
        lazy = false,
        priority = 1000,
        config = function()
            -- 2. Setup and load the theme with transparency for the main bg only
            require("black-metal").setup({
                theme = "taake", -- choose your desired variant
                variant = "dark",
                transparent = true, -- main editor background transparent
                plain_float = true, -- keep floats opaque
                alt_bg = false, -- no alternate (lighter) background
                term_colors = true, -- use terminal colors
                cursorline_gutter = true,
                dark_gutter = false,
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
            end, 10) -- small delay to avoid being overwritten
            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = function()
                    vim.defer_fn(function()
                        vim.cmd("lua require('yazi').apply_custom_highlights()")
                    end, 10)
                end,
            })
        end,
    },

    {
        "vague2k/vague.nvim",
        lazy = false, -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other plugins
        config = function()
            require("vague").setup({
                transparent = true,
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
