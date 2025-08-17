return {
  "norcalli/nvim-colorizer.lua",
  lazy = true,
  config = function()
    require("colorizer").setup({
      "*",
      css = { rgb_fn = true },
    })
  end,
}
