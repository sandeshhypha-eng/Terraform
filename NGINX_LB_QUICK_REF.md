# Nginx Load Balancer - Quick Reference

## 📌 Quick Access Points

### Nginx Module
**Location:** `modules/nginx_lb/`
**Files:**
- `main.tf` - EC2 instance & config
- `variables.tf` - Input variables
- `outputs.tf` - Output values  
- `nginx_config.sh` - Installation script

### Configuration Files Updated
**Security:** `modules/security/main.tf` (Nginx SG added)
**Dev:** `environments/dev/` (main.tf, variables.tf, outputs.tf)
**Release:** `environments/release/` (main.tf, variables.tf, outputs.tf)
**Prod:** `environments/prod/` (main.tf, variables.tf, outputs.tf)

## 🚀 Quick Deploy

### Dev-A
```bash
cd environments/dev
terraform plan -var-file="dev-a.tfvars"
terraform apply -var-file="dev-a.tfvars"
```

### Dev-B
```bash
cd environments/dev
terraform plan -var-file="dev-b.tfvars"
terraform apply -var-file="dev-b.tfvars"
```

### Release
```bash
cd environments/release
terraform plan
terraform apply
```

### Prod
```bash
cd environments/prod
terraform plan
terraform apply
```

## 📊 Instance Configuration

### Dev/Release/Prod Nginx Sizes
```
dev       → t2.micro
release   → t2.small
prod      → t2.small
```

### Backend Web Servers
```
dev-a     → t2.micro (both servers)
dev-b     → t2.small (both servers)
release   → t2.small (both servers)
prod      → t2.medium (both servers)
```

## 🌐 Accessing Your Application

### After Terraform Apply:
```
Output: nginx_lb_public_ip = "203.0.113.45"
URL:    http://203.0.113.45
```

### Using DNS:
```
Output: nginx_lb_public_dns = "ec2-203-0-113-45.compute.amazonaws.com"
URL:    http://ec2-203-0-113-45.compute.amazonaws.com
```

### Health Check:
```
http://203.0.113.45/health
```

## 🔧 Common Commands

### SSH to Nginx
```bash
ssh -i your-key.pem ec2-user@<public_ip>
```

### Check Nginx Status
```bash
sudo systemctl status nginx
sudo systemctl restart nginx
```

### View Logs
```bash
tail -f /var/log/nginx/lb_access.log
tail -f /var/log/nginx/lb_error.log
tail -f /var/log/nginx/error.log
```

### Test Configuration
```bash
sudo nginx -t
```

### View Nginx Config
```bash
cat /etc/nginx/nginx.conf
```

### Check Backend Connectivity
```bash
curl http://10.0.1.XX  # web-1
curl http://10.0.2.XX  # web-2
```

## 📈 Monitoring Load Distribution

### Quick Test (5 requests)
```bash
for i in {1..5}; do curl http://<nginx_ip>; done
```

### Continuous Test
```bash
while true; do 
  curl -s http://<nginx_ip> | grep "Instance"
  sleep 1
done
```

### Check Logs
```bash
# Watch in real-time
tail -f /var/log/nginx/lb_access.log

# Count requests per backend
grep "10.0.1" /var/log/nginx/lb_access.log | wc -l  # web-1
grep "10.0.2" /var/log/nginx/lb_access.log | wc -l  # web-2
```

## 🔍 Troubleshooting

### Nginx Not Starting
```bash
# Check if running
curl http://<public_ip>

# SSH and check logs
ssh ec2-user@<ip>
sudo systemctl status nginx
sudo systemctl start nginx
```

### Can't Reach Backend Servers
```bash
# SSH to Nginx
ssh ec2-user@<nginx_ip>

# Test connectivity
curl http://10.0.1.X
curl http://10.0.2.X

# Check Nginx config
sudo nginx -t
```

### Connection Timeout
```bash
# Check security groups
# 1. Nginx SG allows 80 from 0.0.0.0/0
# 2. Web server SG allows 80 from Nginx SG
```

### One Backend Not Working
```bash
# SSH to that web server
ssh ec2-user@<web_server_ip>

# Check Apache
sudo systemctl status httpd

# Check if listening on port 80
sudo netstat -tlnp | grep 80
```

## 🔐 Security Checks

### Verify Security Groups
```bash
# Nginx SG - should allow:
# - Inbound 80 from 0.0.0.0/0
# - Inbound 22 from your IP (restrict)
# - Outbound all

# Web SG - should allow:
# - Inbound 80 from Nginx SG
# - Outbound all
```

### Restrict SSH Access
```bash
# In AWS console:
# Edit Nginx SG
# Change SSH (22) CIDR from 0.0.0.0/0 to your-ip/32
```

## 📝 Configuration Changes

### Change Load Balancing Algorithm
Edit `modules/nginx_lb/nginx_config.sh`:
- **Round-robin:** (default)
- **Least connections:** Add `least_conn;`
- **IP hash:** Add `ip_hash;`

### Add Custom Headers
Edit the `location /` block in nginx_config.sh

### Change Timeouts
Edit these lines in nginx_config.sh:
```
proxy_connect_timeout 30s;  # Change 30
proxy_send_timeout 30s;     # Change 30
proxy_read_timeout 30s;     # Change 30
```

### Enable HTTPS
1. Get SSL certificate
2. Update nginx_config.sh to listen on 443
3. Add security group rule for 443
4. Configure certificate path

## 📊 Performance Metrics

### Nginx LB Typical Performance
```
Requests/sec:     ~1000-5000 (t2.micro)
Concurrent:       ~100-500
Latency:          1-5ms
Throughput:       10-50 MB/s
```

### Scaling Recommendations
```
<100 req/s   → t2.micro
100-500 req/s → t2.small
500+ req/s   → t2.medium or t2.large
```

## 📋 Instance Configuration Summary

```
Module:       nginx_lb
Type:         EC2 (Self-hosted)
Port:         80 (HTTP)
Backend:      2 web servers
Subnets:      Public (1)
Security:     Custom security group
Scaling:      Manual
Health:       Configured
Logs:         /var/log/nginx/
```

## 🎯 Common Workflows

### Full Deployment (Dev-A)
```bash
cd environments/dev
terraform init
terraform plan -var-file="dev-a.tfvars"
terraform apply -var-file="dev-a.tfvars"
# Get outputs
terraform output
```

### Update Code
```bash
# Make changes
git add .
git commit -m "Update Nginx config"

# Redeploy
terraform apply -var-file="dev-a.tfvars"
```

### Destroy (Dev-A)
```bash
cd environments/dev
terraform destroy -var-file="dev-a.tfvars"
```

### Compare Dev-A vs Dev-B
```bash
# Plan both
terraform plan -var-file="dev-a.tfvars" > plan-a.txt
terraform plan -var-file="dev-b.tfvars" > plan-b.txt

# Compare outputs
terraform output -json -var-file="dev-a.tfvars"
terraform output -json -var-file="dev-b.tfvars"
```

## 🔗 Related Files

- **Main Guide:** `NGINX_LB_MIGRATION.md`
- **Deployment:** `DEPLOYMENT_GUIDE.md`
- **Architecture:** `WORKFLOW_ARCHITECTURE.md`
- **Setup:** `SETUP_CHECKLIST.md`

---

**Quick tip:** Always run `terraform plan` before `terraform apply` to verify changes!
