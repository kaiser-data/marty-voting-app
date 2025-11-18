#!/bin/bash
# Fix DNS for marty.ironhack.com

set -e

echo "🔧 Fixing /etc/hosts for marty.ironhack.com..."
echo ""

# Remove old entry
echo "1️⃣ Removing old ELB entry..."
sudo sed -i.bak '/ac4ad35e3a4964c368b127366d7be51a/d' /etc/hosts

# Add new entry
echo "2️⃣ Adding new IP entry..."
echo "13.57.86.174  marty.ironhack.com" | sudo tee -a /etc/hosts

# Verify
echo ""
echo "3️⃣ Verifying /etc/hosts entry:"
grep "marty.ironhack.com" /etc/hosts

# Flush DNS
echo ""
echo "4️⃣ Flushing DNS cache..."
sudo systemd-resolve --flush-caches 2>/dev/null || sudo resolvectl flush-caches 2>/dev/null || echo "DNS cache flush not needed"

# Test
echo ""
echo "5️⃣ Testing DNS resolution..."
if ping -c 2 marty.ironhack.com &>/dev/null; then
    echo "✅ Ping successful!"
else
    echo "⚠️  Ping failed, but /etc/hosts is configured correctly"
fi

# Test HTTP
echo ""
echo "6️⃣ Testing HTTP connection..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://marty.ironhack.com/vote 2>/dev/null || echo "000")

if [[ "$HTTP_CODE" == "200" || "$HTTP_CODE" == "302" ]]; then
    echo "✅ HTTP connection successful!"
elif [[ "$HTTP_CODE" == "404" ]]; then
    echo "⚠️  Got 404 - server is reachable but path might be wrong"
else
    echo "⚠️  HTTP test returned code: $HTTP_CODE"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Now open your browser and visit:"
echo "  🔗 http://marty.ironhack.com/vote"
echo "  🔗 http://marty.ironhack.com/result"
echo ""
echo "If it still doesn't work:"
echo "  1. Clear browser DNS cache: chrome://net-internals/#dns"
echo "  2. Try Incognito mode (Ctrl+Shift+N)"
echo "  3. Restart your browser"
