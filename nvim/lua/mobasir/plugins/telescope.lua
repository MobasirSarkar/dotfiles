-- telescope.nvim
return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
			"jvgrootveld/telescope-zoxide",
			"nvim-telescope/telescope-ui-select.nvim",
		},
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				defaults = {
					border = {
						prompt = { 1, 1, 1, 1 },
						results = { 1, 1, 1, 1 },
						preview = { 1, 1, 1, 1 },
					},
					borderchars = {
						prompt = { " ", " ", "─", "│", "│", " ", "─", "└" },
						results = { "─", " ", " ", "│", "┌", "─", " ", "│" },
						preview = { "─", "│", "─", "│", "┬", "┐", "┘", "┴" },
					},
				},
				extensions = {
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					},
				},
				pickers = {
					colorscheme = { enable_preview = true },
					find_files = {
						hidden = true,
						find_command = {
							"rg",
							"--files",
							"--hidden",
							"--glob",
							"!{.git/*,.next/*,.svelte-kit/*,target/*,node_modules/*,.zig-cache/*}",
							"--path-separator",
							"/",
						},
					},
				},
			})

			pcall(telescope.load_extension, "fzf")
			pcall(telescope.load_extension, "zoxide")
			pcall(telescope.load_extension, "ui-select")

			local builtin = require("telescope.builtin")

			-- ✅ Just use the global picker config
			vim.keymap.set("n", "<leader>o", builtin.find_files, {})
			vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
			vim.keymap.set("n", "<leader>fd", builtin.diagnostics, {})
			vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols, {})
			vim.keymap.set("n", "<leader>ws", builtin.lsp_workspace_symbols, {})
			vim.keymap.set("n", "<leader>fz", ":Telescope zoxide list<CR>", {})
			vim.keymap.set("n", "<leader>fv", builtin.help_tags, {})
		end,
	},
}
