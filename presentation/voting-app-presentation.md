---
marp: true
theme: default
paginate: true
style: |
  @import 'default';

  /* Professional Color Palette */
  :root {
    --navy: #1e3a8a;
    --blue: #2563eb;
    --sky: #0ea5e9;
    --slate: #334155;
  }

  /* Base Styling - REDUCED HEIGHT */
  section {
    background: white;
    color: var(--slate);
    font-family: 'Segoe UI', -apple-system, sans-serif;
    padding: 40px 70px 50px 70px;
    font-size: 24px;
    line-height: 1.5;
  }

  /* Typography - COMPACT */
  h1 {
    color: var(--navy);
    font-size: 2.3em;
    font-weight: 700;
    margin: 0 0 0.4em 0;
    line-height: 1.1;
  }

  h2 {
    color: var(--blue);
    font-size: 1.7em;
    font-weight: 600;
    margin: 0.5em 0 0.4em 0;
    line-height: 1.2;
  }

  h3 {
    color: var(--sky);
    font-size: 1.2em;
    font-weight: 600;
    margin: 0.4em 0 0.3em 0;
    line-height: 1.2;
  }

  /* Text Elements - COMPACT */
  p {
    margin-bottom: 0.4em;
    line-height: 1.5;
  }

  ul, ol {
    margin: 0.4em 0;
    padding-left: 1.5em;
  }

  li {
    margin-bottom: 0.35em;
    line-height: 1.4;
  }

  strong {
    color: var(--navy);
    font-weight: 600;
  }

  /* Code Blocks - COMPACT & READABLE */
  pre {
    background: #f1f5f9 !important;
    border: 2px solid #e2e8f0;
    border-radius: 6px;
    padding: 0.8em !important;
    margin: 0.5em 0 !important;
    font-size: 0.65em !important;
    line-height: 1.4;
    color: var(--slate) !important;
  }

  pre code {
    background: transparent !important;
    color: var(--slate) !important;
    font-family: 'Consolas', 'Monaco', monospace;
  }

  code {
    background: #f1f5f9;
    color: var(--navy);
    padding: 0.15em 0.35em;
    border-radius: 3px;
    font-size: 0.85em;
    font-family: 'Consolas', monospace;
  }

  /* Links */
  a {
    color: var(--blue);
    text-decoration: none;
    border-bottom: 1px solid var(--blue);
  }

  /* Dark Header Slides */
  section.dark {
    background: var(--navy);
    color: white;
  }

  section.dark h1,
  section.dark h2,
  section.dark h3 {
    color: white;
  }

  section.dark code {
    background: rgba(255,255,255,0.15);
    color: white;
  }

  /* Two Column Layout */
  .columns {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 2em;
    margin: 0.6em 0;
  }

  /* Badges - INLINE */
  .badge {
    display: inline-block;
    padding: 0.25em 0.65em;
    background: #f1f5f9;
    border: 2px solid #e2e8f0;
    border-radius: 14px;
    font-size: 0.75em;
    font-weight: 500;
    margin-right: 0.5em;
    margin-bottom: 0.3em;
    color: var(--navy);
    white-space: nowrap;
  }

  /* Checkmarks */
  .check {
    color: #059669;
    font-weight: 600;
    font-size: 0.95em;
  }

  .check::before {
    content: "✓ ";
  }

  /* Footer - RIGHT BOTTOM CORNER */
  footer {
    position: absolute;
    right: 70px;
    bottom: 30px;
    left: auto;
    text-align: right;
    font-size: 0.6em;
    color: #94a3b8;
  }

  section.dark footer {
    color: rgba(255,255,255,0.5);
  }

header: ''
footer: 'Marty Kaiser | Ironhack DevOps 2025'
---

<!-- _class: dark -->

# Multistack App on Kubernetes

## Deploying a Voting Application to AWS EKS

![bg right:35% 90%](BTFF_Kubernetes.png)

<span class="badge">Python</span><span class="badge">Node.js</span><span class="badge">.NET</span><span class="badge">Redis</span><span class="badge">PostgreSQL</span>

---

## Project Overview

<div class="columns">
<div>

### The Challenge
- Multi-language microservices
- Real-time voting system
- Message queue processing
- Production-ready Kubernetes

</div>
<div>

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
Browser (User)
   ↓
AWS ELB (Load Balancer)
   ↓
╔═══════════════════════════════════════╗
║   Kubernetes Cluster (EKS)            ║
║                                       ║
║  ┌─────────────────────────────────┐ ║
║  │ NGINX Ingress Controller Pod    │ ║
║  │ (Pre-installed infrastructure)  │ ║
║  └──────────┬──────────────┬───────┘ ║
║             │              │          ║
║  ┌──────────▼──┐   ┌───────▼──────┐ ║
║  │ Vote Pod    │   │ Result Pod   │ ║
║  │ (Flask)     │   │ (Node.js)    │ ║
║  └──────┬──────┘   └───────┬──────┘ ║
║         │ Writes            │ Reads  ║
║         ↓                   ↓        ║
║  ┌───────────┐       ┌────────────┐ ║
║  │ Redis Pod │       │Postgres Pod│ ║
║  └─────┬─────┘       └──────┬─────┘ ║
║        │ Consume            ↑        ║
║        ↓                    │        ║
║  ┌─────────────┐            │        ║
║  │ Worker Pod  │────────────┘        ║
║  │ (.NET)      │  Writes             ║
║  └─────────────┘                     ║
╚═══════════════════════════════════════╝
```

---

## CI/CD Pipeline

**Trigger:** Push to `main` branch

**Build Phase:**
- Build Docker images (vote, worker, result)
- Push to Docker Hub

**Deploy Phase:**
- Connect to EKS cluster
- Create Kubernetes secrets
- Apply manifests: `kubectl apply -f K8s/`

<span class="badge">Deployment: 7-10 min</span>

---

## Problem 1: Infrastructure Issues

**Symptoms:**
```
Browser: DNS_PROBE_FINISHED_NXDOMAIN
Worker:  Waiting for db... Giving up
```

**Root Causes:**

**Cluster Migration** `ironhack-main` → `ironhack-main-2`
- ELB changed, old DNS invalid

**Naming Chaos** - Code vs Kubernetes
- Code: `redis`, `db` | K8s: `marty-svc-redis`, `marty-svc-postgres`

**Missing Secrets** - Database credentials never created

---

## Solution 1: Infrastructure Fixes

<div class="columns">
<div>

**Networking**
<p class="check">Subdomain routing</p>
<p class="check">vote.marty.ironhack.com</p>
<p class="check">No path rewriting</p>

**Security**
<p class="check">GitHub Secrets → K8s</p>
<p class="check">Automated injection</p>

</div>
<div>

**Configuration**
<p class="check">Environment variables</p>
<p class="check">Service discovery</p>
<p class="check">Proper naming</p>

**Ingress**
<p class="check">ingressClassName: nginx</p>
<p class="check">Explicit hostnames</p>

</div>
</div>

---

<!-- _class: dark -->

# Problem 2

## The Wildcard Ingress Mystery

![bg right:40% 85%](Gaga_or_Taylor.jpg)

---

## Wildcard Ingress Issue

**What Happened?**

Accessing `vote.marty.ironhack.com` showed **Taylor Swift vs Lady Gaga** instead of **Cats vs Dogs**.

**Root Cause:**

```yaml
# Another team's Ingress
spec:
  rules:
  - http:  # No "host:" = catches ALL
      paths:
      - path: /vote
```

Ingress without `host` field acts as catch-all.

---

## Solution 2: Explicit Hosts

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: marty-ingress
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
            port: {number: 80}
```

**Key Learning:** Always specify explicit `host` values

---

## Problem 3: Hardcoded Connections

<div class="columns">
<div>

**Vote (Flask)**
```python
# Before
Redis(host="redis")

# After
redis_host = os.getenv(
  'REDIS_HOST', 'redis'
)
Redis(host=redis_host)
```

</div>
<div>

**Result (Node.js)**
```javascript
// Before
'postgres://user:pass@db'

// After
`postgres://${process.env.POSTGRES_USER}:
${process.env.POSTGRES_PASSWORD}@
${process.env.POSTGRES_HOST}`
```

</div>
</div>

---

## Problem 3: Worker Variables

<div class="columns">
<div>

**Wrong Config**
```yaml
env:
  - name: POSTGRES_HOST
  - name: POSTGRES_USER
```

Code expected different names!

</div>
<div>

**Corrected**
```yaml
env:
  - name: DB_HOST
    value: "marty-svc-postgres"
  - name: DB_USERNAME
    valueFrom:
      secretKeyRef:
        name: marty-db-credentials
```

</div>
</div>

---

## Summary

**What We Accomplished:**

<p class="check">Multi-language microservices on Kubernetes</p>
<p class="check">AWS ELB + NGINX Ingress routing</p>
<p class="check">Secure secret management</p>
<p class="check">Automated CI/CD pipeline</p>

**Skills Demonstrated:**

**Kubernetes** - Deployments, Services, Ingress, Secrets
**AWS** - EKS, ELB
**Docker** - Multi-stage builds
**CI/CD** - GitHub Actions

---

<!-- _class: dark -->

# Questions?

![bg 65%](kubernetes-meme_final_page.jpg)

---

<!-- _class: dark -->

# Thank You!

**Project Repository**
https://github.com/kaiser-data/marty-voting-app

**Live Application**
Vote: http://vote.marty.ironhack.com
Result: http://result.marty.ironhack.com

---
