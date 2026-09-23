-- Modified for fresh installs: load Telescope only when a mapping is used.
-- plugins/telescope.lua:
return {
  "nvim-telescope/telescope.nvim",
  tag = "v0.2.0",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>pf", function() require("telescope.builtin").find_files() end, desc = "Telescope find files" },
    { "C-p", function() require("telescope.builtin").git_files() end, desc = "Telescope find git files" },
    {
      "<leader>ps",
      function()
        require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") })
      end,
      desc = "Telescope grep search",
    },
  },
}
