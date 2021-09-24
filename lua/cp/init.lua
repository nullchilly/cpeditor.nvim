if vim.fn.argv(0) ~= 'cp' then
  return
end
local cp_dir = debug.getinfo(1).source:match("@?(.*/)")
print('python ' .. cp_dir .. 'listen.py')
vim.g.listen_cp = vim.fn.jobstart({'bash', '-c', 'python ' .. cp_dir .. 'listen.py'}, {
  on_stdout = function(_, data, _)
    print(data[1])
  end
})
vim.cmd('autocmd VimLeave * :call jobstop(g:listen_cp)')
