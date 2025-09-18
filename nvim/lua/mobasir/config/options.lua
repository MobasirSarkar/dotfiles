vim.g.snacks_animate = true

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 30
vim.o.clipboard = "unnamedplus"
vim.o.winborder = "rounded"
vim.o.termguicolors = true

local opts = vim.opt

opts.nu = true
opts.relativenumber = true

opts.autoindent = true

opts.tabstop = 4
opts.shiftwidth = 4
opts.list = false
opts.softtabstop = 4
opts.expandtab = true
opts.smarttab = true
opts.background = "dark"

opts.hlsearch = false
opts.incsearch = true

opts.ignorecase = true
opts.smartcase = true

opts.lazyredraw = false
opts.linebreak = true
opts.wrap = false

opts.laststatus = 2
opts.ruler = true
opts.mouse = "a"

opts.title = true
opts.cursorline = true
opts.history = 1000

opts.spell = true
opts.signcolumn = "yes"

opts.hidden = true

opts.backspace = { "start", "indent", "eol" }
opts.scrolloff = 8

opts.fillchars = { eob = " " }

opts.swapfile = false

opts.pumblend = 10
opts.pumheight = 10

if vim.fn.has("nvim-0.10") == 1 then
	opts.smoothscroll = true
	opts.foldtext = ""
else
	opts.foldmethod = "indent"
	opts.foldtext = "v:lua.require'mobasir.util'.ui.foldtext()"
end

vim.g.markdown_recommended_style = 0
