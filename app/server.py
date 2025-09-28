from http.server import BaseHTTPRequestHandler, HTTPServer
import os
PORT = 8080
MSG = os.environ.get("APP_MSG", "Hello from v2 (green) - Blue/Green deployment test!")
class H(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200); self.end_headers()
        self.wfile.write(MSG.encode())
HTTPServer(("", PORT), H).serve_forever()
