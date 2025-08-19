local function augroup(name)
	return vim.api.nvim_create_augroup("mobasir_" .. name, { clear = true })
end

--[[ vim.api.nvim_create_autocmd("VimEnter", {
   callback = function(data)
      if data.file and vim.fn.isdirectory(data.file) == 1 then
         vim.schedule(function()
            local ok, yazi = pcall(require, "yazi")
            if ok then
               yazi.yazi() -- this is the actual function in yazi.nvim
            else
               vim.notify("Yazi not found", vim.log.levels.ERROR)
            end
         end)
      end
   end,
}) ]]

-- Auto-create missing directories on save
vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function(event)
		local file = event.match
		local dir = vim.fn.fnamemodify(file, ":p:h")
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, "p")
		end
	end,
})

-- Check if we need to reload the file when it changed
--
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup("checktime"),
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd("checktime")
		end
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		(vim.hl or vim.highlight).on_yank()
	end,
})

-- make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("man_unlisted"),
	pattern = { "man" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
	end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("wrap_spell"),
	pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
	group = augroup("json_conceal"),
	pattern = { "json", "jsonc", "json5" },
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
