#!/bin/bash
# Update /etc/hosts for subdomain-based routing

set -e

ELB_IP="13.57.86.174"

echo "🔧 Updating /etc/hosts for subdomain-based routing..."
echo ""

# Remove old entries
echo "1️⃣ Removing old entries..."
sudo sed -i.bak '/marty.ironhack.com/d' /etc/hosts
sudo sed -i '/vote.marty.ironhack.com/d' /etc/hosts
sudo sed -i '/result.marty.ironhack.com/d' /etc/hosts

# Add new subdomain entries
echo "2️⃣ Adding new subdomain entries..."
echo "$ELB_IP  vote.marty.ironhack.com" | sudo tee -a /etc/hosts
echo "$ELB_IP  result.marty.ironhack.com" | sudo tee -a /etc/hosts

# Verify
echo ""
echo "3️⃣ Verifying /etc/hosts entries:"
grep "marty.ironhack.com" /etc/hosts

# Flush DNS
echo ""
echo "4️⃣ Flushing DNS cache..."
sudo systemd-resolve --flush-caches 2>/dev/null || sudo resolvectl flush-caches 2>/dev/null || echo "DNS cache flush not needed"

echo ""
echo "✅ /etc/hosts updated successfully!"
echo ""
echo "🎉 Your app is now available at:"
echo "   🗳️  Vote:   http://vote.marty.ironhack.com"
echo "   📊 Result: http://result.marty.ironhack.com"
echo ""
echo "Note: Clear browser cache and reload!"
