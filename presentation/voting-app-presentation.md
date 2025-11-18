---
marp: true
theme: default
paginate: true
backgroundColor: #fff
backgroundImage: url('https://marp.app/assets/hero-background.svg')
header: 'Multistack App on Kubernetes | Ironhack Project'
footer: 'Marty Kaiser | 2025'
---

<!-- _class: lead -->

# Multistack App on Kubernetes

## Deploying a Full-Stack Voting Application to AWS EKS

![bg right:40% 80%](BTFF_Kubernetes.png)

**Technologies:** Python • Node.js • .NET • Redis • PostgreSQL
**Platform:** Kubernetes on AWS EKS

---

## Project Overview

### The Challenge
Deploy a **multi-language microservices application** to Kubernetes with:
- Real-time voting system
- Message queue processing
- Database persistence
- Production-ready infrastructure

### Tech Stack
- **Vote Service:** Python/Flask
- **Worker Service:** .NET 7
- **Result Service:** Node.js/Express
- **Queue:** Redis
- **Database:** PostgreSQL

---

## Architecture & Infrastructure

```
┌─────────────┐
│   Browser   │ → vote.marty.ironhack.com
└──────┬──────┘   result.marty.ironhack.com
       │
       ▼
┌─────────────────────────────────────┐
│    AWS Elastic Load Balancer        │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│   NGINX Ingress Controller (K8s)    │
└──────┬──────────────────┬───────────┘
       │                  │
       ▼                  ▼
┌─────────────┐    ┌─────────────┐
│  Vote Pod   │    │ Result Pod  │
└──────┬──────┘    └──────┬──────┘
       │                  │
       ▼                  │
┌─────────────┐           │
│    Redis    │◄──┬───────┘
└──────┬──────┘   │
       │          │
       ▼          │
┌─────────────┐   │
│ Worker Pod  │───┤
└──────┬──────┘   │
       │          │
       ▼          ▼
┌─────────────────────┐
│    PostgreSQL       │
└─────────────────────┘
```

---

## CI/CD Workflow

### GitHub Actions Pipeline

1. **Trigger:** Push to `main` branch
2. **Build Phase:**
   - Build Docker images for vote, worker, result
   - Push to Docker Hub (`kaiserdata/*:latest`)
3. **Deploy Phase:**
   - Configure AWS credentials
   - Connect to EKS cluster (`ironhack-main-2`)
   - Create Kubernetes secrets from GitHub Secrets
   - Apply manifests (`kubectl apply -f K8s/`)
4. **Result:** Automatic deployment to production

**Deployment Time:** ~7-10 minutes

---

## Problem 1: DNS Resolution Chaos

### The Issue
```
Browser: "DNS_PROBE_FINISHED_NXDOMAIN"
```

### Root Causes
1. **Outdated /etc/hosts entry** pointing to deleted ELB
   ```bash
   # ❌ Old entry
   ac4ad35e3a4964c368b127366d7be51a...elb.amazonaws.com  marty.ironhack.com
   ```
2. **Hostname mismatch:** Ingress configured for `marty-v1.ironhack.com`
3. **Path rewriting issues:** Flask/Node apps expect `/` not `/vote`

### Solution
- ✅ Subdomain-based routing: `vote.marty.ironhack.com`
- ✅ Direct IP mapping: `13.57.86.174 → vote.marty.ironhack.com`
- ✅ Modern Ingress: `ingressClassName: nginx`

---

<!-- _class: lead -->

# Problem 2: Taylor Swift vs Lady Gaga

### Or: The Wildcard Ingress War 🎤

![bg right:50% 90%](Gaga_or_Taylor.jpg)

---

## The Wildcard Ingress Battle

### What Happened?
Accessing `vote.marty.ironhack.com` showed **Jakob's voting app** (Taylor Swift vs Lady Gaga) instead of mine (Cats vs Dogs)!

### The Culprit
```yaml
# Jakob's Ingress
spec:
  rules:
  - http:  # ← No "host:" = matches EVERYTHING!
      paths:
      - path: /vote
```

### The Fix
```yaml
# My Ingress - Specific hostnames
spec:
  rules:
  - host: vote.marty.ironhack.com    # ✅ Explicit
  - host: result.marty.ironhack.com  # ✅ Explicit
```

**Lesson:** Wildcard Ingress rules catch all unmatched traffic!

---

## Problem 3: Hardcoded Connections Everywhere

### Vote App (Flask)
```python
# ❌ Before
Redis(host="redis")

# ✅ After
Redis(host=os.getenv('REDIS_HOST', 'redis'))
```

### Worker App (.NET)
```yaml
# ❌ Wrong env vars
POSTGRES_HOST, POSTGRES_USER...

# ✅ Correct vars
DB_HOST, DB_USERNAME, DB_PASSWORD...
```

### Result App (Node.js)
```javascript
// ❌ Before
connectionString: 'postgres://postgres:postgres@db/postgres'

// ✅ After
connectionString: `postgres://${process.env.POSTGRES_USER}:...`
```

---

## Solutions Applied

### 🔐 Security
- GitHub Secrets → Kubernetes Secrets
- No credentials in code/manifests
- Automated secret injection via CI/CD

### 🌐 Networking
- Subdomain-based routing
- Proper service discovery (`marty-svc-*`)
- NGINX Ingress with explicit hostnames

### ⚙️ Configuration
- Environment variables for all connections
- 12-factor app methodology
- Docker Compose → Kubernetes migration

### 🚀 DevOps
- Automated CI/CD with GitHub Actions
- Infrastructure as Code
- Proper pod restarts after image updates

---

## Summary & Key Learnings

### What We Accomplished
✅ Deployed multi-language microservices to Kubernetes
✅ Configured AWS ELB + NGINX Ingress routing
✅ Implemented secure secret management
✅ Automated CI/CD pipeline with GitHub Actions
✅ Real-time voting system with WebSocket updates

### Technical Skills Demonstrated
- **Kubernetes:** Deployments, Services, Ingress, Secrets
- **AWS:** EKS, ELB, IAM permissions
- **Docker:** Multi-stage builds, image management
- **Networking:** DNS resolution, load balancing, service mesh
- **CI/CD:** GitHub Actions, automated deployments
- **Debugging:** Systematic troubleshooting methodology

---

<!-- _class: lead -->

# Questions?

![bg 70%](kubernetes-meme_final_page.jpg)

---

<!-- _class: lead -->

# Thank You!

### Project Repository
https://github.com/kaiser-data/marty-voting-app

### Live Application
- 🗳️ **Vote:** http://vote.marty.ironhack.com
- 📊 **Result:** http://result.marty.ironhack.com

### Documentation
- Complete troubleshooting guide
- GitHub Secrets setup
- CI/CD workflow documentation

**Marty Kaiser | Ironhack DevOps Bootcamp 2025**
