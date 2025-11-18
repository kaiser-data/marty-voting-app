# Quick Fix Summary - DNS & Ingress Issue

## 🚨 The Problem
Browser showed `DNS_PROBE_POSSIBLE` when accessing `marty.ironhack.com/vote`

## 🔍 Root Causes

1. **Broken /etc/hosts entry** - Pointed to non-existent ELB hostname
2. **Hostname mismatch** - Ingress expected `marty-v1.ironhack.com`, browser used `marty.ironhack.com`
3. **Deprecated Ingress config** - Used old annotation instead of `ingressClassName`
4. **Path routing issue** - Ingress sent `/vote` but Flask expected `/`

## ✅ Fixes Applied

### 1. Fixed /etc/hosts
```bash
# Removed old entry
sudo sed -i.bak '/ac4ad35e3a4964c368b127366d7be51a/d' /etc/hosts

# Added correct IP mapping
echo "13.57.86.174  marty.ironhack.com" | sudo tee -a /etc/hosts

# Flushed DNS cache
sudo systemd-resolve --flush-caches
```

### 2. Updated Ingress Hostname
Changed from `marty-v1.ironhack.com` → `marty.ironhack.com`

### 3. Modernized Ingress Configuration
```yaml
# Old
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx

# New
spec:
  ingressClassName: nginx
```

### 4. Added Path Rewriting
```yaml
metadata:
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  rules:
    - host: marty.ironhack.com
      http:
        paths:
          - path: /vote(/|$)(.*)      # Rewrites /vote → /
            pathType: ImplementationSpecific
          - path: /result(/|$)(.*)    # Rewrites /result → /
            pathType: ImplementationSpecific
```

**How path rewriting works:**
- Request: `http://marty.ironhack.com/vote`
- Regex captures: `/vote(/|$)(.*)`  → `$1=/`, `$2=` (empty)
- Rewrite target: `/$2` → `/` (root)
- Backend receives: `GET /` (what Flask expects)

## 🎯 Result
✅ **Vote page:** http://marty.ironhack.com/vote
✅ **Result page:** http://marty.ironhack.com/result

## 📊 Traffic Flow
```
Browser
  ↓ DNS lookup via /etc/hosts
  ↓ marty.ironhack.com → 13.57.86.174
AWS ELB (13.57.86.174)
  ↓
NGINX Ingress Controller
  ↓ Matches host: marty.ironhack.com
  ↓ Matches path: /vote
  ↓ Rewrites: /vote → /
Service (marty-svc-vote)
  ↓
Flask Pod
  ↓ Receives: GET /
  ↓ Returns: HTML ✅
```

## 🔑 Key Takeaways

1. **/etc/hosts format:** `<IP>  <hostname>` (no http://, no port, no path)
2. **Use IPs not hostnames** in /etc/hosts (ELB hostnames don't work)
3. **Flush DNS cache** after changes (`systemd-resolve --flush-caches`)
4. **Path rewriting** bridges URL structure and app routes
5. **Modern Ingress** uses `ingressClassName`, not annotations

## 🛠️ Files Modified

- `/etc/hosts` - Added IP mapping
- `K8s/marty-ingress.yaml` - Updated hostname, class, and paths
- Applied changes: `kubectl apply -f K8s/marty-ingress.yaml`

## 📖 Full Documentation
See `DNS-AND-INGRESS-FIX-GUIDE.md` for complete technical details.
