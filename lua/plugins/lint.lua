return {
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
      golangclilint = {
        name = "golangclilint",
        cmd = "golangci-lint",
        stdin = false,
        args = {
          "run",
          "--out-format",
          "json",
          "--issues-exit-code=1",
          "./...",
        },
        stream = "stdout",
        ignore_exitcode = true,
      },
    },
  },
}
