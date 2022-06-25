<h1 align="center">
  <img
    src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png"
    height="30"
    width="0px"
  />
    Competitive programming plugin written in lua
  <img
    src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png"
    height="30"
    width="0px"
  />
</h1>

<p align="center">
    <a href="https://github.com/catppuccin/nvim/stargazers"><img src="https://img.shields.io/github/stars/nullchilly/cpeditor.nvim?colorA=1e1e28&colorB=c9cbff&style=for-the-badge&logo=starship style=for-the-badge"></a>
    <a href="https://github.com/catppuccin/nvim/issues"><img src="https://img.shields.io/github/issues/nullchilly/cpeditor.nvim?colorA=1e1e28&colorB=f7be95&style=for-the-badge"></a>
    <a href="https://github.com/catppuccin/nvim/contributors"><img src="https://img.shields.io/github/contributors/nullchilly/cpeditor.nvim?colorA=1e1e28&colorB=b1e1a6&style=for-the-badge"></a>
</p>

![image](https://user-images.githubusercontent.com/56817415/175784821-77f43e90-be9b-45e4-92a9-78e8aa77d2a1.png)

# Installation

```lua
use {
  'nullchilly/cpeditor.nvim',
  requires = 'nvim-lua/plenary.nvim'
}
```

# Setup

```lua
require("cpeditor").setup {
  integration = {
    bufferline = false, -- Set to true is recommended
    nvim_dap = false, -- Get test input file path
  },

  links = {
    ["local"] = {
      path = "~/code/local",
      name = "${name}"
    },
    ["https://codeforces.com/contest/(%d+)/problem/(%w+)"] = { -- https://codeforces.com/problemset/problem/464/E
      path = "~/code/contest/codeforces/${m1}/${m2}", -- m1 = 464, m2 = E
      name = "${m1}${m2}" -- name = 464E
    },
    ["https://codeforces.com/problemset/problem/(%d+)/(%w+)"] = {
      path = "~/code/contest/codeforces/${m1}/${m2}",
      name = "${m1}${m2}"
    },
  },

  layouts = {
    only = {
      func = function() end,
      order = { 1, 0, 0, 0, 0 },
    },
    split = {
      func = function()
        vim.cmd "set nosplitright | vs | setl wfw | wincmd w | bel sp | vs | vs | 1wincmd w"
      end,
      order = { 1, 2, 3, 4, 5 }, -- main, errors, input, output, expected output
    },
  },
  layout = "split",

  tests_format = {
    input = "tests/${tcnum}/${tcnum}.in",
    output = "tests/${tcnum}/${tcnum}.out",
    answer = "tests/${tcnum}/${tcnum}.ans",
    stderr = "tests/${tcnum}/${tcnum}.err"
  },

  langs = {
    cpp = {
      flags = {
        normal = "-std=c++20 -O2 -DTIMING -DLOCAL -ftree-vectorize -fopt-info-vec",
        debug = "-std=c++20 -g -Wall -Wextra -Wpedantic -Wshadow -Wformat=2 -Wfloat-equal -Wconversion -Wlogical-op -Wshift-overflow=2 -Wduplicated-cond -Wcast-qual -Wcast-align -Wno-variadic-macros -DDEBUG -DLOCAL -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -fsanitize=address -fsanitize=undefined -fno-sanitize-recover -fstack-protector -fsanitize-address-use-after-scope" -- :Cpeditor flag debug
      },
      flag = "normal",
      sources = {
        ["main.cpp"] = {
          compile = "g++ ${flag} main.cpp -o main",
          run = "./main < tests/${tcnum}/${tcnum}.in > tests/${tcnum}/${tcnum}.out 2> tests/${tcnum}/${tcnum}.err"
        },
        -- Stress testing
        ["brute.cpp"] = {
          compile = "g++ ${flag} brute.cpp -o brute",
          run = "./brute < ${input} > ${output} 2> ${stderr}"
        },
        ["gen.cpp"] = {
          compile = "g++ ${flag} -o gen",
          run = "./gen < ${input} > ${output} 2> ${stderr}"
        },
        ["stress.cpp"] = {
          compile = "g++ ${flag} -o stress",
          run = "./stress"
        }
      },
      source = "main.cpp"
    },
    python = {
      ["${pname}.py"] = { -- 464E.py
        compile = [[python -c "import py_compile; py_compile.compile('${pname}.py')"]],
        run = "pypy ${pname.py}"
      }
    },
  },
  lang = "cpp",
}```

# Integrations

- Bufferline
```lua
require("bufferline").setup {
  options = {
    mode = "tabs",
    name_formatter = function(tab)
      local error, problem_name = pcall(function() return vim.api.nvim_tabpage_get_var(tab.tabnr, "cpeditor_problem_name") end)
      if error == false then
        return tab.name
      end
      return problem_name
    end,
    custom_areas = {
      right = function()
        local result = {}
        table.insert(result, {text = require("cpeditor.layout").tabline()})
        return result
      end
    },
  },
}
```

- nvim-dap

# Example keymaps
```lua
vim.keymap.set("n", "<leader>x", "<cmd> tabclose <CR>") --   close tab
vim.keymap.set('n', 't', function()
  vim.cmd("Cpeditor test " .. vim.v.count)
end)
```

# Features (Will update later)

- Problem parser

https://github.com/jmerle/competitive-companion
- Hotkey submit

https://github.com/xalanq/cf-tool
- Debugging

Work in progress
- Stresstest

Work in progress

# Acknowledgement
- https://github.com/p00f/cphelper.nvim My initial motivation to write this plugin
- https://github.com/xeluxee/competitest.nvim For great ideas
- https://github.com/cpeditor/cpeditor For not merging vim support since 2020

<!-- vim:et -->
