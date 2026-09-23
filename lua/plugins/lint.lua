return {
  {
    -- The LazyVim Go extra adds "golangci-lint" to mason's ensure_installed,
    -- which reinstalls a build made with an older Go and causes exit code 3.
    -- golangci-lint is managed by Homebrew instead, so strip it from the list.
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      opts.ensure_installed = vim.tbl_filter(function(tool)
        return tool ~= "golangci-lint" and tool ~= "gopls"
      end, opts.ensure_installed)
    end,
  },
  {
    "mfussenegger/nvim-lint",
  opts = {
    events = { "BufWritePost", "BufReadPost", "InsertLeave" },
    -- Filetype → linters
    linters_by_ft = {
      python = { "ruff" },
      go = { "golangcilint" },
    },
    linters = {
      ruff = {
        name = "ruff",
        cmd = "ruff",
        stdin = false,
        args = { "check", "--output-format", "text" },
        stream = "stdout",
        ignore_exitcode = true,
        parser = require("lint.parser").from_errorformat("%f:%l:%c %m", { source = "ruff" }),
      },
      -- golangci-lint uses nvim-lint's built-in definition. It auto-detects the
      -- installed version (v1 vs v2), selects the correct output flag
      -- (--output.json.path for v2), handles standalone files with no go.mod,
      -- and includes a JSON parser. Do not re-define it here.
      },
    },
  },
}
