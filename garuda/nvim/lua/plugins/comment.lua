return {
  {
    "numToStr/Comment.nvim",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    opts = {},
    config = function()
      require("Comment").setup()
      require("ts_context_commentstring").setup({
        enable_autocmd = false,
      })
    end,
  },
  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
    enabled = vim.fn.has("nvim-0.10.0") == 1,
  },
}
