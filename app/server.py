#!/usr/bin/env python3
import http.server
import socketserver
import os
import sys
import logging

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger(__name__)

PORT = 8080
MSG = os.environ.get("APP_MSG", "Hello from v5 (green) - Zero Downtime Test!")

class MyHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        logger.info(f"Received GET request for {self.path}")
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        response = f"""
        <html>
        <body>
        <h1>{MSG}</h1>
        <p>Path: {self.path}</p>
        <p>Container is working!</p>
        </body>
        </html>
        """
        self.wfile.write(response.encode())

if __name__ == "__main__":
    logger.info(f"Starting server on 0.0.0.0:{PORT}")
    logger.info(f"Message: {MSG}")
    
    try:
        with socketserver.TCPServer(("0.0.0.0", PORT), MyHandler) as httpd:
            logger.info(f"Server started successfully on port {PORT}")
            httpd.serve_forever()
    except Exception as e:
        logger.error(f"Error starting server: {e}")
        sys.exit(1)
