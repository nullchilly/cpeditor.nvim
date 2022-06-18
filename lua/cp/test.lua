local M = {}
local tabline = require("layout").tabline
local problems = _G.cp_problems
local cur_problem = _G.cp_cur_problem
print(problems, cur_problem)

local function source(s)
	wincmd(P[N].layout[1], s)
end
local function info(s)
	wincmd(P[N].layout[2], s)
end
local function inp(s)
	wincmd(P[N].layout[3], s)
end
local function out(s)
	wincmd(P[N].layout[4], s)
end
local function ans(s)
	wincmd(P[N].layout[5], s)
end

function M.test(t)
  if not problems[cur_problem].result[t] then return end
  info(string.format("e! tests/%d/%d.err", t, t))
  inp(string.format("e! tests/%d/%d.in", t, t))
  out(string.format("e! tests/%d/%d.out", t, t))
  ans(string.format("e! tests/%d/%d.ans", t, t))
  problems[cur_problem].curTest = t
  tabline()
end

function M.insert(t)
  local s = problems[cur_problem]
  s.result[t] = "NA"
  os.execute(string.format("mkdir -p %s/tests/%d", s.problemPath, t))
  test(t) info("w") inp("w") out("w") ans("w")
end

function M.erase(t)
  local s = problems[_G.cp_cur_problem]
  if not t then t = s.curTest end
  os.execute(string.format("rm -r %s/tests/%d", s.problemPath, t))
  s.result[t] = nil
  tabline()
end

function M.hide_show(t)
  local s = problems[_G.cp_cur_problem]
  if not t then t = s.curTest end
  if s.result[t] == "HD" then
    s.result[t] = "NA"
  else
    s.result[t] = "HD"
  end
  tabline()
end

function M.show_all()
  local s = problems[_G.cp_cur_problem]
  for t, v in pairs(s.result) do
    if s.result[t] == "HD" then
      s.result[t] = "NA"
    end
  end
  tabline()
end

function M.invert()
  local s = problems[_G.cp_cur_problem]
  for t, v in pairs(s.result) do
    if s.result[t] == "HD" then
      s.result[t] = "NA"
    else s.result[t] = "HD"
    end
  end
  tabline()
end

function M.hide(stat)
  local s = problems[_G.cp_cur_problem]
  for t, v in pairs(s.result) do
    if v == stat then
      s.result[t] = "HD"
    end
  end
  tabline()
end

function M.run(t)
  local s = problems[_G.cp_cur_problem]
  if t then
    inp("w")
  else
    t = problems[_G.cp_cur_problem].curTest
    for i, _ in pairs(s.result) do
      s.result[i] = "PD"
    end
  end
  s.result[t] = "PD"
  tabline()
  local timer = 0
  local tle = nil
  local job = vim.fn.jobstart(string.format("cd %s && %s < tests/%d/%d.in > tests/%d/%d.out 2> tests/%d/%d.err", s.problemPath, s.lang[3], t, t, t, t, t, t), {
    on_exit = function(_, exitCode, _)
      vim.fn.timer_stop(timer)
      if t == s.curTest then info(string.format("e! tests/%d/%d.err", t, t)) out("e!") end
      if exitCode == 0 then
        local comp = vim.fn.jobstart(string.format("diff -qbB tests/%d/%d.out tests/%d/%d.ans", t, t, t, t), {
          on_exit = function(_, e, _)
            if e == 0 then s.result[t] = "AC"
            else s.result[t] = "WA" end
            tabline()
          end
        })
      else
        if tle then s.result[t] = "TL"
        else s.result[t] = "RE" end
        tabline()
        if t == s.curTest then
          info(string.format("e! tests/%d/%d.err", t, t))
        end
        out("e");
      end
    end
  })
  timer = vim.fn.timer_start(s.timeout, function()
    vim.fn.jobstop(job)
    tle = 1
  end)
end

function M.compile(all)
  local s = problems[_G.cp_cur_problem]
  if all then vim.cmd("wa") else main("w") end
  io.open(string.format("%s/.info", s.problemPath), "w"):close()
  local f = io.open(string.format("%s/.info", s.problemPath), "a")
  f:write("[Compiling...]\n")
  f:flush()
  info("e .info")
  local job = vim.fn.jobstart(s.lang[2] .. " " .. s.lang[1], {
    on_stderr = function(_, data, _)
      for _, d in ipairs(data) do f:write(d .. '\n') end
    end,
    on_exit = function(_, exitCode, _)
      if exitCode == 0 then
        f:write("[Compiled]")
        if all then
          for i, _ in pairs(s.result) do if s.result[i] ~= "HD" then run(i, 0) end end
        end
      else f:write("[Compile Error]") end
      f:close()
      info("e! .info")
    end
  })
end

return M
