# DNS and Ingress Fix Guide - Kubernetes Voting App

## 📋 Table of Contents
1. [Problem Summary](#problem-summary)
2. [Root Cause Analysis](#root-cause-analysis)
3. [Solution Steps](#solution-steps)
4. [Technical Explanation](#technical-explanation)
5. [Verification](#verification)
6. [Key Learnings](#key-learnings)

---

## 🚨 Problem Summary

### Initial Issue
**Error:** `DNS_PROBE_FINISHED_NXDOMAIN` and `DNS_PROBE_POSSIBLE` in browser

**Symptoms:**
- Browser could not reach `marty.ironhack.com` or `marty-v1.ironhack.com`
- DNS resolution failures
- "This site can't be reached" errors

### Environment
- **Platform:** Kubernetes on AWS EKS
- **Ingress Controller:** NGINX Ingress
- **Load Balancer:** AWS ELB (Classic Load Balancer)
- **DNS Strategy:** Local /etc/hosts file (no real DNS)

---

## 🔍 Root Cause Analysis

### Issue 1: Outdated /etc/hosts Entry ❌

**Problem:**
```bash
# /etc/hosts contained:
ac4ad35e3a4964c368b127366d7be51a-1358328476.us-west-1.elb.amazonaws.com   marty.ironhack.com
```

**Why it failed:**
- This ELB hostname **no longer existed** (deleted or changed)
- DNS lookup for this hostname returned `NXDOMAIN`
- Browser couldn't resolve `marty.ironhack.com` to any IP address

**Verification:**
```bash
$ nslookup ac4ad35e3a4964c368b127366d7be51a-1358328476.us-west-1.elb.amazonaws.com
** server can't find ac4ad35e3a4964c368b127366d7be51a...: NXDOMAIN
```

### Issue 2: Hostname Mismatch 🔀

**Problem:**
- Browser tried to access: `marty.ironhack.com`
- Ingress was configured for: `marty-v1.ironhack.com`
- Host header didn't match, so requests were rejected

### Issue 3: Deprecated Ingress Annotation ⚠️

**Problem:**
```yaml
annotations:
  kubernetes.io/ingress.class: nginx  # Deprecated
```

**Why it's problematic:**
- Old annotation format (pre-Kubernetes 1.18)
- May not be picked up by modern Ingress controllers
- Multiple Ingress controllers might conflict

**Modern approach:**
```yaml
spec:
  ingressClassName: nginx  # Modern, explicit
```

### Issue 4: Path Routing Mismatch 🛣️

**Problem:**
- Ingress sent requests to: `/vote` → Flask app
- Flask app only had route for: `/` (root path)
- Result: **404 Not Found**

**Flask route configuration:**
```python
# vote/app.py:24
@app.route("/", methods=['POST','GET'])
def hello():
    # ...
```

**Why it failed:**
```
User requests: http://marty.ironhack.com/vote
               ↓
Ingress forwards: /vote → Flask
               ↓
Flask expects: / (not /vote)
               ↓
Flask returns: 404 Not Found
```

---

## ✅ Solution Steps

### Step 1: Resolve New ELB to IP Address

```bash
# Get current Ingress ELB hostname
$ kubectl get ingress -n marty
NAME            HOSTS                ADDRESS
marty-ingress   marty-v1.ironhack.com   a587e5dbd9d3c494dbe7caff73f6ff41-942394582.us-west-1.elb.amazonaws.com

# Resolve ELB hostname to IP addresses
$ nslookup a587e5dbd9d3c494dbe7caff73f6ff41-942394582.us-west-1.elb.amazonaws.com
Address: 13.57.86.174
Address: 54.177.38.157
```

**Result:** ELB resolves to two IPs (for high availability). We use `13.57.86.174`.

### Step 2: Fix /etc/hosts Entry

```bash
# Remove old/broken entry
sudo sed -i.bak '/ac4ad35e3a4964c368b127366d7be51a/d' /etc/hosts

# Add correct IP mapping
echo "13.57.86.174  marty.ironhack.com" | sudo tee -a /etc/hosts

# Verify
$ grep "marty.ironhack.com" /etc/hosts
13.57.86.174  marty.ironhack.com
```

**Why this works:**
- Uses actual IP address (not ELB hostname)
- Direct mapping: `marty.ironhack.com` → `13.57.86.174`
- Browser can now resolve the hostname locally

### Step 3: Flush DNS Cache

```bash
# Linux (systemd-resolved)
sudo systemd-resolve --flush-caches

# Or
sudo resolvectl flush-caches
```

**Why necessary:**
- Browser/OS may cache previous DNS failures
- Old "not found" results persist without flushing
- Forces fresh DNS lookups

### Step 4: Update Ingress Hostname

**Changed from:**
```yaml
spec:
  rules:
    - host: marty-v1.ironhack.com  # ❌ Didn't match /etc/hosts
```

**Changed to:**
```yaml
spec:
  rules:
    - host: marty.ironhack.com  # ✅ Matches /etc/hosts
```

**Command:**
```bash
kubectl apply -f K8s/marty-ingress.yaml
```

### Step 5: Modernize Ingress Class

**Changed from:**
```yaml
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx  # ❌ Deprecated
```

**Changed to:**
```yaml
spec:
  ingressClassName: nginx  # ✅ Modern, explicit
```

**Why this matters:**
- Explicitly selects the correct Ingress controller
- Prevents conflicts with multiple controllers (alb, traefik, etc.)
- Follows Kubernetes 1.18+ best practices

### Step 6: Add Path Rewriting

**The Problem:**
```
URL: http://marty.ironhack.com/vote
     ↓
Ingress path: /vote
     ↓
Backend receives: /vote
     ↓
Flask expects: /
     ↓
Result: 404 ❌
```

**The Solution - Path Rewriting:**

```yaml
metadata:
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  rules:
    - host: marty.ironhack.com
      http:
        paths:
          - path: /vote(/|$)(.*)
            pathType: ImplementationSpecific
            backend:
              service:
                name: marty-svc-vote
                port:
                  number: 80
```

**How it works:**

1. **Regex Pattern:** `/vote(/|$)(.*)`
   - `/vote` - Matches the literal path
   - `(/|$)` - Matches `/` or end of string (capture group $1)
   - `(.*)` - Matches anything after (capture group $2)

2. **Rewrite Target:** `/$2`
   - Takes capture group $2 (everything after `/vote/`)
   - Prepends `/` to create new path
   - Forwards to backend

3. **Examples:**
   ```
   Request: /vote       → Backend receives: /
   Request: /vote/      → Backend receives: /
   Request: /vote/test  → Backend receives: /test
   ```

**Applied to both services:**
```yaml
- path: /vote(/|$)(.*)    → marty-svc-vote
- path: /result(/|$)(.*)  → marty-svc-result
```

---

## 🔧 Technical Explanation

### DNS Resolution Flow (Before Fix)

```
Browser: "Where is marty.ironhack.com?"
    ↓
/etc/hosts: "It's at ac4ad35e3a4964c368b127366d7be51a...elb.amazonaws.com"
    ↓
DNS Query: "Where is ac4ad35e3a4964c368b127366d7be51a...?"
    ↓
DNS Server: "NXDOMAIN - doesn't exist"
    ↓
Browser: "DNS_PROBE_POSSIBLE" ❌
```

### DNS Resolution Flow (After Fix)

```
Browser: "Where is marty.ironhack.com?"
    ↓
/etc/hosts: "It's at 13.57.86.174"
    ↓
Browser: Connects to 13.57.86.174 ✅
```

### HTTP Request Flow (Complete)

```
┌─────────────────────────────────────────────────┐
│ Browser                                          │
│ http://marty.ironhack.com/vote                  │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
        ┌────────────────┐
        │  /etc/hosts     │
        │  Lookup         │
        │  marty → 13.57  │
        └────────┬────────┘
                 │
                 ▼
        ┌────────────────────────┐
        │  TCP Connection to     │
        │  13.57.86.174:80       │
        └────────┬───────────────┘
                 │
                 ▼
        ┌────────────────────────┐
        │  AWS ELB               │
        │  (Load Balancer)       │
        └────────┬───────────────┘
                 │
                 ▼
        ┌────────────────────────┐
        │  NGINX Ingress         │
        │  Controller Pod        │
        │  (in EKS cluster)      │
        └────────┬───────────────┘
                 │
                 │ Checks Host header: marty.ironhack.com ✅
                 │ Matches path: /vote
                 │ Applies rewrite: /vote → /
                 │
                 ▼
        ┌────────────────────────┐
        │  Service               │
        │  marty-svc-vote        │
        │  (ClusterIP)           │
        └────────┬───────────────┘
                 │
                 ▼
        ┌────────────────────────┐
        │  Vote Pod              │
        │  (Flask/Python)        │
        │  Receives: GET /       │
        │  Returns: HTML ✅      │
        └────────────────────────┘
```

### Key HTTP Headers

**Request sent by browser:**
```http
GET /vote HTTP/1.1
Host: marty.ironhack.com
User-Agent: Mozilla/5.0...
```

**Ingress forwards to backend:**
```http
GET / HTTP/1.1
Host: marty.ironhack.com
X-Forwarded-For: <client-ip>
X-Forwarded-Proto: http
X-Original-URI: /vote
```

---

## 🧪 Verification

### Test 1: DNS Resolution

```bash
# Test local DNS resolution
$ ping -c 2 marty.ironhack.com
PING marty.ironhack.com (13.57.86.174) 56(84) bytes of data.
64 bytes from 13.57.86.174: icmp_seq=1 ttl=52 time=11.2 ms
64 bytes from 13.57.86.174: icmp_seq=2 ttl=52 time=10.8 ms
```
✅ **Success:** Resolves to correct IP

### Test 2: HTTP Connection with curl

```bash
# Test vote endpoint
$ curl -I http://marty.ironhack.com/vote
HTTP/1.1 200 OK
Date: Thu, 18 Jan 2025 ...
Content-Type: text/html; charset=utf-8
Server: nginx

# Test result endpoint
$ curl -I http://marty.ironhack.com/result
HTTP/1.1 200 OK
Date: Thu, 18 Jan 2025 ...
Content-Type: text/html; charset=utf-8
Server: nginx
```
✅ **Success:** Both endpoints return 200 OK

### Test 3: Browser Access

**Vote Page:** http://marty.ironhack.com/vote
- ✅ Shows "Cats vs Dogs" voting interface
- ✅ Can submit votes
- ✅ Cookie persists voter ID

**Result Page:** http://marty.ironhack.com/result
- ✅ Shows real-time vote counts
- ✅ WebSocket updates work
- ✅ Percentages displayed correctly

### Test 4: Kubernetes Status

```bash
# Check Ingress
$ kubectl get ingress -n marty
NAME            CLASS   HOSTS                ADDRESS
marty-ingress   nginx   marty.ironhack.com   a587e5dbd9d3c494...

# Check Pods
$ kubectl get pods -n marty
NAME                                     READY   STATUS    RESTARTS
marty-deployment-postgres-976d48945-...  1/1     Running   0
marty-deployment-redis-646959d8f5-...    1/1     Running   0
marty-deployment-result-cd55745b8-...    1/1     Running   0
marty-deployment-vote-6d8ffbd759-...     1/1     Running   0
marty-deployment-worker-5df478595f-...   1/1     Running   0

# Check Services
$ kubectl get svc -n marty
NAME                 TYPE        CLUSTER-IP       PORT(S)
marty-svc-postgres   ClusterIP   10.100.53.6      5432/TCP
marty-svc-redis      ClusterIP   10.100.125.152   6379/TCP
marty-svc-result     ClusterIP   10.100.86.194    80/TCP
marty-svc-vote       ClusterIP   10.100.105.147   80/TCP
```
✅ **All components healthy**

---

## 📚 Key Learnings

### 1. /etc/hosts Best Practices

**✅ DO:**
- Use IP addresses directly (not hostnames)
- Format: `<IP_ADDRESS>  <HOSTNAME>`
- Example: `13.57.86.174  marty.ironhack.com`

**❌ DON'T:**
- Include `http://` protocol
- Include port numbers (`:80`)
- Include paths (`/vote`)
- Use ELB hostnames instead of IPs

### 2. Why Use IP Instead of ELB Hostname?

**/etc/hosts requirement:**
- Can only map hostname → IP address
- Cannot map hostname → another hostname
- Needs a "final" IP address

**ELB hostnames are dynamic:**
- ELB may resolve to different IPs over time
- ELB may be deleted/recreated
- IPs provide direct, stable mapping

**Trade-off:**
- IP addresses may change if ELB is recreated
- Must update /etc/hosts when ELB IPs change
- For production, use real DNS (Route53) instead

### 3. Ingress Path Rewriting

**Why needed:**
- Frontend apps often expect root path (`/`)
- URLs need prefixes for organization (`/vote`, `/result`)
- Ingress bridges this gap with path rewriting

**Pattern:**
```yaml
# Capture groups in path
path: /vote(/|$)(.*)
      └─┬──┘ └─┬──┘
        $1     $2

# Rewrite using capture groups
rewrite-target: /$2
                └─┬──┘
              Uses $2 (everything after /vote/)
```

**When to use:**
- Legacy apps with fixed routes
- Microservices with different path structures
- Multi-tenant applications

### 4. Modern Ingress Configuration

**Old (pre-1.18):**
```yaml
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
```

**New (1.18+):**
```yaml
spec:
  ingressClassName: nginx
```

**Advantages:**
- Type-safe (validated by API server)
- Prevents typos in annotations
- Better controller selection
- Required for some advanced features

### 5. DNS Cache Invalidation

**Where DNS is cached:**
1. **Browser cache** - Must clear: `chrome://net-internals/#dns`
2. **OS cache** - Must flush: `systemd-resolve --flush-caches`
3. **Application cache** - May need app restart
4. **Router/DNS server** - Outside your control

**Troubleshooting order:**
1. Clear browser DNS cache
2. Flush system DNS cache
3. Try incognito/private mode
4. Restart browser
5. Check /etc/hosts syntax

### 6. Kubernetes Networking Layers

**7 layers from browser to pod:**
1. **Browser** - Initiates HTTP request
2. **/etc/hosts** - Local DNS resolution
3. **AWS ELB** - Distributes load across nodes
4. **NGINX Ingress** - Routes by hostname and path
5. **Kubernetes Service** - Load balances to pods
6. **Kubernetes Network** - Pod-to-pod communication
7. **Application Pod** - Handles request

**Each layer can fail independently - debug from top to bottom!**

### 7. Debugging Methodology

**Progressive testing:**
```bash
# 1. DNS resolution
ping marty.ironhack.com

# 2. TCP connection
curl -I http://13.57.86.174

# 3. HTTP with Host header
curl -H "Host: marty.ironhack.com" http://13.57.86.174/vote

# 4. Full URL
curl http://marty.ironhack.com/vote

# 5. Browser
# Visit in browser
```

**Each step isolates a different layer of the stack.**

---

## 🎓 For Instructors

### Project Demonstrates:

1. **DNS Resolution** - Local /etc/hosts configuration
2. **Kubernetes Ingress** - Path-based routing with NGINX
3. **AWS EKS Integration** - Using ELB with Kubernetes
4. **Microservices Architecture** - Multiple services communicating
5. **Debugging Skills** - Systematic troubleshooting approach
6. **Infrastructure as Code** - Kubernetes manifests

### Skills Applied:

- Linux system administration (/etc/hosts, DNS)
- Kubernetes resource management
- NGINX configuration and path rewriting
- AWS Load Balancer concepts
- HTTP protocol understanding
- Problem isolation and debugging

---

## 📝 Final Configuration

### /etc/hosts
```bash
13.57.86.174  marty.ironhack.com
```

### Ingress (K8s/marty-ingress.yaml)
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: marty-ingress
  namespace: marty
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  ingressClassName: nginx
  rules:
    - host: marty.ironhack.com
      http:
        paths:
          - path: /vote(/|$)(.*)
            pathType: ImplementationSpecific
            backend:
              service:
                name: marty-svc-vote
                port:
                  number: 80
          - path: /result(/|$)(.*)
            pathType: ImplementationSpecific
            backend:
              service:
                name: marty-svc-result
                port:
                  number: 80
```

### Application URLs
- **Vote:** http://marty.ironhack.com/vote
- **Result:** http://marty.ironhack.com/result

---

## 🚀 Success Metrics

✅ **DNS Resolution:** `marty.ironhack.com` resolves to `13.57.86.174`
✅ **HTTP Status:** Both endpoints return `200 OK`
✅ **Application Function:** Can vote and see results
✅ **Real-time Updates:** WebSocket connections working
✅ **No Errors:** No browser DNS or connection errors

---

## 📖 References

- [Kubernetes Ingress Documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [NGINX Rewrite Target](https://kubernetes.github.io/ingress-nginx/examples/rewrite/)
- [AWS ELB Documentation](https://docs.aws.amazon.com/elasticloadbalancing/)

---

**Document created:** 2025-01-18
**Author:** Claude (Anthropic)
**Project:** Ironhack Voting App - EKS Deployment
**Status:** ✅ Resolved and Verified
