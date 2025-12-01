import http.server
import socketserver
import os

PORT = 5060

class CORSRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.send_header('X-Frame-Options', 'ALLOWALL')
        self.send_header('Content-Security-Policy', "frame-ancestors *")
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

# Change to the correct directory
web_dir = '/home/user/flutter_app/build/web'
if os.path.exists(web_dir):
    os.chdir(web_dir)
    print(f"Serving {web_dir} on port {PORT}")
else:
    print(f"Error: {web_dir} does not exist")
    exit(1)

with socketserver.TCPServer(('0.0.0.0', PORT), CORSRequestHandler) as httpd:
    httpd.allow_reuse_address = True
    print(f"Serving at port {PORT}")
    httpd.serve_forever()
