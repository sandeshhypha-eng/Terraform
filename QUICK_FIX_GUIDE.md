# Quick Fix Guide - Nginx Not Running

## Immediate Steps to Get Nginx Running

### Option 1: Destroy and Redeploy (Cleanest - Recommended)

```bash
# 1. Navigate to your environment
cd "/Users/fci/Desktop/untitled folder/Terraform"

# 2. Destroy the current infrastructure (the fixed script will be used on new instances)
terraform -chdir=environments/prod destroy -auto-approve

# 3. Wait a moment for termination to complete
sleep 30

# 4. Reapply with the fixed Nginx script
terraform -chdir=environments/prod apply -auto-approve

# 5. Get the new IP address
terraform -chdir=environments/prod output nginx_lb_public_ip
```

**Why this works:** The new Nginx instance will use the updated `nginx_config.sh` with proper error handling.

---

### Option 2: Manual Fix on Current Instance

#### Step 1: SSH into the Nginx instance
```bash
ssh -i /path/to/your/key.pem ec2-user@43.205.99.203
```

#### Step 2: Download the fixed script
```bash
# Get the backend server IPs from Terraform outputs
terraform -chdir=environments/prod output web_1_private_ip
terraform -chdir=environments/prod output web_2_private_ip
```

#### Step 3: Create the fixed script on the instance
```bash
# Replace the IPs with actual values from Step 2
sudo tee /tmp/nginx_config_fixed.sh > /dev/null <<'EOF'
#!/bin/bash
# ... copy the entire fixed nginx_config.sh content here
# Remember to replace ${web_1_ip} and ${web_2_ip} with actual IPs
EOF
```

#### Step 4: Run the script
```bash
sudo bash /tmp/nginx_config_fixed.sh
```

#### Step 5: Verify it's running
```bash
sudo systemctl status nginx
curl http://localhost/health
```

---

## Debugging the Current Instance

### View Installation Log
```bash
ssh -i /path/to/your/key.pem ec2-user@43.205.99.203 "sudo cat /var/log/nginx_install.log"
```

### Check Why Nginx Failed
```bash
# SSH into instance
ssh -i /path/to/your/key.pem ec2-user@43.205.99.203

# Check if nginx package is available
yum info nginx

# Check system logs
sudo journalctl -xe

# Try manual installation
sudo yum install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
sudo systemctl status nginx
```

### Test Connectivity to Backend
```bash
# SSH into instance
ssh -i /path/to/your/key.pem ec2-user@43.205.99.203

# Get backend IPs from terraform
# Then test connection to them
sudo nc -zv 10.2.1.X 80   # Replace X with actual subnet
sudo nc -zv 10.2.2.X 80
```

---

## What We Fixed

| Issue | Solution |
|-------|----------|
| `set -e` caused silent failures | Removed and added explicit error checks |
| No logging of installation process | Added logs to `/var/log/nginx_install.log` |
| No verification Nginx was running | Added `systemctl is-active nginx` check |
| Config errors not detected | Added `nginx -t` verification |
| Service might not start in time | Added 2-second wait before verification |

---

## Commands to Verify After Fix

```bash
# 1. Check installation log
sudo cat /var/log/nginx_install.log | grep -E "(✓|✗|Error)"

# 2. Check service status
sudo systemctl status nginx

# 3. Check listening ports
sudo ss -tlnp | grep nginx

# 4. Check config validity
sudo nginx -t

# 5. Test health endpoint
curl http://localhost/health

# 6. Test load balancer
curl http://localhost/

# 7. Check backend connectivity
ping 10.2.1.X   # Replace with actual web server 1 IP
ping 10.2.2.X   # Replace with actual web server 2 IP
```

---

## If Still Not Working

### Check these in order:

1. **Is yum working?**
   ```bash
   sudo yum check-update
   sudo yum install -y nginx
   ```

2. **Is the nginx package available in this AMI?**
   ```bash
   yum search nginx
   ```

3. **Are there security group issues?**
   - Check security group allows inbound 80 and 443
   - Check web servers have return traffic allowed

4. **Are web servers running?**
   ```bash
   ping 10.2.1.X
   ping 10.2.2.X
   curl http://10.2.1.X
   curl http://10.2.2.X
   ```

5. **Check CloudWatch logs**
   - Go to EC2 console
   - Select instance
   - View "System Log" tab to see user_data execution

---

## Quick Ansible-Style Fix (Advanced)

If you have the key, you can create an inline fix script:

```bash
INSTANCE_IP="43.205.99.203"
KEY_PATH="/path/to/key.pem"

ssh -i $KEY_PATH ec2-user@$INSTANCE_IP << 'ENDSSH'
sudo bash << 'ENDSCRIPT'
# Fix Nginx
yum install -y nginx
systemctl daemon-reload
systemctl enable nginx
systemctl start nginx
systemctl status nginx
echo "✓ Nginx installed and running"
ENDSCRIPT
ENDSSH
```

---

## Recommended Next Steps

1. ✅ **Run Option 1** (destroy and redeploy) - This uses the fixed script
2. ✅ **Verify** with health check: `curl http://new-ip/health`
3. ✅ **Test load balancing**: Hit the endpoint multiple times and verify requests go to different backends
4. ✅ **Review logs** for any issues: `sudo cat /var/log/nginx_install.log`

This is the cleanest and most reliable approach! 🚀
