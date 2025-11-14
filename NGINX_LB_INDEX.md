# 📌 Nginx Load Balancer - Complete Documentation Index

## 🎯 Start Here

**For Quick Summary:** `NGINX_LB_COMPLETE.txt`
- What changed
- What was added
- Quick deploy commands
- Testing checklist

**For Quick Reference:** `NGINX_LB_QUICK_REF.md`
- Common commands
- Troubleshooting
- Performance info
- Workflows

**For Complete Guide:** `NGINX_LB_MIGRATION.md`
- Architecture overview
- Configuration details
- Advanced options
- Comparison vs ALB

---

## 📂 File Structure

### New Nginx Module
```
modules/nginx_lb/
├── main.tf              # EC2 instance configuration
├── variables.tf         # Input variables
├── outputs.tf           # Output values
└── nginx_config.sh      # Installation script
```

### Updated Security Module
```
modules/security/main.tf
└── Added Nginx security group
```

### Updated Environments
```
environments/
├── dev/
│   ├── main.tf          # Uses Nginx instead of ALB
│   ├── variables.tf     # Added nginx_instance_type
│   └── outputs.tf       # Updated to Nginx outputs
├── prod/
│   ├── main.tf          # Uses Nginx instead of ALB
│   ├── variables.tf     # Added nginx_instance_type
│   └── outputs.tf       # Updated to Nginx outputs
└── release/
    ├── main.tf          # Uses Nginx instead of ALB
    ├── variables.tf     # Added nginx_instance_type
    └── outputs.tf       # Updated to Nginx outputs
```

---

## 📖 Documentation Files

### Summary (10 min read)
- `NGINX_LB_COMPLETE.txt` - Overview and summary

### Quick Reference (5 min read)
- `NGINX_LB_QUICK_REF.md` - Commands and workflows

### Detailed Guide (20 min read)
- `NGINX_LB_MIGRATION.md` - Complete documentation

---

## 🚀 Quick Start

### Deploy Dev-A
```bash
cd environments/dev
terraform apply -var-file="dev-a.tfvars"
terraform output nginx_lb_endpoint
curl <output_endpoint>
```

### Deploy Dev-B
```bash
cd environments/dev
terraform apply -var-file="dev-b.tfvars"
```

### Deploy Release
```bash
cd environments/release
terraform apply
```

### Deploy Prod
```bash
cd environments/prod
terraform apply
```

---

## 🔍 Key Changes

### Removed
- AWS ALB module usage
- Target groups
- ALB security group (replaced with Nginx SG)
- ALB DNS outputs

### Added
- Nginx EC2 instance
- Nginx configuration script
- Nginx security group
- Nginx health endpoints
- nginx_instance_type variable

### Modified
- Security group now handles both ALB and Nginx (compatibility)
- Environment main.tf files now use Nginx instead of ALB
- Outputs changed from ALB DNS to Nginx IP/DNS
- Variables added for Nginx instance type

---

## 📊 Instance Configuration

### Dev Environment
- **Nginx:** t2.micro
- **Web-1:** t2.micro
- **Web-2:** t2.micro

### Release Environment
- **Nginx:** t2.small
- **Web-1:** t2.small
- **Web-2:** t2.small

### Prod Environment
- **Nginx:** t2.small
- **Web-1:** t2.medium
- **Web-2:** t2.medium

---

## 🔐 Security

### Nginx Security Group
- ✅ HTTP (80) from anywhere
- ✅ HTTPS (443) from anywhere
- ✅ SSH (22) from anywhere ⚠️ (restrict to your IP)

### Web Server Security Group
- ✅ HTTP (80) from Nginx SG
- ✅ HTTP (80) from ALB SG (for compatibility)

---

## 🧪 Testing

### Test 1: Access
```bash
curl http://<nginx_ip>
# Expected: "Hello from EC2 Instance 1" or "Instance 2"
```

### Test 2: Health Check
```bash
curl http://<nginx_ip>/health
# Expected: "Nginx Load Balancer is running"
```

### Test 3: Load Distribution
```bash
for i in {1..10}; do curl http://<nginx_ip> | grep Instance; done
# Expected: Alternating Instance 1 and Instance 2
```

---

## 🛠️ Common Tasks

### View Nginx Logs
```bash
ssh -i key.pem ec2-user@<nginx_ip>
tail -f /var/log/nginx/lb_access.log
```

### Check Nginx Status
```bash
ssh -i key.pem ec2-user@<nginx_ip>
sudo systemctl status nginx
```

### Restart Nginx
```bash
ssh -i key.pem ec2-user@<nginx_ip>
sudo systemctl restart nginx
```

### Test Backend Connectivity
```bash
ssh -i key.pem ec2-user@<nginx_ip>
curl http://10.0.1.X      # web-1
curl http://10.0.2.X      # web-2
```

---

## ⚠️ Troubleshooting

### Can't Access Nginx
1. Check security group allows port 80
2. Verify Nginx is running: `sudo systemctl status nginx`
3. Check if public IP assigned: AWS Console EC2

### One Backend Down
1. SSH to Nginx instance
2. Test backend: `curl http://10.0.1.X`
3. Check web server: `sudo systemctl status httpd`

### Load Not Balancing
1. Check Nginx logs: `/var/log/nginx/lb_access.log`
2. Verify round-robin working: Multiple curls
3. Check health checks: Nginx status endpoint

For more details, see `NGINX_LB_MIGRATION.md` Troubleshooting section.

---

## 📈 Performance

### t2.micro
- ~1000-5000 req/s
- 1-5ms latency
- 100-500 concurrent

### t2.small
- ~5000-15000 req/s
- 1-3ms latency
- 500-2000 concurrent

### Scaling
- <100 req/s: t2.micro
- 100-500 req/s: t2.small
- 500+ req/s: t2.medium

---

## 🔧 Advanced Configuration

### Change Load Balancing Algorithm
Edit `modules/nginx_lb/nginx_config.sh`:
- Current: Round-robin
- Alternative: `least_conn`, `ip_hash`, `random`

### Add HTTPS
1. Get SSL certificate
2. Update nginx_config.sh
3. Add port 443 to security group

### Custom Headers
Edit the proxy_set_header lines in nginx_config.sh

### Change Health Check Endpoint
Edit the `location /health` block

---

## 📋 Architecture

### Previous (ALB)
```
Internet → AWS ALB → Web-1 + Web-2
```

### Current (Nginx)
```
Internet → Nginx EC2 → Web-1 + Web-2
```

---

## ✅ Pre-Deployment Checklist

- [ ] Read NGINX_LB_COMPLETE.txt
- [ ] Reviewed main.tf changes
- [ ] Checked security group configuration
- [ ] Reviewed nginx_config.sh script
- [ ] Planned for dev-a, dev-b, release, prod
- [ ] Have AWS credentials configured
- [ ] Know how to access Terraform outputs

---

## 🎯 Deployment Checklist

### Before `terraform apply`:
- [ ] `terraform plan` shows expected changes
- [ ] Security groups are correct
- [ ] Instance types are appropriate

### After `terraform apply`:
- [ ] All resources created successfully
- [ ] Got Nginx public IP from output
- [ ] Can ping/curl the Nginx IP
- [ ] Received response from web server
- [ ] Health check endpoint works

---

## 📞 Support Resources

**Documentation:**
- `NGINX_LB_COMPLETE.txt` - Summary
- `NGINX_LB_QUICK_REF.md` - Quick commands
- `NGINX_LB_MIGRATION.md` - Complete guide

**Related Guides:**
- `DEPLOYMENT_GUIDE.md` - General deployment
- `WORKFLOW_ARCHITECTURE.md` - Overall architecture
- `SETUP_CHECKLIST.md` - Initial setup

---

## 🎉 Ready to Deploy!

Your infrastructure is now configured with Nginx load balancer!

**Next Step:** Deploy to dev-a and test

```bash
cd environments/dev
terraform apply -var-file="dev-a.tfvars"
terraform output
curl http://<nginx_lb_endpoint>
```

**Happy deploying! 🚀**

---

**Last Updated:** November 15, 2025
**Status:** ✅ Complete
**Environments:** dev-a, dev-b, release, prod
**All Ready:** Yes
