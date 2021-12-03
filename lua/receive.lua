local uv = vim.loop

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
