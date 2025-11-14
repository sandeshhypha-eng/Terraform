#!/bin/bash
# Diagnostic script to debug Nginx instance
# Usage: ./DEBUG_NGINX_INSTANCE.sh <nginx-public-ip> <path-to-aws-key.pem>

set -e

if [ $# -lt 2 ]; then
  echo "Usage: $0 <nginx-public-ip> <path-to-aws-key.pem>"
  echo "Example: $0 65.0.76.83 ~/.ssh/my-aws-key.pem"
  exit 1
fi

NGINX_IP="$1"
KEY_PATH="$2"
EC2_USER="ec2-user"

echo "========================================================"
echo "Nginx Instance Diagnostic Script"
echo "========================================================"
echo "Target IP: $NGINX_IP"
echo "Key Path: $KEY_PATH"
echo ""

# Check if key exists
if [ ! -f "$KEY_PATH" ]; then
  echo "✗ ERROR: Key file not found at $KEY_PATH"
  exit 1
fi

echo "[1/7] Checking network connectivity..."
if ping -c 1 -W 2 "$NGINX_IP" &>/dev/null; then
  echo "✓ Instance is reachable via ping"
else
  echo "⚠ Instance did not respond to ping (may be blocked by security group)"
fi

echo ""
echo "[2/7] Checking SSH connectivity..."
if ssh -i "$KEY_PATH" -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new "$EC2_USER@$NGINX_IP" "echo OK" &>/dev/null; then
  echo "✓ SSH connection successful"
else
  echo "✗ SSH connection failed - cannot proceed with diagnostics"
  exit 1
fi

echo ""
echo "[3/7] Checking if nginx service exists..."
ssh -i "$KEY_PATH" "$EC2_USER@$NGINX_IP" "sudo systemctl list-unit-files | grep -i nginx || echo 'No nginx unit found'"

echo ""
echo "[4/7] Checking nginx service status..."
ssh -i "$KEY_PATH" "$EC2_USER@$NGINX_IP" "sudo systemctl status nginx 2>&1 || echo 'Nginx service not found or not running'"

echo ""
echo "[5/7] Checking if nginx process is running..."
ssh -i "$KEY_PATH" "$EC2_USER@$NGINX_IP" "ps aux | grep -i nginx | grep -v grep || echo 'No nginx process found'"

echo ""
echo "[6/7] Reviewing user_data installation log..."
ssh -i "$KEY_PATH" "$EC2_USER@$NGINX_IP" "sudo cat /var/log/nginx_install.log 2>/dev/null | tail -50 || echo 'nginx_install.log not found'"

echo ""
echo "[7/7] Checking security group rules..."
echo "Attempting to check if port 80 is listening..."
ssh -i "$KEY_PATH" "$EC2_USER@$NGINX_IP" "sudo netstat -tlnp 2>/dev/null | grep -E ':(80|443)' || echo 'Port 80/443 not listening'"

echo ""
echo "========================================================"
echo "Additional debugging info:"
echo "========================================================"
echo "To manually check nginx config:"
echo "  ssh -i \"$KEY_PATH\" $EC2_USER@$NGINX_IP \"sudo nginx -t\""
echo ""
echo "To restart nginx:"
echo "  ssh -i \"$KEY_PATH\" $EC2_USER@$NGINX_IP \"sudo systemctl restart nginx\""
echo ""
echo "To view nginx error log:"
echo "  ssh -i \"$KEY_PATH\" $EC2_USER@$NGINX_IP \"sudo tail -100 /var/log/nginx/error.log\""
echo ""
echo "To view full cloud-init output:"
echo "  ssh -i \"$KEY_PATH\" $EC2_USER@$NGINX_IP \"sudo cat /var/log/cloud-init-output.log | tail -200\""
echo "========================================================"
