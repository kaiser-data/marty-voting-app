---
marp: true
theme: default
paginate: true
style: |
  @import 'default';

  /* Custom Color Palette */
  :root {
    --color-primary: #1a1f3a;
    --color-secondary: #2d3561;
    --color-k8s-blue: #326CE5;
    --color-aws-orange: #FF9900;
    --color-success: #10B981;
    --color-error: #EF4444;
    --color-warning: #F59E0B;
    --color-code-bg: #1e293b;
    --color-light: #f8fafc;
    --gradient-primary: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    --gradient-success: linear-gradient(135deg, #10B981 0%, #059669 100%);
    --gradient-error: linear-gradient(135deg, #EF4444 0%, #DC2626 100%);
    --gradient-dark: linear-gradient(135deg, #1a1f3a 0%, #2d3561 100%);
  }

  /* Base Styling */
  section {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  }

  /* Headers */
  h1 {
    color: white;
    font-size: 3.5em;
    font-weight: 800;
    text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
    margin-bottom: 0.3em;
  }

  h2 {
    color: white;
    font-size: 2.2em;
    font-weight: 700;
    border-bottom: 3px solid rgba(255,255,255,0.3);
    padding-bottom: 0.3em;
    margin-bottom: 0.5em;
  }

  h3 {
    color: #fbbf24;
    font-size: 1.6em;
    font-weight: 600;
    margin-top: 0.8em;
  }

  /* Code Blocks */
  pre {
    background: var(--color-code-bg) !important;
    border-radius: 12px;
    padding: 1.5em !important;
    box-shadow: 0 8px 16px rgba(0,0,0,0.3);
    border-left: 4px solid var(--color-k8s-blue);
  }

  code {
    background: rgba(0,0,0,0.3);
    padding: 0.2em 0.4em;
    border-radius: 4px;
    font-size: 0.9em;
  }

  /* Lists */
  ul, ol {
    font-size: 1.1em;
    line-height: 1.8;
  }

  li {
    margin-bottom: 0.5em;
  }

  /* Strong Text */
  strong {
    color: #fbbf24;
    font-weight: 700;
  }

  /* Links */
  a {
    color: #60a5fa;
    text-decoration: none;
    border-bottom: 2px solid #60a5fa;
    transition: all 0.3s;
  }

  a:hover {
    color: #93c5fd;
    border-bottom-color: #93c5fd;
  }

  /* Lead Slides */
  section.lead {
    text-align: center;
    justify-content: center;
  }

  section.lead h1 {
    font-size: 4em;
    margin-bottom: 0.2em;
  }

  /* Content Slides */
  section.content {
    background: white;
    color: var(--color-primary);
  }

  section.content h2 {
    color: var(--color-primary);
    border-bottom-color: var(--color-k8s-blue);
  }

  section.content h3 {
    color: var(--color-k8s-blue);
  }

  section.content code {
    background: #e2e8f0;
    color: var(--color-primary);
  }

  /* Problem Slides */
  section.problem {
    background: var(--gradient-error);
  }

  section.problem h2::before {
    content: "⚠️ ";
  }

  /* Solution Slides */
  section.solution {
    background: var(--gradient-success);
  }

  section.solution h2::before {
    content: "✅ ";
  }

  /* Tech Slides */
  section.tech {
    background: var(--gradient-dark);
  }

  /* Emoji Sizing */
  section h2::before,
  section h3::before {
    font-size: 0.9em;
  }

  /* Badge Styling */
  .badge {
    display: inline-block;
    padding: 0.3em 0.8em;
    background: rgba(255,255,255,0.2);
    border-radius: 20px;
    font-size: 0.85em;
    font-weight: 600;
    margin: 0.2em;
    border: 2px solid rgba(255,255,255,0.4);
  }

  /* Highlight Boxes */
  .highlight {
    background: rgba(255,255,255,0.15);
    padding: 1em 1.5em;
    border-radius: 12px;
    border-left: 5px solid #fbbf24;
    margin: 1em 0;
  }

  /* Timeline */
  .timeline {
    display: flex;
    justify-content: space-between;
    margin: 1.5em 0;
  }

  .timeline-item {
    flex: 1;
    text-align: center;
    padding: 1em;
    background: rgba(255,255,255,0.1);
    border-radius: 8px;
    margin: 0 0.5em;
  }

  /* Grid Layout */
  .grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 1.5em;
    margin: 1em 0;
  }

  .grid-item {
    background: rgba(255,255,255,0.1);
    padding: 1.2em;
    border-radius: 10px;
    border: 2px solid rgba(255,255,255,0.2);
  }

  /* Footer Styling */
  footer {
    font-size: 0.7em;
    color: rgba(255,255,255,0.7);
  }

  /* Header Styling */
  header {
    font-size: 0.7em;
    color: rgba(255,255,255,0.7);
  }

header: ''
footer: '**Marty Kaiser** | Ironhack DevOps Bootcamp 2025'
---

<!-- _class: lead -->

# 🚀 Multistack App on Kubernetes

## Deploying a Full-Stack Voting Application to AWS EKS

![bg right:40% 90%](BTFF_Kubernetes.png)

<div class="badge">Python</div> <div class="badge">Node.js</div> <div class="badge">.NET</div> <div class="badge">Redis</div> <div class="badge">PostgreSQL</div>

**Platform:** Kubernetes on AWS EKS

---

<!-- _class: content -->

## 📋 Project Overview

<div class="grid">
<div class="grid-item">

### 🎯 The Challenge
Deploy a **multi-language microservices application** to Kubernetes with:
- ⚡ Real-time voting system
- 🔄 Message queue processing
- 💾 Database persistence
- 🏗️ Production-ready infrastructure

</div>
<div class="grid-item">

### 🛠️ Tech Stack
- **Vote Service:** Python/Flask
- **Worker Service:** .NET 7
- **Result Service:** Node.js/Express
- **Queue:** Redis
- **Database:** PostgreSQL

</div>
</div>

---

<!-- _class: tech -->

## 🏗️ Architecture & Infrastructure

```mermaid
graph TB
    Browser[🌐 Browser]
    ELB[☁️ AWS ELB + NGINX Ingress]
    Vote[🗳️ Vote Pod<br/>Flask/Python]
    Result[📊 Result Pod<br/>Node.js]
    Redis[(🔴 Redis<br/>Queue)]
    Worker[⚙️ Worker Pod<br/>.NET 7]
    DB[(🐘 PostgreSQL<br/>Database)]

    Browser -->|vote.marty.ironhack.com| ELB
    Browser -->|result.marty.ironhack.com| ELB
    ELB --> Vote
    ELB --> Result
    Vote -->|Writes| Redis
    Redis -->|Consume| Worker
    Worker -->|Writes| DB
    Result -->|Reads| DB

    style Browser fill:#60a5fa
    style ELB fill:#ff9900
    style Vote fill:#10b981
    style Result fill:#10b981
    style Redis fill:#ef4444
    style Worker fill:#8b5cf6
    style DB fill:#3b82f6
```

<div class="highlight">
<strong>Data Flow:</strong> Browser → Vote → Redis → Worker → PostgreSQL → Result → Browser
</div>

---

<!-- _class: tech -->

## 🔄 CI/CD Workflow

<div class="timeline">
<div class="timeline-item">

**1️⃣ Trigger**
Push to `main`

</div>
<div class="timeline-item">

**2️⃣ Build**
Docker images
→ Docker Hub

</div>
<div class="timeline-item">

**3️⃣ Deploy**
AWS + EKS
K8s Secrets

</div>
<div class="timeline-item">

**4️⃣ Result**
Production!
✅

</div>
</div>

### Pipeline Details

```yaml
GitHub Actions → Docker Build → Push to Registry
                    ↓
              Configure AWS Credentials
                    ↓
              Connect to EKS (ironhack-main-2)
                    ↓
              Create K8s Secrets from GitHub Secrets
                    ↓
              kubectl apply -f K8s/
```

<div class="badge">⏱️ Deployment Time: 7-10 minutes</div>

---

<!-- _class: problem -->

## Problem 1: Infrastructure & Configuration Hell

### 🚨 Multiple Issues Stacking Up

```bash
Browser: "DNS_PROBE_FINISHED_NXDOMAIN"
Worker:  "Waiting for db... Giving up"
```

### 🔍 Root Causes

<div class="grid">
<div class="grid-item">

**1. Cluster Migration**
`ironhack-main` → `ironhack-main-2`
- ELB changed
- Old DNS entries invalid

**2. Naming Chaos**
- Code: `redis`, `db`, `postgres`
- K8s: `marty-svc-redis`, `marty-svc-postgres`

</div>
<div class="grid-item">

**3. Missing Secrets**
`marty-db-credentials` never created

**4. Path Routing Issues**
- Apps expect `/`
- Ingress sent `/vote`, `/result`

</div>
</div>

---

<!-- _class: solution -->

## Solutions Applied

<div class="grid">
<div class="grid-item">

### 🌐 Networking
✅ Subdomain routing
✅ `vote.marty.ironhack.com`
✅ No path rewriting needed
✅ Modern Ingress config

</div>
<div class="grid-item">

### 🔐 Security
✅ GitHub Secrets → K8s Secrets
✅ Automated injection
✅ No hardcoded credentials
✅ CI/CD automation

</div>
</div>

<div class="grid">
<div class="grid-item">

### ⚙️ Configuration
✅ Environment variables
✅ 12-factor methodology
✅ Service discovery
✅ `marty-svc-*` naming

</div>
<div class="grid-item">

### 🏷️ Ingress Modernization
✅ `ingressClassName: nginx`
✅ Explicit hostname matching
✅ Conflict prevention
✅ Production-ready

</div>
</div>

---

<!-- _class: lead -->

# 🎤 Problem 2: The Wildcard Ingress Mystery

### Unexpected Traffic Routing

![bg right:50% 90%](Gaga_or_Taylor.jpg)

---

<!-- _class: problem -->

## The Wildcard Ingress Challenge

### 🤔 What Happened?

Accessing `vote.marty.ironhack.com` unexpectedly displayed a different voting application **(Taylor Swift vs Lady Gaga)** instead of the intended **Cats vs Dogs** interface.

### 🔬 Root Cause Analysis

```yaml
# Another team's Ingress configuration
spec:
  rules:
  - http:  # ⚠️ No "host:" field = matches ALL traffic!
      paths:
      - path: /vote
```

<div class="highlight">
<strong>💡 Issue:</strong> An Ingress without a specified <code>host</code> field acts as a catch-all, matching requests that don't explicitly match other rules.
</div>

---

<!-- _class: solution -->

## The Solution

### ✅ Explicit Hostname Matching

```yaml
# Updated Ingress - Specific routing
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: marty-ingress
  namespace: marty
spec:
  ingressClassName: nginx  # Modern approach
  rules:
  - host: vote.marty.ironhack.com      # ✅ Explicit
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: marty-svc-vote
            port:
              number: 80
  - host: result.marty.ironhack.com    # ✅ Prevents conflicts
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: marty-svc-result
            port:
              number: 80
```

---

<!-- _class: problem -->

## Problem 3: Hardcoded Connections Everywhere

<div class="grid">
<div class="grid-item">

### 🐍 Vote App (Flask)

```python
# ❌ Before
Redis(host="redis")

# ✅ After
redis_host = os.getenv(
    'REDIS_HOST',
    'redis'
)
Redis(host=redis_host)
```

</div>
<div class="grid-item">

### 🟢 Result App (Node.js)

```javascript
// ❌ Before
connectionString:
  'postgres://postgres:postgres@db/postgres'

// ✅ After
connectionString:
  `postgres://${process.env.POSTGRES_USER}:
   ${process.env.POSTGRES_PASSWORD}@
   ${process.env.POSTGRES_HOST}/
   ${process.env.POSTGRES_DB}`
```

</div>
</div>

---

<!-- _class: problem -->

## Problem 3: Worker Environment Variables

### 🔵 Worker App (.NET)

<div class="grid">
<div class="grid-item">

**❌ Wrong Deployment Config**

```yaml
env:
  - name: POSTGRES_HOST
  - name: POSTGRES_USER
  - name: POSTGRES_PASSWORD
```

*Code expected different variable names!*

</div>
<div class="grid-item">

**✅ Corrected Variables**

```yaml
env:
  - name: DB_HOST
    value: "marty-svc-postgres"
  - name: DB_USERNAME
    valueFrom:
      secretKeyRef:
        name: marty-db-credentials
        key: POSTGRES_USER
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: marty-db-credentials
        key: POSTGRES_PASSWORD
```

</div>
</div>

---

<!-- _class: solution -->

## 🎯 Complete Solution Framework

<div class="grid">
<div class="grid-item">

### 🔐 Security
- GitHub Secrets → K8s Secrets
- No credentials in code/manifests
- Automated secret injection
- CI/CD automation

### 🌐 Networking
- Subdomain-based routing
- Service discovery (`marty-svc-*`)
- NGINX Ingress + explicit hosts
- AWS ELB integration

</div>
<div class="grid-item">

### ⚙️ Configuration
- Environment variables everywhere
- 12-factor app methodology
- Docker Compose → K8s migration
- Proper service naming

### 🚀 DevOps
- Automated CI/CD pipeline
- Infrastructure as Code
- Pod restart automation
- Image update handling

</div>
</div>

---

<!-- _class: content -->

## 🏆 Summary & Key Learnings

### What We Accomplished

<div class="grid">
<div class="grid-item">

✅ Multi-language microservices
✅ AWS ELB + NGINX Ingress routing
✅ Secure secret management
✅ Automated CI/CD pipeline
✅ Real-time WebSocket updates

</div>
<div class="grid-item">

**Technical Skills Demonstrated:**
- **Kubernetes:** Deployments, Services, Ingress, Secrets
- **AWS:** EKS, ELB, IAM
- **Docker:** Multi-stage builds, registries
- **Networking:** DNS, load balancing
- **CI/CD:** GitHub Actions
- **Debugging:** Systematic troubleshooting

</div>
</div>

---

<!-- _class: lead -->

# ❓ Questions?

![bg 70%](kubernetes-meme_final_page.jpg)

---

<!-- _class: lead -->

# 🙏 Thank You!

### 📦 Project Repository
https://github.com/kaiser-data/marty-voting-app

### 🌐 Live Application
🗳️ **Vote:** http://vote.marty.ironhack.com
📊 **Result:** http://result.marty.ironhack.com

### 📚 Documentation
✅ Complete troubleshooting guide
✅ GitHub Secrets setup
✅ CI/CD workflow documentation

---

**Marty Kaiser | Ironhack DevOps Bootcamp 2025**
