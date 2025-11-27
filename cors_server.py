import http.server
import socketserver

class CORSHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory="/home/user/flutter_app/build/web", **kwargs)
    
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        self.send_header('X-Frame-Options', 'ALLOWALL')
        self.send_header('Content-Security-Policy', 'frame-ancestors *')
        self.send_header('Cross-Origin-Embedder-Policy', 'unsafe-none')
        self.send_header('Cross-Origin-Opener-Policy', 'unsafe-none')
        self.send_header('Cross-Origin-Resource-Policy', 'cross-origin')
        super().end_headers()
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

class ReuseAddrTCPServer(socketserver.TCPServer):
    allow_reuse_address = True

if __name__ == "__main__":
    with ReuseAddrTCPServer(("0.0.0.0", 5060), CORSHandler) as httpd:
        print("Serving on port 5060...")
        httpd.serve_forever()
