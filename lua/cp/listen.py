from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = 10045

class Handler(BaseHTTPRequestHandler):
  def do_POST(self):
    content_len = int(self.headers['Content-Length'])
    post_body = self.rfile.read(content_len)
    print(post_body.decode())
  def log_message(self, format, *args):
     return

def http_listen(server_class=HTTPServer, handler_class=Handler, port=PORT):
  server_address = ('', port)
  httpd = server_class(server_address, handler_class)
  try:
    httpd.serve_forever()
  except:
    pass
  httpd.server_close()

print("fuck off please")
print("fuck the fuck")
# http_listen()
