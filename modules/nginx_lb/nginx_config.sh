#!/bin/bash
# Nginx Load Balancer Configuration Script
# This script installs and configures Nginx as a reverse proxy/load balancer

set -e

# Update system packages
yum update -y
yum install -y nginx

# Create Nginx configuration for load balancing
cat > /etc/nginx/nginx.conf <<'NGINX_CONFIG'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Upstream backend servers (web servers)
    upstream backend_servers {
        server ${web_1_ip}:80 max_fails=3 fail_timeout=30s;
        server ${web_2_ip}:80 max_fails=3 fail_timeout=30s;
    }

    # Server block for port 80
    server {
        listen 80 default_server;
        listen [::]:80 default_server;

        server_name _;

        # Logging
        access_log /var/log/nginx/lb_access.log main;
        error_log /var/log/nginx/lb_error.log;

        # Health check endpoint
        location /health {
            return 200 "Nginx Load Balancer is running\n";
            add_header Content-Type text/plain;
        }

        # Status page (optional)
        location /nginx_status {
            stub_status on;
            access_log off;
            allow 127.0.0.1;
            deny all;
        }

        # Main proxy configuration
        location / {
            # Proxy settings
            proxy_pass http://backend_servers;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Timeouts
            proxy_connect_timeout 30s;
            proxy_send_timeout 30s;
            proxy_read_timeout 30s;
            
            # Buffering
            proxy_buffering on;
            proxy_buffer_size 4k;
            proxy_buffers 8 4k;
            
            # Load balancing method: round-robin (default)
            # For other methods, modify the upstream block above
        }
    }
}
NGINX_CONFIG

# Enable and start Nginx
systemctl daemon-reload
systemctl enable nginx
systemctl start nginx

# Create a custom index page for Nginx LB
cat > /var/www/html/index.html <<'INDEX'
<!DOCTYPE html>
<html>
<head>
    <title>Nginx Load Balancer</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; background-color: #f0f0f0; }
        .container { background-color: white; padding: 20px; border-radius: 5px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        h1 { color: #333; }
        .status { color: green; font-weight: bold; }
        .info { margin-top: 20px; font-size: 14px; color: #666; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Nginx Load Balancer</h1>
        <p class="status">✓ Load Balancer is running and healthy</p>
        
        <h2>Configuration</h2>
        <ul>
            <li><strong>Role:</strong> Reverse Proxy / Load Balancer</li>
            <li><strong>Load Balancing Method:</strong> Round-robin</li>
            <li><strong>Backend Servers:</strong> 2 web servers</li>
            <li><strong>Health Checks:</strong> Enabled (3 max failures, 30s timeout)</li>
        </ul>
        
        <h2>Status Endpoints</h2>
        <ul>
            <li><a href="/health">Health Check</a> - Basic health status</li>
            <li><a href="/nginx_status">Nginx Status</a> - Nginx statistics (localhost only)</li>
        </ul>
        
        <h2>How It Works</h2>
        <p>This Nginx instance acts as a load balancer, distributing incoming requests between two backend web servers using round-robin load balancing. Each request alternates between the two servers.</p>
        
        <div class="info">
            <p><strong>Backend Servers:</strong></p>
            <p>Server 1: ${web_1_ip}:80</p>
            <p>Server 2: ${web_2_ip}:80</p>
        </div>
    </div>
</body>
</html>
INDEX

# Log successful startup
echo "Nginx Load Balancer successfully configured and started"
echo "Backend servers configured:"
echo "  - Server 1: ${web_1_ip}:80"
echo "  - Server 2: ${web_2_ip}:80"
