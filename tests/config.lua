-- Run from the repository: nvim --headless -u NONE -l tests/config.lua
local files = vim.fn.glob('lua/**/*.lua', false, true)
table.insert(files, 'init.lua')
for _, file in ipairs(files) do
  assert(loadfile(file), 'Invalid Lua: ' .. file)
end
local lock = vim.json.decode(table.concat(vim.fn.readfile('lazy-lock.json'), '\n'))
assert(lock.LazyVim and lock['lazy.nvim'])
-- A clean machine must be able to read specs before plugins exist.
package.preload['telescope.builtin'] = function()
  error('Telescope loaded before installation')
end
local spec = dofile('lua/plugins/telescope.lua')
assert(spec[1] == 'nvim-telescope/telescope.nvim')
local calls = 0
package.preload['telescope.builtin'] = function()
  return { find_files = function() calls = calls + 1 end, git_files = function() calls = calls + 1 end }
end
spec.keys[1][2]()
spec.keys[2][2]()
assert(calls == 2, 'Telescope mappings must dispatch when invoked')
print('Config syntax, lockfile, and first-install Telescope checks passed')
