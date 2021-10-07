# cp.nvim

neovim plugin for cp

# Features

- Problem parser (https://github.com/jmerle/competitive-companion)
- Multiple problem
- Extensive multitest
- Hotkey submit
- Stresstest
- Terminal intergration
- GDB support (https://github.com/puremourning/vimspector)

Note: To see all the available functions use

```
:Cp help()
```

# Install

```lua
use 'tuwuna/cp.nvim'
```

# Setup

```lua
require'cp'.setup {
  autostart_arg = 'cp',
  layouts = {
    {"", {0, 0, 0, 0, 0}},
    {"set nosplitright | vs | setl wfw | wincmd w | bel sp | vs | vs | 1wincmd w", {1, 2, 3, 4, 5}},
    {"execute 'NvimTreeToggle' | set nosplitright | 2wincmd w | vs | setl wfw | wincmd w | bel sp | sp | sp | 2wincmd w", {2, 3, 4, 5, 6}},
  }, layout = 2,
  links = {
    {"https://codeforces.com/contest/$/problem/$", vim.loop.os_homedir() .. "/code/contest/codeforces/$/$"},
    {"https://codeforces.com/problemset/problem/$/$", vim.loop.os_homedir() .. "/code/contest/codeforces/$/$"},
    {"https://atcoder.jp/contests/$/tasks/$", vim.loop.os_homedir() .. "/code/contest/atcoder/$/$"},
    {"https://www.codechef.com/problems/$", vim.loop.os_homedir() .. "/code/single/codechef/$"}
  },
  locals = {vim.loop.os_homedir() .. "/code/local", 1000},
  langs = {
    cpp = {"sol.cpp", "g++ -Wall -O2", "./a.out"},
    python = {"sol.py", [[python -c "import py_compile; py_compile.compile('sol.py')"]], "python sol.py"},
    pypy = {"sol.py", [[python -c "import py_compile; py_compile.compile('sol.py')"]], "pypy sol.py"},
  }, sol = "cpp", brute = "pypy", gen = "python",
  templates = vim.loop.os_homedir() .. "/code/templates/cp",
}

local colors = {
  HD = {"#ffffff", "#000000", "#ffffff", "#000000"},
  NA = {"#ffffff", "#ABB2BF", "#000000", "#ABB2BF"},
  PD = {"#C678DD", "#ffffff", "#000000", "#ABB2BF"},
  AC = {"#ffffff", "#98C379", "#000000", "#98C379"},
  WA = {"#ffffff", "#E06C75", "#000000", "#E06C75"},
  RE = {"#ffffff", "#61AFEF", "#000000", "#61AFEF"},
  TL = {"#ffffff", "#E5C07B", "#000000", "#E5C07B"},
  FL = {"#000000", "NONE", "#000000", "#000000"}
}

local res = "autocmd ColorSCheme * "
for verdict, colors in pairs(colors) do
  res = res .. "hi " .. verdict .. " guifg=" .. colors[1] .. " guibg=" .. colors[2] .. " | "
  res = res .. "hi f" .. verdict .. " guifg=" .. colors[3] .. " guibg=" .. colors[4] .. " | "
end
vim.cmd(res)

vim.api.nvim_set_keymap('n', '<A-D>', ":lua require'cp'.remove()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-c>', ":lua require'cp'.compile()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-r>', ":lua require'cp'.run()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-a>', ":lua require'cp'.compile(0)<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 't', ":<C-u>call CpTest(v:count, 1, 'l', 0)<CR>", { noremap = true, silent = true })
vim.cmd("function CpAdd(...)\nexecute 'Cp insert(' . v:count . ')'\nendfunction")
vim.api.nvim_set_keymap('n', 'A', ':<C-u>call CpAdd()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-b>', ":lua require'cp'.erase()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-s>', ":lua require'cp'.hide_show()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-m>', ":lua require'cp'.show_all()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-o>', ":lua require'cp'.hide('AC')<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-i>', ":lua require'cp'.invert()<CR>", { noremap = true, silent = true })
for i = 1, 9 do vim.api.nvim_set_keymap('n', '<A-' .. i .. '>', ":lua require'cp'.tab(" .. i .. ")<CR>", { noremap = true, silent = true }) end
```
