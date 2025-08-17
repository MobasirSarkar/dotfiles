return {
  "mikavilpas/yazi.nvim",
  dependencies = {
    "MagicDuck/grug-far.nvim",
  },
  event = "VeryLazy",
  keys = {
    -- 👇 in this section, choose your own keymappings!
    {
      -- Open in the current working directory
      "<leader>cw",
      "<cmd>Yazi cwd<cr>",
      desc = "Open the file manager in nvim's working directory",
    },
    {
      -- NOTE: this requires a version of yazi that includes
      -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
      "<leader>e",
      "<cmd>Yazi toggle<cr>",
      desc = "Resume the last yazi session",
    },
  },
  opts = {
    -- if you want to open yazi instead of netrw, see below for more info
    open_for_directories = true,
    keymaps = {
      show_help = "<f1>",
    },
    yazi_floating_window_border = "double",
  },
}
