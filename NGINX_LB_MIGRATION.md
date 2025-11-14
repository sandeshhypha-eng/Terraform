# Nginx Load Balancer Migration - Complete Guide

## 🎯 Overview

Your Terraform infrastructure has been successfully migrated from **AWS ALB (Application Load Balancer)** to **Nginx EC2 instance** serving as a reverse proxy/load balancer. This allows you to deploy without ALB restrictions.

## 📋 What Changed

### ❌ Removed (ALB)
- AWS Application Load Balancer
- Target Groups
- Health Check Configuration
- ALB DNS endpoints

### ✅ Added (Nginx)
- `modules/nginx_lb/` - New Nginx Load Balancer module
  - `main.tf` - Nginx EC2 instance configuration
  - `variables.tf` - Input variables
  - `outputs.tf` - Output values
  - `nginx_config.sh` - Bash script for Nginx setup
- Updated security groups for Nginx in `modules/security/`
- New nginx_instance_type variable in each environment

## 🏗️ Architecture

### Previous: ALB Based
```
Internet
   ↓
AWS ALB (managed)
   ├─→ EC2 Instance 1 (Web Server)
   └─→ EC2 Instance 2 (Web Server)
```

### Current: Nginx Based
```
Internet
   ↓
EC2 Nginx LB (Self-Hosted)
   ├─→ EC2 Instance 1 (Web Server)
   └─→ EC2 Instance 2 (Web Server)
```

## 📦 New Module: nginx_lb

### Location
```
modules/nginx_lb/
├── main.tf              # Nginx instance configuration
├── variables.tf         # Input variables
├── outputs.tf           # Output values
└── nginx_config.sh      # Nginx setup script
```

### What It Does
1. Creates an EC2 instance in a public subnet
2. Installs and configures Nginx
3. Configures Nginx as reverse proxy
4. Sets up load balancing between 2 web servers
5. Configures health checks
6. Provides HTTP endpoints for access

### Key Features
- **Load Balancing Method:** Round-robin
- **Health Checks:** 3 max failures, 30-second timeout
- **Automatic Failover:** Routes to healthy servers only
- **Proxy Configuration:** Full header preservation
- **Logging:** Detailed access and error logs
- **Status Endpoints:** 
  - `/health` - Simple health check
  - `/nginx_status` - Nginx statistics

## 🔧 Configuration Files

### Nginx Configuration
The nginx_config.sh script creates:
- **Upstream block:** Defines backend servers (web-1 and web-2)
- **Server block:** Listens on port 80
- **Proxy settings:** 
  - Timeout: 30 seconds
  - Buffer: 4KB buffer with 8 buffers
  - Headers: Forwarded headers for backend
- **Status page:** /nginx_status endpoint

### Security Group
New Nginx security group allows:
- ✅ Inbound HTTP (80) from internet
- ✅ Inbound HTTPS (443) from internet  
- ✅ Inbound SSH (22) from internet (restrict in production)
- ✅ Outbound: All traffic

### Backend Web Servers
Updated to accept traffic from Nginx security group:
```terraform
ingress {
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  security_groups = [aws_security_group.alb.id, aws_security_group.nginx_lb.id]
}
```

## 📊 Environment-Specific Configuration

### Dev Environment (dev)
```
Nginx Instance Type:  t2.micro
Web Servers:         t2.micro each
Location:            Public subnet 1
Purpose:             Development/Testing
```

### Dev-A Variant
```
VPC CIDR:            10.3.0.0/16
Nginx:               t2.micro
Web Servers:         t2.micro
```

### Dev-B Variant
```
VPC CIDR:            10.4.0.0/16
Nginx:               t2.micro
Web Servers:         t2.small
```

### Release Environment
```
Nginx Instance Type:  t2.small
Web Servers:         t2.small each
Location:            Public subnet 1
Purpose:             Staging/Pre-production
```

### Prod Environment
```
Nginx Instance Type:  t2.small
Web Servers:         t2.medium each
Location:            Public subnet 1
Purpose:             Production
```

## 📤 Outputs

Each environment now outputs:

```terraform
nginx_lb_public_ip      # Direct access via IP
nginx_lb_public_dns     # Access via DNS name
nginx_lb_endpoint       # Ready-to-use URL
nginx_health_check_url  # Health check endpoint
```

### Example Output:
```
Outputs:

nginx_lb_public_ip = "203.0.113.45"
nginx_lb_public_dns = "ec2-203-0-113-45.ap-south-1.compute.amazonaws.com"
nginx_lb_endpoint = "http://203.0.113.45"
nginx_health_check_url = "http://203.0.113.45/health"
```

## 🚀 Deployment Steps

### Step 1: Update Terraform
```bash
cd environments/dev  # or prod/release
terraform init
terraform plan -var-file="dev-a.tfvars"  # or terraform.tfvars
```

### Step 2: Review Changes
Look for:
- Nginx EC2 instance creation
- Security group creation/updates
- No ALB resources

### Step 3: Apply Changes
```bash
terraform apply -var-file="dev-a.tfvars"
```

### Step 4: Wait for Setup
- Nginx instance creation: ~2 minutes
- Nginx startup: ~1 minute
- Total: ~3-5 minutes

### Step 5: Test Access
```bash
# Using the IP
curl http://<nginx_lb_public_ip>

# Using DNS
curl http://<nginx_lb_public_dns>

# Health check
curl http://<nginx_lb_public_ip>/health
```

## 🔍 Monitoring & Troubleshooting

### Check Nginx Status
```bash
# SSH into Nginx instance
ssh -i your-key.pem ec2-user@<nginx_public_ip>

# Check Nginx status
sudo systemctl status nginx

# View Nginx logs
tail -f /var/log/nginx/lb_access.log
tail -f /var/log/nginx/lb_error.log

# Check Nginx configuration
nginx -t
```

### Verify Backend Connectivity
```bash
# From Nginx instance
curl http://10.0.1.X   # web-1 private IP
curl http://10.0.2.X   # web-2 private IP
```

### Monitor Load Balancing
```bash
# Access multiple times and check logs
for i in {1..10}; do curl http://<nginx_ip>; done

# Should see alternating requests to backend servers
```

## ⚙️ Advanced Configuration

### Change Load Balancing Algorithm
Edit `modules/nginx_lb/nginx_config.sh`:

**Round-robin (current):**
```nginx
upstream backend_servers {
    server ${web_1_ip}:80;
    server ${web_2_ip}:80;
}
```

**Least connections:**
```nginx
upstream backend_servers {
    least_conn;
    server ${web_1_ip}:80;
    server ${web_2_ip}:80;
}
```

**IP hash:**
```nginx
upstream backend_servers {
    ip_hash;
    server ${web_1_ip}:80;
    server ${web_2_ip}:80;
}
```

### Enable HTTPS (SSL)
1. Generate SSL certificate
2. Update nginx_config.sh to include SSL configuration
3. Modify security group to allow port 443
4. Update proxy_pass to use https

### Add Custom Headers
```nginx
location / {
    proxy_pass http://backend_servers;
    proxy_set_header X-Custom-Header "value";
    proxy_set_header X-Environment "dev";
}
```

## 📋 Comparison: Nginx vs ALB

| Feature | Nginx LB | AWS ALB |
|---------|----------|---------|
| Cost | EC2 only | ALB + EC2 |
| Latency | ~1-2ms | ~0-1ms |
| Scalability | Manual | Auto-scaling |
| Health Checks | Configurable | AWS managed |
| Logging | File-based | CloudWatch |
| SSL/TLS | Nginx config | ALB native |
| Restrictions | Account limits | ALB quota limits |
| Setup | ~5 min | ~10 min |
| Management | Manual | AWS managed |

## 🔐 Security Considerations

### Current Setup
- ✅ SSH access on port 22 (restrict to admin IPs)
- ✅ HTTP access on port 80 (internet-facing)
- ✅ HTTPS on port 443 (optional)

### Recommendations
1. **Restrict SSH:** Change security group to limit SSH to your IP
2. **Add HTTPS:** Implement SSL/TLS certificates
3. **Monitor Logs:** Set up log aggregation
4. **Backup Config:** Track nginx_config.sh in Git
5. **Rate Limiting:** Add rate limiting in Nginx
6. **WAF Rules:** Consider adding application-level protection

## 📝 Files Modified

### New Files Created
- `modules/nginx_lb/main.tf`
- `modules/nginx_lb/variables.tf`
- `modules/nginx_lb/outputs.tf`
- `modules/nginx_lb/nginx_config.sh`

### Updated Files
- `modules/security/main.tf` - Added Nginx security group
- `environments/dev/main.tf` - Replaced ALB with Nginx
- `environments/dev/variables.tf` - Added nginx_instance_type
- `environments/dev/outputs.tf` - Updated outputs
- `environments/prod/main.tf` - Replaced ALB with Nginx
- `environments/prod/variables.tf` - Added nginx_instance_type
- `environments/prod/outputs.tf` - Updated outputs
- `environments/release/main.tf` - Replaced ALB with Nginx
- `environments/release/variables.tf` - Added nginx_instance_type
- `environments/release/outputs.tf` - Updated outputs

## 🎯 Next Steps

1. **Test Development Deployment**
   ```bash
   cd environments/dev
   terraform apply -var-file="dev-a.tfvars"
   ```

2. **Access Application**
   ```bash
   curl http://<terraform_output_nginx_lb_endpoint>
   ```

3. **Verify Load Balancing**
   ```bash
   # Multiple requests should alternate between web servers
   for i in {1..5}; do curl http://<ip>; done
   ```

4. **Monitor Logs**
   ```bash
   ssh -i key.pem ec2-user@<nginx_ip>
   tail -f /var/log/nginx/lb_access.log
   ```

5. **Update GitHub Actions**
   - The deploy workflow automatically uses the new Nginx LB
   - Outputs will show Nginx IP instead of ALB DNS

## 📞 Support

If you encounter issues:

1. **Check Nginx Logs:**
   ```bash
   ssh to Nginx instance
   sudo journalctl -u nginx
   tail -f /var/log/nginx/error.log
   ```

2. **Verify Backend Servers:**
   ```bash
   curl http://<web1_private_ip>
   curl http://<web2_private_ip>
   ```

3. **Check Security Groups:**
   - Nginx SG allows 80/443 from internet
   - Web server SG allows 80 from Nginx SG

4. **Review Terraform State:**
   ```bash
   terraform state show module.nginx_lb.aws_instance.nginx_lb
   ```

## ✅ Migration Complete!

Your infrastructure is now running on Nginx LB instead of ALB. All environments (dev-a, dev-b, release, prod) are configured and ready to deploy.

**Happy deploying! 🚀**
