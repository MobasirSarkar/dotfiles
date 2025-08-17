local keymaps = vim.keymap

keymaps.set("n", "<leader>l", "<cmd>:Lazy<CR>", { noremap = true, silent = true })
keymaps.set("n", "<leader>*", "<cmd>:wqa<CR>", { noremap = true, silent = true })

keymaps.set({ "n", "v" }, "<leader>y", [["+y]], { noremap = true, silent = true })
keymaps.set("n", "<leader>Y", [["+Y]], { noremap = true, silent = true })

keymaps.set("n", "<C-s>", "<cmd>:w<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true })

keymaps.set("v", "<C-k>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
keymaps.set("v", "<C-j>", ":m '>-2<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>nf", function()
  local cwd = vim.fn.expand("%:p:h") .. "/"
  vim.api.nvim_feedkeys(":edit " .. cwd, "c", false)
end, { noremap = true, silent = false })

keymaps.set("n", "J", "mzJ`z", { noremap = true, silent = true })
keymaps.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
keymaps.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })
keymaps.set("n", "<C-e>", "<cmd>Yazi<CR>", { noremap = true, silent = true })

keymaps.set("n", "<leader><leader>s", "<cmd>source %<CR>", { noremap = true, silent = true })
keymaps.set("x", "<leader>p", [["_dP]], { noremap = true, silent = true })

keymaps.set("n", "<C-e>", "<cmd>Yazi<CR>", { noremap = true, silent = true })

keymaps.set("n", "<leader>db", "<cmd> DapToggleBreakpoint <CR>", { noremap = true, silent = true })
keymaps.set("n", "<leader>dus", function()
  local widgets = require("dap.ui.widgets")
  local sidebar = widgets.sidebar(widgets.scopes)
  sidebar.open()
end, { noremap = true, silent = true })

keymaps.set("n", "<leader>dgt", function()
  require("dap-go").debug_test()
end, { noremap = true, silent = true })

keymaps.set("n", "<leader>dgl", function()
  require("dap-go").debug_last()
end, { noremap = true, silent = true })
