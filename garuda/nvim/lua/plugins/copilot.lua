return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    cmd = { "CopilotChat", "CopilotChatToggle" },
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      "nvim-treesitter/nvim-treesitter",
    },
    build = "make tiktoken",
    opts = {},
    keys = {
      { "<leader>zc", ":CopilotChat<CR>", mode = "n", desc = "Chat with Copilot" },
      { "<leader>ze", ":CopilotChatExplain<CR>", mode = "v", desc = "Explain Code" },
      { "<leader>zr", ":CopilotChatReview<CR>", mode = "v", desc = "Review Code" },
      { "<leader>zf", ":CopilotChatFix<CR>", mode = "v", desc = "Fix code Issues" },
      { "<leader>zo", ":CopilotChatOptimize<CR>", mode = "v", desc = "Optimize Code" },
      { "<leader>zd", ":CopilotChatDocs<CR>", mode = "v", desc = "Generate Docs" },
      { "<leader>zt", ":CopilotChatTest<CR>", mode = "v", desc = "Generate Tests" },
      { "<leader>zm", ":CopilotChatCommit<CR>", mode = "n", desc = "Generate Commit Message" },
      { "<leader>zs", ":CopilotChatCommit<CR>", mode = "v", desc = "Generate Commit for Selection" },
      { "<leader>zv", ":CopilotChatModels<CR>", mode = "n", desc = "Shows Current Models" },
    },
  },
}
