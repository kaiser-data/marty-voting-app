# GitHub Secrets Setup Guide

## 📋 Overview

This guide explains how to configure GitHub secrets for automated deployment of the Kubernetes voting app to AWS EKS.

---

## 🔐 Required Secrets

### **Docker Hub Secrets**
Used for pushing container images to Docker Hub registry.

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `DOCKERHUB_USERNAME` | Your Docker Hub username | `kaiserdata` |
| `DOCKERHUB_TOKEN` | Docker Hub access token | `dckr_pat_xxxxxxxxxxxxx` |

**How to get Docker Hub token:**
1. Go to https://hub.docker.com/settings/security
2. Click **New Access Token**
3. Name: `github-actions`
4. Permissions: **Read, Write, Delete**
5. Copy the token (you won't see it again!)

---

### **AWS Secrets**
Used for authenticating with AWS and deploying to EKS cluster.

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | AWS IAM access key ID | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM secret access key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AWS_REGION` | AWS region for EKS cluster | `us-west-1` |

**How to get AWS credentials:**
1. Go to AWS IAM Console: https://console.aws.amazon.com/iam/
2. Click **Users** → Select your user (or create one)
3. Click **Security credentials** tab
4. Click **Create access key**
5. Select **Command Line Interface (CLI)**
6. Copy both Access Key ID and Secret Access Key

**Required IAM Permissions:**
- `eks:DescribeCluster`
- `eks:UpdateClusterConfig`
- `sts:GetCallerIdentity`

---

### **Database Secrets**
Used for PostgreSQL database authentication in Kubernetes.

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `POSTGRES_USER` | PostgreSQL username | `postgres` |
| `POSTGRES_PASSWORD` | PostgreSQL password | `MySecurePass123!` |

**Password Requirements:**
- Minimum 12 characters
- Mix of uppercase, lowercase, numbers, special chars
- Example generator: `openssl rand -base64 16`

---

## 📝 Step-by-Step Setup

### **1. Navigate to Repository Secrets**

**URL Format:**
```
https://github.com/<username>/<repo>/settings/secrets/actions
```

**For this project:**
```
https://github.com/kaiser-data/marty-voting-app/settings/secrets/actions
```

**Or navigate manually:**
1. Go to your GitHub repository
2. Click **Settings** tab (top right)
3. Click **Secrets and variables** (left sidebar)
4. Click **Actions**

---

### **2. Add Each Secret**

For each secret in the tables above:

1. Click **New repository secret** (green button)
2. Enter **Name** (exactly as shown in table)
3. Enter **Value** (your actual credential)
4. Click **Add secret**

**⚠️ Important:**
- Secret names are **case-sensitive**
- You **cannot view** secrets after creation (only update/delete)
- Store credentials securely (password manager recommended)

---

### **3. Verify Secrets**

After adding all secrets, you should see:

```
✅ AWS_ACCESS_KEY_ID          Updated X days ago
✅ AWS_REGION                 Updated X days ago
✅ AWS_SECRET_ACCESS_KEY      Updated X days ago
✅ DOCKERHUB_TOKEN            Updated X days ago
✅ DOCKERHUB_USERNAME         Updated X days ago
✅ POSTGRES_PASSWORD          Updated X days ago
✅ POSTGRES_USER              Updated X days ago
```

---

## 🔄 How Secrets Are Used in CI/CD

### **Workflow File: `.github/workflows/deploy-eks.yaml`**

```yaml
# Docker Hub Login
- name: Login to Docker Hub
  run: echo "${{ secrets.DOCKERHUB_TOKEN }}" | docker login -u "${{ secrets.DOCKERHUB_USERNAME }}" --password-stdin

# AWS Authentication
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ${{ secrets.AWS_REGION }}

# Create Kubernetes Secret
- name: Create database credentials secret
  run: |
    kubectl create secret generic marty-db-credentials \
      --from-literal=POSTGRES_USER=${{ secrets.POSTGRES_USER }} \
      --from-literal=POSTGRES_PASSWORD=${{ secrets.POSTGRES_PASSWORD }} \
      --namespace=marty \
      --dry-run=client -o yaml | kubectl apply -f -
```

---

## 🚀 Deployment Flow

```
1. Push to main branch
   ↓
2. GitHub Actions triggered
   ↓
3. Secrets loaded from repository
   ↓
4. Docker images built & pushed (using DOCKERHUB_*)
   ↓
5. AWS credentials configured (using AWS_*)
   ↓
6. Kubernetes secret created (using POSTGRES_*)
   ↓
7. K8s manifests applied to EKS cluster
   ↓
8. Pods restart with new images and secrets
```

---

## 🔒 Security Best Practices

### **DO:**
- ✅ Use strong, unique passwords for each secret
- ✅ Rotate secrets regularly (every 90 days)
- ✅ Use IAM users with minimal required permissions
- ✅ Enable MFA on AWS accounts
- ✅ Store backup of secrets in password manager
- ✅ Use different credentials for dev/staging/prod

### **DON'T:**
- ❌ Commit secrets to Git (even in comments)
- ❌ Share secrets via Slack/email/chat
- ❌ Use same password for multiple environments
- ❌ Give GitHub Actions admin AWS permissions
- ❌ Hardcode secrets in Kubernetes manifests

---

## 🔧 Troubleshooting

### **Secret Not Working**
```bash
# Check if secret exists in namespace
kubectl get secret marty-db-credentials -n marty

# View secret keys (not values)
kubectl describe secret marty-db-credentials -n marty

# Check workflow logs
# Go to: https://github.com/kaiser-data/marty-voting-app/actions
```

### **Authentication Errors**

**Docker Hub:**
```
Error: denied: requested access to the resource is denied
```
→ Regenerate Docker Hub token with correct permissions

**AWS:**
```
Error: User is not authorized to perform: eks:DescribeCluster
```
→ Add required IAM permissions to AWS user

**Kubernetes:**
```
Error: secrets "marty-db-credentials" not found
```
→ Check workflow logs for secret creation step errors

---

## 🧪 Testing Secrets

### **Manual Secret Creation (for testing)**
```bash
# Connect to EKS cluster
aws eks update-kubeconfig --name ironhack-main-2 --region us-west-1

# Create secret manually
kubectl create secret generic marty-db-credentials \
  --from-literal=POSTGRES_USER=postgres \
  --from-literal=POSTGRES_PASSWORD=test123 \
  --namespace=marty

# Verify
kubectl get secret marty-db-credentials -n marty -o yaml
```

### **Test Deployment Without CI/CD**
```bash
# Apply manifests manually
kubectl apply -f K8s/

# Check pod logs
kubectl logs -n marty -l app=marty-postgres
kubectl logs -n marty -l app=marty-worker
kubectl logs -n marty -l app=marty-result
```

---

## 📚 References

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Docker Hub Access Tokens](https://docs.docker.com/security/for-developers/access-tokens/)

---

## ✅ Checklist Before Pushing

- [ ] All 7 secrets added to GitHub repository settings
- [ ] Docker Hub token has Read/Write/Delete permissions
- [ ] AWS IAM user has EKS permissions
- [ ] PostgreSQL password is strong (12+ chars)
- [ ] Workflow file updated and committed
- [ ] Backup of secrets stored securely
- [ ] Ready to push and trigger deployment

---

**Last Updated:** 2025-11-18
**Repository:** https://github.com/kaiser-data/marty-voting-app
