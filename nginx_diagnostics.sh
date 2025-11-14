#!/bin/bash
# Quick Troubleshooting Script for Nginx LB Instance
# Run this on the Nginx LB instance to diagnose issues

echo "======================================================"
echo "Nginx Load Balancer - Diagnostic Report"
echo "======================================================"
echo "Timestamp: $(date)"
echo ""

# 1. Check if installation log exists
echo "[1] Checking installation log..."
if [ -f /var/log/nginx_install.log ]; then
    echo "✓ Installation log found"
    echo "------- Last 20 lines of installation log -------"
    tail -20 /var/log/nginx_install.log
    echo ""
else
    echo "✗ Installation log not found at /var/log/nginx_install.log"
    echo ""
fi

# 2. Check if Nginx is installed
echo "[2] Checking Nginx installation..."
if command -v nginx &> /dev/null; then
    echo "✓ Nginx binary found"
    nginx -v
else
    echo "✗ Nginx binary NOT found"
fi
echo ""

# 3. Check Nginx service status
echo "[3] Checking Nginx service status..."
systemctl status nginx
echo ""

# 4. Check if Nginx is listening on port 80
echo "[4] Checking if Nginx is listening on port 80..."
if ss -tlnp 2>/dev/null | grep -q ':80'; then
    echo "✓ Nginx is listening on port 80"
    ss -tlnp | grep nginx
else
    echo "✗ Nginx is NOT listening on port 80"
    echo "Open ports:"
    ss -tlnp | grep LISTEN
fi
echo ""

# 5. Check Nginx configuration
echo "[5] Checking Nginx configuration..."
if [ -f /etc/nginx/nginx.conf ]; then
    echo "✓ Nginx configuration file found"
    echo "Validating configuration..."
    nginx -t
else
    echo "✗ Nginx configuration file NOT found"
fi
echo ""

# 6. Check Nginx error log
echo "[6] Checking Nginx error log..."
if [ -f /var/log/nginx/error.log ]; then
    echo "✓ Nginx error log found"
    echo "------- Last 20 lines of error log -------"
    tail -20 /var/log/nginx/error.log
else
    echo "✗ Nginx error log NOT found"
fi
echo ""

# 7. Test health endpoint
echo "[7] Testing health endpoint (localhost)..."
if systemctl is-active --quiet nginx; then
    curl -s http://localhost/health && echo "" || echo "✗ Failed to reach health endpoint"
else
    echo "✗ Nginx is not running, cannot test endpoint"
fi
echo ""

# 8. Check backend servers in config
echo "[8] Checking backend server configuration..."
echo "Upstream servers defined in nginx.conf:"
grep -A 2 "upstream backend_servers" /etc/nginx/nginx.conf 2>/dev/null || echo "✗ Could not find upstream block"
echo ""

# 9. Check system resources
echo "[9] System resource usage..."
echo "Memory:"
free -h | grep Mem
echo ""
echo "Disk:"
df -h / | tail -1
echo ""
echo "CPU load:"
uptime
echo ""

# 10. Network connectivity
echo "[10] Testing network connectivity to backend servers..."
# Try to get the IPs from the config
BACKEND_IPS=$(grep "server " /etc/nginx/nginx.conf | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
if [ -n "$BACKEND_IPS" ]; then
    while read -r ip; do
        echo "Testing connectivity to $ip:80..."
        timeout 2 bash -c "echo '' > /dev/tcp/$ip/80" 2>/dev/null && echo "✓ Connected to $ip:80" || echo "✗ Cannot reach $ip:80"
    done <<< "$BACKEND_IPS"
else
    echo "⚠ Could not extract backend IPs from configuration"
fi
echo ""

echo "======================================================"
echo "End of Diagnostic Report"
echo "======================================================"
