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
│  AWS ELB + NGINX Ingress (K8s)      │
│  (Integrated routing layer)         │
└──────┬──────────────────┬───────────┘
       │                  │
       ▼                  ▼
┌─────────────┐    ┌─────────────┐
│  Vote Pod   │    │ Result Pod  │
│  (Flask)    │    │  (Node.js)  │
└──────┬──────┘    └──────┬──────┘
       │                  │
       │ Writes           │ Reads
       ▼                  │
┌─────────────┐           │
│    Redis    │           │
│   (Queue)   │           │
└──────┬──────┘           │
       │                  │
       │ Consume          │
       ▼                  │
┌─────────────┐           │
│ Worker Pod  │           │
│   (.NET)    │           │
└──────┬──────┘           │
       │                  │
       │ Writes           │
       ▼                  ▼
┌─────────────────────────┐
│      PostgreSQL         │
│      (Database)         │
└─────────────────────────┘
```

**Data Flow:** Browser → Vote → Redis → Worker → PostgreSQL → Result → Browser

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

## Problem 1: Infrastructure & Configuration Hell

### Multiple Issues Stacking Up
```
Browser: "DNS_PROBE_FINISHED_NXDOMAIN"
Worker: "Waiting for db... Giving up"
```

### Root Causes
1. **Cluster Migration:** Moving from `ironhack-main` → `ironhack-main-2`
   - ELB changed, old DNS entries invalid
2. **Naming Inconsistencies:**
   - Code: `redis`, `db`, `postgres`
   - K8s: `marty-svc-redis`, `marty-svc-postgres`
3. **Missing Secrets:** `marty-db-credentials` never created
4. **Path Routing:** Flask/Node apps expect `/` not `/vote`, `/result`

### Solutions Applied
- ✅ Subdomain routing: `vote.marty.ironhack.com` (no path rewriting)
- ✅ GitHub Secrets → K8s Secrets automation
- ✅ Environment variables for all connections
- ✅ Modern Ingress: `ingressClassName: nginx`

---

<!-- _class: lead -->

# Problem 2: The Wildcard Ingress Mystery

### Unexpected Traffic Routing 🎤

![bg right:50% 90%](Gaga_or_Taylor.jpg)

---

## The Wildcard Ingress Challenge

### What Happened?
Accessing `vote.marty.ironhack.com` unexpectedly displayed a different voting application (Taylor Swift vs Lady Gaga) instead of the intended Cats vs Dogs interface.

### Root Cause Analysis
```yaml
# Another team's Ingress configuration
spec:
  rules:
  - http:  # ← No "host:" field = matches ALL traffic!
      paths:
      - path: /vote
```

**Issue**: An Ingress without a specified `host` field acts as a catch-all, matching requests that don't explicitly match other rules.

### The Solution
```yaml
# Updated Ingress - Explicit hostname matching
spec:
  rules:
  - host: vote.marty.ironhack.com    # ✅ Specific routing
  - host: result.marty.ironhack.com  # ✅ Prevents conflicts
```

**Key Learning**: Always specify explicit `host` values in Ingress rules to prevent unintended traffic routing in shared Kubernetes clusters.

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
