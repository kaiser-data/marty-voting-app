---
marp: true
theme: default
paginate: true
style: |
  @import 'default';

  /* Harmonious Color Palette */
  :root {
    --primary-dark: #0f172a;
    --primary-blue: #1e40af;
    --accent-blue: #3b82f6;
    --light-bg: #f8fafc;
    --text-light: #e2e8f0;
    --border-color: #cbd5e1;
    --success: #059669;
    --warning: #f59e0b;
    --error: #dc2626;
  }

  /* Base Section Styling */
  section {
    background: var(--primary-dark);
    color: var(--text-light);
    font-family: 'Segoe UI', system-ui, sans-serif;
    padding: 50px 60px;
    font-size: 24px;
  }

  /* Typography Hierarchy - Harmonized */
  h1 {
    color: white;
    font-size: 2.5em;
    font-weight: 700;
    margin-bottom: 0.4em;
    line-height: 1.2;
  }

  h2 {
    color: white;
    font-size: 1.8em;
    font-weight: 600;
    margin-bottom: 0.5em;
    margin-top: 0.3em;
    line-height: 1.3;
  }

  h3 {
    color: #60a5fa;
    font-size: 1.3em;
    font-weight: 600;
    margin: 0.6em 0 0.3em 0;
    line-height: 1.3;
  }

  /* Paragraphs and Lists */
  p, li {
    font-size: 0.95em;
    line-height: 1.5;
    margin-bottom: 0.4em;
  }

  ul, ol {
    margin: 0.5em 0;
    padding-left: 1.5em;
  }

  li {
    margin-bottom: 0.3em;
  }

  /* Code Blocks - Compact */
  pre {
    background: #1e293b !important;
    border-radius: 8px;
    padding: 0.8em 1em !important;
    margin: 0.5em 0 !important;
    font-size: 0.7em !important;
    line-height: 1.4;
    border-left: 3px solid var(--accent-blue);
  }

  code {
    background: rgba(59, 130, 246, 0.15);
    padding: 0.15em 0.3em;
    border-radius: 3px;
    font-size: 0.85em;
  }

  /* Strong Text */
  strong {
    color: #60a5fa;
    font-weight: 600;
  }

  /* Links */
  a {
    color: #60a5fa;
    text-decoration: none;
    border-bottom: 1px solid #60a5fa;
  }

  /* Lead Slides - Title Slides */
  section.lead {
    text-align: center;
    justify-content: center;
    background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
  }

  section.lead h1 {
    font-size: 3em;
    margin-bottom: 0.3em;
  }

  section.lead h2 {
    font-size: 1.5em;
    color: #94a3b8;
    font-weight: 400;
  }

  /* Light Slides */
  section.light {
    background: white;
    color: var(--primary-dark);
  }

  section.light h2,
  section.light h1 {
    color: var(--primary-dark);
  }

  section.light h3 {
    color: var(--primary-blue);
  }

  section.light code {
    background: #e0f2fe;
    color: var(--primary-dark);
  }

  section.light strong {
    color: var(--primary-blue);
  }

  /* Two Column Layout */
  .columns {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 2em;
    margin: 0.8em 0;
  }

  .column {
    padding: 0;
  }

  /* Compact Boxes */
  .box {
    background: rgba(59, 130, 246, 0.1);
    border: 2px solid rgba(59, 130, 246, 0.3);
    border-radius: 8px;
    padding: 0.8em 1em;
    margin: 0.5em 0;
  }

  section.light .box {
    background: #eff6ff;
    border-color: #bfdbfe;
  }

  /* Small Badges */
  .badge {
    display: inline-block;
    padding: 0.25em 0.6em;
    background: rgba(59, 130, 246, 0.2);
    border-radius: 12px;
    font-size: 0.75em;
    font-weight: 500;
    margin: 0.2em 0.3em 0.2em 0;
    border: 1px solid rgba(59, 130, 246, 0.4);
  }

  /* Status Icons - Compact */
  .status-ok::before { content: "✅ "; font-size: 0.9em; }
  .status-error::before { content: "❌ "; font-size: 0.9em; }
  .status-warning::before { content: "⚠️ "; font-size: 0.9em; }

  /* Footer and Header */
  footer {
    font-size: 0.6em;
    color: rgba(255, 255, 255, 0.5);
  }

  section.light footer {
    color: rgba(0, 0, 0, 0.4);
  }

  header {
    font-size: 0.6em;
    color: rgba(255, 255, 255, 0.5);
  }

  /* Image Sizing */
  img {
    max-width: 100%;
    height: auto;
  }

  /* Prevent Overflow */
  section {
    overflow: hidden;
  }

header: ''
footer: '**Marty Kaiser** | Ironhack DevOps Bootcamp 2025'
---

<!-- _class: lead -->

# Multistack App on Kubernetes

## Deploying a Voting Application to AWS EKS

![bg right:35% 85%](BTFF_Kubernetes.png)

<span class="badge">Python</span> <span class="badge">Node.js</span> <span class="badge">.NET</span> <span class="badge">Redis</span> <span class="badge">PostgreSQL</span>

---

<!-- _class: light -->

## Project Overview

<div class="columns">
<div class="column">

### The Challenge
- Multi-language microservices
- Real-time voting system
- Message queue processing
- Production-ready on Kubernetes

</div>
<div class="column">

### Tech Stack
**Vote:** Python/Flask
**Worker:** .NET 7
**Result:** Node.js/Express
**Queue:** Redis
**Database:** PostgreSQL

</div>
</div>

---

## Architecture

```
┌─────────────┐
│   Browser   │ → vote.marty.ironhack.com
└──────┬──────┘   result.marty.ironhack.com
       │
       ▼
┌─────────────────────────────────────┐
│  AWS ELB + NGINX Ingress            │
└──────┬──────────────────┬───────────┘
       │                  │
       ▼                  ▼
  ┌─────────┐        ┌─────────┐
  │  Vote   │        │ Result  │
  │ (Flask) │        │(Node.js)│
  └────┬────┘        └────┬────┘
       │ Writes           │ Reads
       ▼                  │
  ┌─────────┐             │
  │  Redis  │             │
  └────┬────┘             │
       │ Consume          │
       ▼                  │
  ┌─────────┐             │
  │ Worker  │             │
  │  (.NET) │             │
  └────┬────┘             │
       │ Writes           │
       ▼                  ▼
  ┌──────────────────────┐
  │     PostgreSQL       │
  └──────────────────────┘
```

---

## CI/CD Pipeline

### GitHub Actions Workflow

**Trigger:** Push to `main` branch

**1. Build Phase**
- Build Docker images (vote, worker, result)
- Push to Docker Hub

**2. Deploy Phase**
- Configure AWS credentials
- Connect to EKS cluster
- Create Kubernetes secrets
- Apply manifests: `kubectl apply -f K8s/`

<span class="badge">Deployment Time: 7-10 minutes</span>

---

## Problem 1: Infrastructure Issues

### Symptoms
```
Browser: DNS_PROBE_FINISHED_NXDOMAIN
Worker:  Waiting for db... Giving up
```

### Root Causes

**Cluster Migration:** `ironhack-main` → `ironhack-main-2`
- ELB changed, old DNS entries invalid

**Naming Inconsistencies**
- Code: `redis`, `db`, `postgres`
- K8s: `marty-svc-redis`, `marty-svc-postgres`

**Missing Secrets:** Database credentials not created

---

## Solution 1: Infrastructure Fixes

<div class="columns">
<div class="column">

### Networking
<span class="status-ok">Subdomain routing</span>
<span class="status-ok">vote.marty.ironhack.com</span>
<span class="status-ok">No path rewriting</span>

### Security
<span class="status-ok">GitHub Secrets → K8s</span>
<span class="status-ok">Automated injection</span>
<span class="status-ok">CI/CD automation</span>

</div>
<div class="column">

### Configuration
<span class="status-ok">Environment variables</span>
<span class="status-ok">Service discovery</span>
<span class="status-ok">Proper naming</span>

### Ingress
<span class="status-ok">ingressClassName: nginx</span>
<span class="status-ok">Explicit hostnames</span>
<span class="status-ok">Modern API version</span>

</div>
</div>

---

<!-- _class: lead -->

# Problem 2
## The Wildcard Ingress Mystery

![bg right:40% 80%](Gaga_or_Taylor.jpg)

---

## Wildcard Ingress Issue

### What Happened?

Accessing `vote.marty.ironhack.com` showed **Taylor Swift vs Lady Gaga** instead of **Cats vs Dogs**.

### Root Cause

```yaml
# Another team's Ingress
spec:
  rules:
  - http:  # ⚠️ No "host:" = catches ALL traffic
      paths:
      - path: /vote
```

**Issue:** Ingress without `host` field acts as catch-all

---

## Solution 2: Explicit Hosts

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: marty-ingress
  namespace: marty
spec:
  ingressClassName: nginx
  rules:
  - host: vote.marty.ironhack.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: marty-svc-vote
            port:
              number: 80
  - host: result.marty.ironhack.com
    # ... similar configuration
```

**Key Learning:** Always specify explicit `host` values

---

## Problem 3: Hardcoded Connections

<div class="columns">
<div class="column">

### Vote App (Flask)
```python
# ❌ Before
Redis(host="redis")

# ✅ After
redis_host = os.getenv(
  'REDIS_HOST', 'redis'
)
Redis(host=redis_host)
```

</div>
<div class="column">

### Result App (Node.js)
```javascript
// ❌ Before
'postgres://postgres:postgres@db'

// ✅ After
`postgres://${process.env.POSTGRES_USER}:
${process.env.POSTGRES_PASSWORD}@
${process.env.POSTGRES_HOST}`
```

</div>
</div>

---

## Problem 3: Worker Variables

<div class="columns">
<div class="column">

### Wrong Config
```yaml
env:
  - name: POSTGRES_HOST
  - name: POSTGRES_USER
```

Code expected different names!

</div>
<div class="column">

### Corrected
```yaml
env:
  - name: DB_HOST
    value: "marty-svc-postgres"
  - name: DB_USERNAME
    valueFrom:
      secretKeyRef:
        name: marty-db-credentials
        key: POSTGRES_USER
```

</div>
</div>

---

<!-- _class: light -->

## Summary

### What We Accomplished

<span class="status-ok">Multi-language microservices on Kubernetes</span>
<span class="status-ok">AWS ELB + NGINX Ingress routing</span>
<span class="status-ok">Secure secret management</span>
<span class="status-ok">Automated CI/CD pipeline</span>
<span class="status-ok">Real-time voting with WebSockets</span>

### Skills Demonstrated

**Kubernetes:** Deployments, Services, Ingress, Secrets
**AWS:** EKS, ELB, IAM permissions
**Docker:** Multi-stage builds, image management
**Networking:** DNS resolution, load balancing
**CI/CD:** GitHub Actions automation

---

<!-- _class: lead -->

# Questions?

![bg 60%](kubernetes-meme_final_page.jpg)

---

<!-- _class: lead -->

# Thank You!

### Project Repository
https://github.com/kaiser-data/marty-voting-app

### Live Application
**Vote:** http://vote.marty.ironhack.com
**Result:** http://result.marty.ironhack.com

---
