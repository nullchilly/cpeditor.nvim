P = {}
N = now

function wincmd(index, cmd)
  if index == 0 then return end
  local i = vim.fn.winnr()
  vim.cmd(index .. "wincmd w")
  vim.cmd(cmd)
  vim.cmd(i .. "wincmd w")
end

function main(s) wincmd(P[N].layout[1], s) end
function info(s) wincmd(P[N].layout[2], s) end
function inp(s) wincmd(P[N].layout[3], s) end
function out(s) wincmd(P[N].layout[4], s) end
function ans(s) wincmd(P[N].layout[5], s) end

function layout(index, new)
  local s = P[N]
  if not new then vim.cmd("wa | only") end
  vim.cmd(C.layouts[index][1])
  s.layout = C.layouts[index][2]
  main("e!" .. s.lang[1])
  info("e! .info | w | set ft=" .. C.sol)
  test(s.curTest)
end

function lang(L, first)
  local s = P[N]
  s.lang = C.langs[L]
  if not first then main("e!" .. s.lang[1]) end
end

function tabline()
  local res = ""
  for i, v in ipairs(P) do
    if N == i then res = res .. "%#fNA#"
    else res = res .. "%#NA#" end
    res = res .. "%" .. i .. "@CpTab@ " .. v.name .. " "
  end
  res = res .. "%#FL#%T%="
  s = P[N]
  for i, v in pairs(s.result) do
    res = res .. "%#"
    if i == s.curTest then res = res .. "f" end
    res = res .. v .. "#"
    res = res .. "%" .. i .. "@CpTest@"
    res = res .. " " .. i .. " "
  end
  vim.o.tabline = res
end

function test(t)
  if not P[N].result[t] then return end
  info(string.format("e! tests/%d/%d.err", t, t))
  inp(string.format("e! tests/%d/%d.in", t, t))
  out(string.format("e! tests/%d/%d.out", t, t))
  ans(string.format("e! tests/%d/%d.ans", t, t))
  P[N].curTest = t
  tabline()
end

function insert(t)
  local s = P[N]
  s.result[t] = "NA"
  os.execute(string.format("mkdir -p %s/tests/%d", s.problemPath, t))
  test(t) info("w") inp("w") out("w") ans("w")
end

function erase(t)
  local s = P[N]
  if not t then t = s.curTest end
  os.execute(string.format("rm -r %s/tests/%d", s.problemPath, t))
  s.result[t] = nil
  tabline()
end

function hide_show(t)
  s = P[N]
  if not t then t = s.curTest end
  if s.result[t] == "HD" then
    s.result[t] = "NA"
  else
    s.result[t] = "HD"
  end
  tabline()
end

function show_all()
  s = P[N]
  for t, v in pairs(s.result) do
    if s.result[t] == "HD" then
      s.result[t] = "NA"
    end
  end
  tabline()
end

function invert()
  s = P[N]
  for t, v in pairs(s.result) do
    if s.result[t] == "HD" then
      s.result[t] = "NA"
    else s.result[t] = "HD"
    end
  end
  tabline()
end

function hide(stat)
  s = P[N]
  for t, v in pairs(s.result) do
    if v == stat then
      s.result[t] = "HD"
    end
  end
  tabline()
end

function run(t)
  if t then
    inp("w")
  else
    t = P[N].curTest
    for i, _ in pairs(s.result) do
      s.result[i] = "PD"
    end
  end
  s.result[t] = "PD"
  tabline()
  local s = P[N]
  io.open(string.format("%s/tests/%d/%d.err", s.problemPath, t, t), "w"):close()
  io.open(string.format("%s/tests/%d/%d.out", s.problemPath, t, t), "w"):close()
  local stdout = io.open(string.format("%s/tests/%d/%d.out", s.problemPath, t, t), "a")
  local stderr = io.open(string.format("%s/tests/%d/%d.err", s.problemPath, t, t), "a")
  local timer = vim.fn.timer_start(s.timeout, function() s.result[t] = "TL" tabline() end)
  local job = vim.fn.jobstart(s.lang[3], {
    on_stderr = function(_, data, _)
      for _, d in ipairs(data) do stderr:write(d .. "\n") end
    end,
    on_stdout = function(_, data, _)
      for _, d in ipairs(data) do stdout:write(d .. "\n") end
    end,
    on_exit = function(_, exitCode, _)
      stderr:close()
      stdout:close()
      if t == s.curTest then info(string.format("e! tests/%d/%d.err", t, t)) out("e!") end
      if exitCode == 0 then
        vim.fn.timer_stop(timer)
        local comp = vim.fn.jobstart(string.format("diff -qbB tests/%d/%d.out tests/%d/%d.ans", t, t, t, t), {
          on_exit = function(_, e, _)
            if e == 0 then s.result[t] = "AC"
            else s.result[t] = "WA" end
            tabline()
          end
        })
      else
        s.result[t] = "RE"
        tabline()
      end
    end
  })
  local input = io.open(string.format("%s/tests/%d/%d.in", s.problemPath, t, t), "r")
  vim.fn.chansend(job, input:read("*all")) input.close()
end

function compile(all)
  local s = P[N]
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
          for i, _ in pairs(s.result) do run(i, 0) end
        end
      else f:write("[Compile Error]") end
      f:close()
      info("e! .info")
    end
  })
end

function build(tests)
  local s = P[N]
  lang(C.sol, 0)
  os.execute(string.format("mkdir -p %s/tests", s.problemPath))
  os.execute(string.format("cp %s/%s %s/%s", C.templates, s.lang[1], s.problemPath, s.lang[1]))
  for t, data in pairs(tests) do
    s.result[t] = "NA"
    os.execute(string.format("mkdir -p %s/tests/%d", s.problemPath, t))
    local input = io.open(string.format("%s/tests/%d/%d.in", s.problemPath, t, t), "w")
    input:write(data["input"]) input:close()
    local answer = io.open(string.format("%s/tests/%d/%d.ans", s.problemPath, t, t), "w")
    answer:write(data["output"]) answer:close()
  end
end

function display()
  local s = P[N]
  vim.cmd("cd " .. s.problemPath)
  layout(C.layout, 0)
  test(s.curTest)
end

function tab(index)
  vim.cmd("tabn" .. index)
  N = index
  vim.cmd("cd " .. P[N].problemPath)
  tabline()
end

function add(name, timeout, problemPath, tests)
  if not problemPath then
    problemPath = string.format("%s/%s", C.locals[1], name)
    tests = {{input = "", output = ""}}
  end
  if not timeout then
    timeout = C.locals[2]
  end
  for i, s in ipairs(P) do
    if s.name == name then
      tab(i)
      return
    end
  end
  if next(P) then vim.cmd("tabnew") end
  N = #P + 1
  local f = io.open(string.format("%s/%s.json", problemPath, name))
  if f then
    P[N] = vim.fn.json_decode(f:read()) f:close()
  else
    P[N] = {problemPath = problemPath, timeout = timeout, curTest = 1, result = {}}
    build(tests)
  end
  P[N].name = name
  display()
end

function remove()
  if #P == 1 then
    print("Won't remove the only problem")
    return
  end
  table.remove(P, N)
  tab(N - 1)
  tabline()
end

function submit()
  local s = P[N]
  vim.fn.jobstart({'bash', '-c', string.format("cf submit -f %s/$s %s", s.problemPath, s.lang[1], s.name)}, {
    on_stdout = function(_, data, _)
    end,
    on_exit = function(_, exitCode, _)
      print("Fuck why doesn't it work")
    end
  })
end

function match(pattern, link)
  local j = 0
  local group = {}
  for i = 1, #pattern do
    j = j + 1
    local p = string.sub(pattern, i, i)
    local l = string.sub(link, j, j)
    if p ~= l then
      if p == '$' then
        s = ""
        while true do
          local l = string.sub(link, j, j)
          if l == '/' or l == '?' or l == '' then break end
          s = s .. l
          j = j + 1
        end
        j = j - 1
        group[#group + 1] = s
      else break end
    end
  end
  return group
end

function merge(group, path)
  result = ""
  local j = 0
  for i = 1, #path do
    local c = string.sub(path, i, i)
    if c == '$' then
      j = j + 1
      result = result .. group[j]
    else
      result = result .. c
    end
  end
  return result
end

function process(data)
  json = vim.fn.json_decode(data)
  for _, tbl in ipairs(C.links) do
    local group = match(tbl[1], json.url)
    if next(group) then
      name = group[1] .. group[2]
      add(name, json.timeLimit, merge(group, tbl[2]), json.tests)
      break
    end
  end
end

local uv = vim.loop

function receive()
  local buffer = ""
  server = uv.new_tcp()
  server:bind("127.0.0.1", 27121)
  server:listen(128, function(err)
    assert(not err, err)
    local client = uv.new_tcp()
    server:accept(client)
    client:read_start(function(error, chunk)
      assert(not error, error)
      if chunk then
        buffer = buffer .. chunk
      else
        client:shutdown()
        client:close()
        local lines = {}
        for line in string.gmatch(buffer, "[^\r\n]+") do
          table.insert(lines, line)
        end
        buffer = lines[#lines]
        vim.schedule(function()
          process(buffer)
        end)
        server:shutdown()
      end
    end)
  end)
  uv.run()
end

function save()
  for name, s in pairs(P) do
    local path = io.open(string.format("%s/%s.json", s.problemPath, s.name), "w")
    path:write(vim.fn.json_encode(s)) path.close()
  end
end

function start()
  vim.o.hidden = true
  vim.o.termguicolors = true

--// lua syntax soon //--
vim.cmd[[
function CpTab(num, clicks, button, flags)
  execute "lua require'cp'.tab(" . a:num . ")"
endfunction

function CpTest(num, clicks, button, flags)
  if a:button == 'r'
    execute "lua require'cp'.hide_show(" . a:num . ")"
  else
    execute "lua require'cp'.test(" . a:num . ")"
  endif
endfunction

command! -nargs=* Cp execute "lua require'cp'." . <f-args>
autocmd VimLeave * lua require'cp'.save()]]
--\\ lua syntax soon \\--

  receive()
end

function setup(user_config)
  C = user_config
  if vim.fn.argv(0) == C.autostart_arg then
    start()
  end
end

function help()
  print("Usage:\n")
  for k, v in pairs(M) do
    print("Cp " .. k .. "({args})")
  end
end

M = {
  help = help,
  setup = setup,
  start = start,
  save = save,
  layout = layout,
  lang = lang,
  compile = compile,
  run = run,
  tab = tab,
  add = add,
  submit = submit,
  remove = remove,
  insert = insert,
  erase = erase,
  hide = hide,
  hide_show = hide_show,
  show = show,
  show_all = show_all,
  invert = invert,
  run = run,
  test = test,
}

return M
