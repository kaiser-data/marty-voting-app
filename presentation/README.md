# Presentation Guide

## Multistack App on Kubernetes - Marp Presentation

This presentation covers the Ironhack Kubernetes voting app project, including architecture, challenges, and solutions.

---

## 📊 Presentation Contents

**Total Slides:** 12
**Duration:** ~10-15 minutes

### Slide Breakdown
1. **Title Slide** - Project introduction with BTFF Kubernetes image
2. **Project Overview** - Technologies and challenge description
3. **Architecture & Infrastructure** - System diagram and components
4. **CI/CD Workflow** - GitHub Actions pipeline
5. **Problem 1** - DNS Resolution issues
6. **Problem 2 (Title)** - Taylor Swift vs Lady Gaga intro
7. **Problem 2 (Details)** - Wildcard Ingress battle
8. **Problem 3** - Hardcoded connections across all apps
9. **Solutions Applied** - Security, networking, configuration fixes
10. **Summary & Learnings** - Key takeaways and skills demonstrated
11. **Questions** - With Kubernetes meme
12. **Thank You** - Contact info and links

---

## 🚀 How to Use

### Option 1: View in VS Code (Recommended)
1. Install **Marp for VS Code** extension
   ```bash
   code --install-extension marp-team.marp-vscode
   ```
2. Open `voting-app-presentation.md` in VS Code
3. Click the **Preview** button (or press `Ctrl+K V`)
4. Use arrow keys to navigate slides

### Option 2: Export to HTML
```bash
# Install Marp CLI
npm install -g @marp-team/marp-cli

# Generate HTML
marp voting-app-presentation.md -o voting-app-presentation.html

# Open in browser
open voting-app-presentation.html  # macOS
xdg-open voting-app-presentation.html  # Linux
```

### Option 3: Export to PDF
```bash
# Generate PDF (requires Chrome/Chromium)
marp voting-app-presentation.md -o voting-app-presentation.pdf --allow-local-files

# Or generate both
marp voting-app-presentation.md -o voting-app-presentation.html
marp voting-app-presentation.md -o voting-app-presentation.pdf --allow-local-files
```

### Option 4: Present Online
```bash
# Start Marp server
marp -s voting-app-presentation.md

# Open browser to: http://localhost:8080
# Press 'f' for fullscreen
# Use arrow keys to navigate
```

---

## 🎨 Images Used

1. **BTFF_Kubernetes.png** - Intro slide background
2. **Gaga_or_Taylor.jpg** - Problem 2 (Wildcard Ingress)
3. **kubernetes-meme_final_page.jpg** - Final question slide

---

## 🎤 Presentation Tips

### Key Points to Emphasize
1. **Multi-language complexity** - Python, .NET, Node.js in one system
2. **Real production issues** - DNS, Ingress conflicts, hardcoded configs
3. **Systematic debugging** - Evidence-based troubleshooting approach
4. **DevOps best practices** - CI/CD, secrets management, IaC

### Timing Suggestions
- **Intro + Overview:** 2 minutes
- **Architecture:** 2 minutes
- **CI/CD Workflow:** 1 minute
- **Problem 1 (DNS):** 2 minutes
- **Problem 2 (Wildcard Ingress):** 2 minutes
- **Problem 3 (Hardcoded):** 2 minutes
- **Solutions:** 2 minutes
- **Summary:** 2 minutes
- **Q&A:** 5 minutes

### Speaking Notes

**Slide 2 (Overview):**
> "This project demonstrates deploying a complex microservices application where each service uses a different programming language - showcasing the heterogeneous nature of modern cloud-native systems."

**Slide 7 (Wildcard Ingress):**
> "This was one of the most interesting bugs - my application was showing someone else's voting options! Jakob's Ingress had a wildcard rule that was catching all unmatched traffic, including mine."

**Slide 8 (Hardcoded Connections):**
> "A classic migration challenge: code designed for Docker Compose doesn't translate directly to Kubernetes. Service discovery works completely differently."

**Slide 10 (Summary):**
> "The key learning here is that Kubernetes requires a fundamental shift in how we think about configuration and service communication compared to traditional deployments."

---

## 📝 Customization

### Change Theme
Edit line 3 in the markdown:
```yaml
theme: default  # Options: default, gaia, uncover
```

### Modify Colors
```yaml
backgroundColor: #fff
color: #333
```

### Add More Slides
Use `---` to separate slides:
```markdown
---

## New Slide Title
Content here...
```

---

## 🔗 Resources

- **Marp Official:** https://marp.app/
- **Marp CLI Docs:** https://github.com/marp-team/marp-cli
- **VS Code Extension:** https://marketplace.visualstudio.com/items?itemName=marp-team.marp-vscode
- **Project Repository:** https://github.com/kaiser-data/marty-voting-app

---

## 🎯 Quick Commands

```bash
# Install Marp CLI globally
npm install -g @marp-team/marp-cli

# Generate all formats
marp voting-app-presentation.md -o voting-app-presentation.html
marp voting-app-presentation.md -o voting-app-presentation.pdf --allow-local-files
marp voting-app-presentation.md -o voting-app-presentation.pptx

# Watch mode (auto-reload)
marp -w voting-app-presentation.md

# Server mode with watch
marp -s -w voting-app-presentation.md
```

---

**Created:** 2025-11-18
**Author:** Marty Kaiser
**Project:** Ironhack Voting App on Kubernetes
