# dee-ji's Neovim configuration

A snapshot of my active **LazyVim** setup: Neovim **0.11.3**, 51 locked plugins,
Go and Python development, debugging, snippets, Git tools, and database access.
This is the current LazyVim configuration, not the older NvChad backup.

## What makes up the build

`init.lua` → `lua/config/lazy.lua` → LazyVim defaults + extras in `lazyvim.json`
+ overrides in `lua/plugins/`. `lazy-lock.json` records every plugin revision.

| Component | Configuration / behavior |
| --- | --- |
| Plugin manager / base | lazy.nvim + LazyVim, with Tokyo Night as the default theme |
| UI | Snacks, bufferline, lualine, Noice, which-key, mini.icons |
| Completion / snippets | blink.cmp, mini.snippets, friendly-snippets |
| Navigation | Snacks defaults plus Telescope, Harpoon 2, Flash, Trouble |
| Git | Gitsigns, Fugitive; optional external lazygit |
| Syntax | nvim-treesitter **main** branch, textobjects, autotag |
| Python | Pyright, Ruff LSP, Ruff formatting/linting, venv-selector, debugpy |
| Go | gopls, goimports + gofumpt, golangci-lint, Delve |
| Debugging | nvim-dap, dap-ui, virtual text, Go/Python adapters |
| Other language extras | Docker, JSON, Markdown, SQL, TOML, YAML |
| SQL | Dadbod, Dadbod UI and completion, SQLFluff; bring your own DB CLI/connection |
| Editing | Relative numbers, four-space defaults, 80-column guide, persistent undo, Undotree |

Go indentation and other buffer settings can be overridden by filetype defaults or
EditorConfig. `lua/config/autocmds.lua` is a placeholder; `lua/plugins/example.lua`
is deliberately disabled. `.neoconf.json` and `stylua.toml` are retained from the
original setup. All active configuration files are included, including the local
snippet spec and extra/plugin lock changes that had not yet been committed.

## Prerequisites

The source machine used Intel macOS, Neovim 0.11.3 (LuaJIT), Go 1.26.3,
Node 22.16.0, Python 3.12.6, and had MesloLGS NF fonts installed.
Use a true-color terminal with a Nerd Font selected in its profile.

Required tools: Git, ripgrep (`rg`), `fd`, a C compiler, `make`, `curl`, `tar`,
`unzip`, Node/npm, Python with pip/venv, and Go. Parser builds need
**tree-sitter CLI >= 0.26.1**; the recorded version is 0.26.3.
Optional: lazygit for the Git UI, a browser for Markdown previews, and database
clients such as `psql` or `sqlite3` for the databases you use.

On macOS with Homebrew installed:

```sh
xcode-select --install # only if Command Line Tools are not already installed
brew install git ripgrep fd node python go tree-sitter-cli lazygit
brew install --cask font-meslo-lg-nerd-font
```

These Homebrew commands install currently available tools, not historical versions.
On Linux, install the same tools with your package manager (Debian's `fd-find`
may expose `fdfind`; make `fd` available on PATH). Install Python's venv package
if it is packaged separately. Use a recent Go toolchain for Mason's Go builds.

### Match the Neovim version

Install the archive for your OS/architecture from the official
[Neovim v0.11.3 release](https://github.com/neovim/neovim/releases/tag/v0.11.3).
For Intel macOS, for example:

```sh
mkdir -p "$HOME/.local/opt"
cd "$HOME/.local/opt"
curl -fLO https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-macos-x86_64.tar.gz
xattr -c nvim-macos-x86_64.tar.gz
tar xzf nvim-macos-x86_64.tar.gz
export PATH="$HOME/.local/opt/nvim-macos-x86_64/bin:$PATH"
nvim --version
```

Add that PATH export to your shell startup file. Apple Silicon uses
`nvim-macos-arm64`; Linux uses `nvim-linux-x86_64` or `nvim-linux-arm64` and omits
`xattr`. A plain `brew install neovim` will not reproduce the recorded version.

## Install without replacing your current setup

Use Neovim's `NVIM_APPNAME` to keep this config, plugins, cache, and state separate:

```sh
export NVIM_APPNAME=dee-ji-nvim
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/$NVIM_APPNAME"
data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/$NVIM_APPNAME"
# Use a fresh destination; git clone refuses to overwrite an existing directory.
git clone https://github.com/dee-ji/dee-ji-nvim.git "$config_dir"
mkdir -p "$data_dir/lazy" "$HOME/.vim/undodir"

# Seed the two bootstrap plugins at the recorded revisions BEFORE first startup.
# This avoids importing today's LazyVim defaults with an older plugin lockfile.
git clone https://github.com/folke/lazy.nvim.git "$data_dir/lazy/lazy.nvim"
git -C "$data_dir/lazy/lazy.nvim" checkout 85c7ff3711b730b4030d03144f6db6375044ae82
git clone https://github.com/LazyVim/LazyVim.git "$data_dir/lazy/LazyVim"
git -C "$data_dir/lazy/LazyVim" checkout 28db03f958d58dfff3c647ce28fdc1cb88ac158d
nvim
```

The bootstrap SHAs above correspond to the committed `lazy-lock.json`; if you
intentionally update that file, update these commands too. Wait for lazy.nvim to
install the remaining locked plugins. Run `:Lazy restore`, wait for completion,
and restart. [Restore uses the lockfile](https://lazy.folke.io/usage/lockfile);
`:Lazy update` and `:Lazy sync` are upgrade operations, not snapshot restoration.

Always launch this profile with `NVIM_APPNAME=dee-ji-nvim nvim` (or keep the export
in your shell). The custom undo directory is still shared at `~/.vim/undodir`.
To make this your default `nvim`, first back up existing config, data, state, and
cache directories, then follow the same commands with `NVIM_APPNAME=nvim`.
Do not copy over your existing directories in place.

## Install language tools and parsers

Open `:Mason` and wait for automatic installs to finish. For the tool versions
recorded on the source machine, run these commands inside Neovim:

```vim
:MasonInstall debugpy@1.8.19 delve@v1.26.0 gofumpt@v0.9.2 goimports@v0.40.0
:MasonInstall golangci-lint@v2.7.2 gopls@v0.21.0 hadolint@v2.14.0
:MasonInstall lua-language-server@3.16.1 markdown-toc@1.2.0 markdownlint-cli2@0.20.0
:MasonInstall pyright@1.1.407 ruff@0.14.9 shfmt@v3.12.0 sqlfluff@3.5.0
:MasonInstall stylua@v2.3.1 tree-sitter-cli@v0.26.3
```

Mason's registry and upstream release availability are external dependencies.
These versions were extracted from installed Mason receipts, not guessed from
plugin versions. Mason executables are added to Neovim's PATH. These commands
are explicit version requests, not an automatically enforced Mason lockfile.

After installs finish, restart Neovim and run `:TSUpdate`. Opening a file triggers
installation of missing configured parsers. The syntax list covers Bash, C, Go,
Python, JS/TS/TSX, Rust, Lua, HTML/XML, JSON/JSONC, Markdown, TOML, YAML, Vim, and
support grammars; extras add Go module/workspace, Docker, SQL, and Python grammars.
Rust highlighting does not imply a configured Rust language server.

Open Go files inside a module (`go.mod`) and Python files inside their project.
Use `:VenvSelect` to choose a project virtualenv; install project dependencies
separately. For Markdown preview, use `:MarkdownPreview`; if its build failed,
run `:Lazy build markdown-preview.nvim` and inspect its output.

## Useful mappings

`<leader>` is **Space**. These are custom mappings; press Space and wait for
which-key to discover the inherited LazyVim mappings.

| Mapping | Action |
| --- | --- |
| `<leader>pf` | Telescope find files |
| literal `C-p` | Telescope Git files (this is NOT Ctrl-P; retained as configured) |
| `<leader>ps` | Telescope prompted text search |
| `<leader>pv` | Netrw / `:Ex` |
| `<leader>gs` | Fugitive Git status |
| `<leader>ut` | Toggle undo tree |
| `<leader>y`, `<leader>Y` | Copy to system clipboard |
| `<leader>p` in visual mode | Paste without replacing the yank register |
| `<leader>d` | Delete without replacing the yank register |
| `J` / `K` in visual mode | Move selected lines |
| Ctrl-D / Ctrl-U | Scroll and center cursor |
| `<leader>ee`, `ea`, `ef`, `el` | Insert Go error-handling templates |
| `<leader>zig` | Restart LSP clients |
| `<leader>cv` in Python | Choose virtualenv |
| `<leader>D` | Toggle database UI |

## Snapshot caveats

This preserves the source configuration's behavior rather than silently redesigning
it. One first-install correction was made: Telescope is required inside its key
callbacks, after installation, instead of while reading its plugin spec.

- `tmux-sessionizer`, `vim-with-me`, and `cellular-automaton` were referenced by
  mappings but are not installed/configured in this snapshot. Ctrl-F, Alt-H,
  Alt-Shift-H, `<leader>vwm`, `<leader>svwm`, and the global `<leader>ca` animation
  mapping need those dependencies or removal. LSP buffers may override `<leader>ca`
  with code actions. No sessionizer script was found on PATH.
- The snippet spec puts options outside `opts`, so its overrides are ignored;
  the enabled LazyVim mini-snippets extra supplies the working setup instead.
- The custom LSP `opts` function replaces inherited server options, so enabled
  language extras do not guarantee all of their language servers are enabled.
  Its gopls settings are at the server-table level instead of
  `settings.gopls`; those intended Go settings are not transmitted as LSP settings.
- The custom Ruff lint command uses `--output-format text`, which newer Ruff
  versions reject. Ruff LSP and Conform formatting are separate paths. The
  `golangclilint` override is misspelled and unused; the configured
  `golangcilint` uses nvim-lint's built-in definition instead.
- `<leader><leader>` sources the current file, and `<leader>x` runs `chmod +x`
  using the original unquoted filename command. Review those before using them
  on arbitrary files. Several custom keys also replace LazyVim default prefixes.
- Optional prettier, extra language servers, DB clients, and project-specific
  dependencies are not all present in the source machine's Mason inventory.
  Install/configure them if you need the corresponding features.

Plugin commits are pinned; OS packages, fonts, language-tool transitive dependencies,
and platform-specific parser builds are not a bit-for-bit system image. The
old NvChad backups, downloaded plugins, binaries, sessions, undo history, logs,
and database connection state are intentionally not part of this repository.

## Verify and maintain

Validated on Intel macOS with Neovim 0.11.3: an isolated profile starts with
all 51 plugin revisions matching the lockfile and the Tokyo Night Moon theme.
Language tools, parser builds, and interactive debugger workflows were not
fully exercised.

From this repository:

```sh
nvim --headless -u NONE -l tests/config.lua
```

That check validates Lua syntax and the Telescope first-install regression without
requiring any plugins. In the installed profile, run `:checkhealth`, `:Lazy`,
`:Mason`, `:LspInfo`, and `:ConformInfo`. Open a Go and Python project to check
language-server attachment, formatting, linting, and debugger setup independently.
A successful editor startup does not validate every external integration.

To update intentionally, use `:Lazy update`, test your projects, then commit the
new `lazy-lock.json`. Keep `lazyvim.json` in Git when changing extras. Update this
README's bootstrap SHAs and tool versions when capturing a new snapshot.

Based on the LazyVim starter; its Apache-2.0 `LICENSE` is retained.
