# SSH Key Pair Configuration - Complete ✅

## Summary
All EC2 instances created by Terraform will now use the **`lc-ec2`** SSH key pair. This allows you to SSH into any instance without providing a key path.

---

## Changes Made

### 1. `/modules/instances/main.tf`
**Added:**
- New variable `key_name` with default value `"lc-ec2"`
- `key_name = var.key_name` to both `aws_instance.web_1` and `aws_instance.web_2`

**Result:** Web server instances will now be created with the lc-ec2 key pair attached.

### 2. `/modules/nginx_lb/variables.tf`
**Added:**
- New variable `key_name` with default value `"lc-ec2"`

**Result:** Nginx load balancer module now has the key configuration parameter.

### 3. `/modules/nginx_lb/main.tf`
**Added:**
- `key_name = var.key_name` to `aws_instance.nginx_lb`

**Result:** Nginx LB instance will now be created with the lc-ec2 key pair attached.

---

## How It Works

When Terraform creates EC2 instances, it will now:
1. Look up the existing **`lc-ec2`** SSH key pair in your AWS account
2. Attach that key pair to all 3 instances (2 web servers + 1 Nginx LB)
3. Allow SSH access using: `ssh -i /path/to/lc-ec2.pem ec2-user@<instance-ip>`

---

## Next Steps: Deploy with Updated Code

### Step 1: Navigate to your environment (dev/prod/release)
```bash
cd environments/prod
# or: cd environments/dev
# or: cd environments/release
```

### Step 2: Plan the changes
```bash
terraform plan -out=tfplan
```

**What to expect in the plan:**
- The 3 EC2 instances will show `key_name = "lc-ec2"` as a NEW argument
- If instances already exist, Terraform will mark them for replacement (destruction + creation)

### Step 3: Apply the changes
```bash
terraform apply tfplan
```

This will:
- Destroy the old instances (if they exist)
- Create new instances WITH the lc-ec2 key pair attached
- Takes ~2-3 minutes

### Step 4: SSH into the instances
After apply completes, you can SSH directly:

```bash
# Get the Nginx LB public IP
NGINX_IP=$(terraform output -raw nginx_lb_public_ip)

# SSH using the lc-ec2 key
ssh -i /path/to/lc-ec2.pem ec2-user@$NGINX_IP

# Or SSH to web servers (using their private IPs from within Nginx LB)
ssh -i /path/to/lc-ec2.pem ec2-user@<web-server-private-ip>
```

---

## Verification

After instances are created, verify the key pair is attached:

```bash
# Check instance details (should show KeyName: lc-ec2)
aws ec2 describe-instances --instance-ids i-xxxxxxxxxxxx --region ap-south-1 --query 'Reservations[0].Instances[0].{ID:InstanceId,KeyName:KeyName,State:State.Name}'
```

Expected output:
```
{
    "ID": "i-047d46ee2a4476af2",
    "KeyName": "lc-ec2",
    "State": "running"
}
```

---

## Troubleshooting

### Error: "InvalidKeyPair.NotFound"
- The `lc-ec2` key pair doesn't exist in your AWS account
- Solution: Create the key pair first:
  ```bash
  aws ec2 create-key-pair --key-name lc-ec2 --region ap-south-1 --query 'KeyMaterial' --output text > lc-ec2.pem
  chmod 600 lc-ec2.pem
  ```

### Error: "Permission denied (publickey)"
- The SSH key path is wrong, or permissions are incorrect
- Solution:
  ```bash
  chmod 600 /path/to/lc-ec2.pem
  ssh -i /path/to/lc-ec2.pem -v ec2-user@<instance-ip>  # verbose to debug
  ```

### Can't connect after terraform apply
- Security group may still be blocking SSH
- Verify SSH (port 22) is allowed in the security group:
  ```bash
  aws ec2 describe-security-groups --group-ids sg-xxxxxxxxx --region ap-south-1 --query 'SecurityGroups[0].IpPermissions'
  ```

---

## Files Modified
1. ✅ `/modules/instances/main.tf` - Added key_name to both web servers
2. ✅ `/modules/nginx_lb/variables.tf` - Added key_name variable
3. ✅ `/modules/nginx_lb/main.tf` - Added key_name to Nginx LB instance

**Ready to deploy!** 🚀
