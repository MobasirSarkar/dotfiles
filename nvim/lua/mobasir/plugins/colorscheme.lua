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
			require("black-metal").setup({
				theme = "dark-funeral", -- sets variant
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
				on_highlights = function(highlights, colors) end,
				colors = {
					bg = "#171418", -- #14 → +7% red & blue
					inactiveBg = "#1d1a23",
					fg = "#c9c0cc",
					floatBorder = "#756e75",
					line = "#252228",
					comment = "#787078",
					builtin = "#afafb9",
					func = "#b89aa4",
					string = "#d1b08f", -- adjusted from duller yellow
					number = "#c8a782",
					property = "#c0b8cf",
					constant = "#b0a8c2",
					parameter = "#b29ab4",
					visual = "#2e2f33",
					error = "#ca7a8f",
					warning = "#cfa774",
					hint = "#9296c2",
					operator = "#929ab2",
					keyword = "#9099ae",
					type = "#a1a4b2",
					search = "#3d465d",
					plus = "#80936d",
					delta = "#cfa774",
				},
			})
			vim.cmd([[colorscheme vague]])
		end,
	},
}
