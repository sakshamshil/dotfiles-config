# WSL Migration Guide - Windows Laptop Setup

Complete guide to replicate your current WSL2 Ubuntu 22.04 environment on a new Windows laptop.

## Pre-Migration: Backup Current Setup

### 1. Backup Configuration Files
```bash
# Create backup directory
mkdir -p ~/migration-backup

# Copy all important dotfiles
cp ~/.bashrc ~/migration-backup/
cp ~/.zshrc ~/migration-backup/
cp ~/.gitconfig ~/migration-backup/
cp -r ~/.ssh ~/migration-backup/ssh-backup
cp -r ~/.nvm ~/migration-backup/nvm-backup (optional, can reinstall)
cp -r ~/.claude ~/migration-backup/claude-backup (if exists)

# If you have custom configs
cp -r ~/.config ~/migration-backup/config-backup 2>/dev/null || true

# Create a package list
dpkg --get-selections > ~/migration-backup/package-list.txt

# List manually installed packages
apt-mark showmanual > ~/migration-backup/manual-packages.txt
```

### 2. Export Current Setup Info
```bash
# Save current setup details
cat > ~/migration-backup/setup-info.txt << 'EOF'
WSL Version: WSL2
Distribution: Ubuntu 22.04.5 LTS
Shell: Bash
Node Version: $(node --version 2>/dev/null || echo "via NVM")
Claude CLI: $(claude --version 2>/dev/null)
EOF
```

### 3. Backup Critical Data
- **SSH Keys**: `~/.ssh/` (especially `id_work`, `id_personal`, `csr.pem`)
- **API Keys/Credentials**: Note from .bashrc line 144 (GEMINI_API_KEY)
- **Projects/Code**: Ensure all git repos are committed and pushed
- **Claude CLI sessions**: Any important conversation history

### 4. Transfer Backup to New Machine
**Option A**: Cloud storage (OneDrive, Dropbox, Google Drive)
```bash
# Archive the backup
cd ~
tar -czf migration-backup.tar.gz migration-backup/
# Upload to cloud storage
```

**Option B**: USB drive
```bash
# Copy to mounted USB drive
cp -r ~/migration-backup /mnt/d/migration-backup/
```

**Option C**: Git repository (for dotfiles only, NOT SSH keys)
```bash
cd ~/migration-backup
git init
git add .bashrc .gitconfig  # Only non-sensitive files
git commit -m "Backup dotfiles"
git remote add origin <your-private-repo>
git push -u origin main
```

---

## New Laptop Setup

### Phase 1: Windows Setup

#### 1.1 Enable WSL2
Open PowerShell as Administrator:
```powershell
# Enable WSL
wsl --install

# Restart computer when prompted

# After restart, check WSL version
wsl --version

# Update WSL if needed
wsl --update
```

#### 1.2 Install Ubuntu 22.04
```powershell
# Install Ubuntu 22.04 from Microsoft Store or:
wsl --install -d Ubuntu-22.04

# Set as default
wsl --set-default Ubuntu-22.04

# Set WSL2 as default version
wsl --set-default-version 2
```

#### 1.3 Install Windows Terminal (Recommended)
- Install from Microsoft Store: **Windows Terminal**
- Set as default terminal application

#### 1.4 Configure Windows Terminal (Optional but Recommended)
**Settings → Ubuntu Profile:**
- Starting directory: `\\wsl$\Ubuntu-22.04\home\<your-username>`
- Font: Cascadia Code, FiraCode, or JetBrains Mono (for better terminal experience)
- Theme: Your preference

---

### Phase 2: WSL Ubuntu Setup

#### 2.1 Initial Ubuntu Configuration
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Set username (should match old one: saksham)
# This is done during initial Ubuntu setup
```

#### 2.2 Restore Backup Files
Transfer your `migration-backup.tar.gz` to the new machine, then:
```bash
# Extract backup
tar -xzf migration-backup.tar.gz

# Restore SSH keys (CRITICAL - set correct permissions)
cp -r migration-backup/ssh-backup ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
chmod 600 ~/.ssh/config

# Restore git config
cp migration-backup/.gitconfig ~/.gitconfig

# Don't restore .bashrc yet - we'll build it fresh with packages first
```

#### 2.3 Install Essential Packages
```bash
# Development essentials
sudo apt install -y build-essential curl wget git nano vim

# Modern CLI tools (from your current setup)
sudo apt install -y bat lsd fzf trash-cli

# Git tooling
sudo apt install -y gh  # GitHub CLI

# Additional utilities
sudo apt install -y sshpass wslu  # wslu provides wslview
```

#### 2.4 Install NVM and Node.js
```bash
# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Reload shell
source ~/.bashrc

# Install Node.js (you had v22.17.0)
nvm install 22.17.0
nvm use 22.17.0
nvm alias default 22.17.0
```

#### 2.5 Install Additional CLI Tools

**Zoxide** (smart cd):
```bash
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
```

**Lazygit**:
```bash
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit lazygit.tar.gz
```

**Starship Prompt**:
```bash
curl -sS https://starship.rs/install.sh | sh
```

#### 2.6 Install Claude CLI
```bash
npm install -g @anthropic-ai/claude-code-cli
```

#### 2.7 Restore and Configure .bashrc
```bash
# Backup default .bashrc
cp ~/.bashrc ~/.bashrc.backup

# Restore your customized .bashrc
cp migration-backup/.bashrc ~/.bashrc

# IMPORTANT: Update any machine-specific paths or IPs if needed
# Review and update SSH aliases (csr, csrapp, csrdb) with correct IPs

# Reload configuration
source ~/.bashrc
```

#### 2.8 Configure Git and GitHub
```bash
# Verify git config
git config --global --list

# Setup GitHub CLI
gh auth login
# Choose: GitHub.com, SSH, authenticate via browser

# Test SSH connections
ssh -T git@github-work
ssh -T git@github-personal
```

---

### Phase 3: Environment Variables and Secrets

#### 3.1 Set API Keys
**IMPORTANT**: Don't commit API keys to git

```bash
# Edit .bashrc to add your API keys
nano ~/.bashrc

# Add (around line 144):
export GEMINI_API_KEY="your-api-key-here"

# Or use a separate secrets file
echo 'export GEMINI_API_KEY="your-key"' > ~/.secrets
echo 'source ~/.secrets' >> ~/.bashrc
chmod 600 ~/.secrets
```

Add `~/.secrets` to `.gitignore` if you're version controlling dotfiles.

---

### Phase 4: Optional Enhancements

#### 4.1 Configure Windows Terminal Font
Install a Nerd Font for better starship/terminal icons:
1. Download: [Nerd Fonts](https://www.nerdfonts.com/)
2. Install font in Windows
3. Set in Windows Terminal settings

#### 4.2 Setup VS Code for WSL
```bash
# Install VS Code in Windows first, then:
code .  # This installs WSL server automatically
```

#### 4.3 Configure WSL Performance
Create/edit `/etc/wsl.conf`:
```bash
sudo nano /etc/wsl.conf

# Add:
[boot]
systemd=true

[network]
generateResolvConf = true

[interop]
appendWindowsPath = true
```

Restart WSL: `wsl --shutdown` in PowerShell

#### 4.4 Configure .wslconfig (Windows Side)
Create `C:\Users\<YourUsername>\.wslconfig`:
```ini
[wsl2]
memory=8GB  # Adjust based on your RAM
processors=4  # Adjust based on your CPU
swap=2GB
localhostForwarding=true
```

---

### Phase 5: Verification Checklist

Run these commands to verify everything works:

```bash
# Shell and prompt
echo $SHELL  # Should be /bin/bash
which starship  # Should find it

# Modern CLI tools
lsd --version
batcat --version
fzf --version
zoxide --version
lazygit --version

# Development tools
git --version
node --version
npm --version
gh --version

# Claude CLI
claude --version

# SSH connections
ssh -T git@github-work
ssh -T git@github-personal

# Aliases
type clauded  # Should show alias
type lg  # Should show alias
type cd  # Should show zoxide alias

# Test clipboard integration
echo "test" | copy  # Should copy to Windows clipboard
paste  # Should paste from Windows clipboard
```

---

## Quick Reference: Your Custom Setup

### Custom Aliases
```bash
clauded='claude --dangerously-skip-permissions'
claudedr='claude --dangerously-skip-permissions --resume'
claudedc='claude --dangerously-skip-permissions --continue'
cat='batcat'
ls='lsd'
cd='z'  # zoxide
lg='lazygit'
yupdate='sudo apt update && sudo apt upgrade -y'
open='wslview'
copy='clip.exe'
paste="powershell.exe -command 'Get-Clipboard' | tr -d '\r'"
```

### SSH Hosts
- `csr` → 192.168.10.131
- `c3m` → 192.168.10.246
- `csrapp` → 10.40.0.2
- `csrdb` → 10.40.0.4
- `github-work` → Work GitHub via id_work
- `github-personal` → Personal GitHub via id_personal

---

## Automation Script (Optional)

Save this as `setup-wsl.sh` for faster setup:

```bash
#!/bin/bash

echo "🚀 Starting WSL Setup..."

# Update system
echo "📦 Updating system..."
sudo apt update && sudo apt upgrade -y

# Install essentials
echo "🔧 Installing essential packages..."
sudo apt install -y build-essential curl wget git nano vim \
    bat lsd fzf trash-cli gh sshpass wslu

# Install NVM
echo "📦 Installing NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node
echo "📦 Installing Node.js..."
nvm install 22
nvm use 22

# Install Zoxide
echo "🚀 Installing Zoxide..."
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# Install Lazygit
echo "📦 Installing Lazygit..."
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit lazygit.tar.gz

# Install Starship
echo "✨ Installing Starship..."
curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install Claude CLI
echo "🤖 Installing Claude CLI..."
npm install -g @anthropic-ai/claude-code-cli

echo "✅ Installation complete!"
echo "⚠️  Next steps:"
echo "1. Restore your .bashrc, .gitconfig, and .ssh/ from backup"
echo "2. Run: source ~/.bashrc"
echo "3. Configure GitHub: gh auth login"
echo "4. Add your API keys to .bashrc or ~/.secrets"
```

Make it executable:
```bash
chmod +x setup-wsl.sh
./setup-wsl.sh
```

---

## Troubleshooting

### WSL2 Network Issues
```bash
# Reset DNS
sudo rm /etc/resolv.conf
sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
sudo bash -c 'echo "nameserver 8.8.4.4" >> /etc/resolv.conf'
```

### SSH Key Permissions
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
chmod 600 ~/.ssh/config
```

### NVM Not Found
```bash
source ~/.bashrc
# Or manually:
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

### GitHub SSH Authentication
```bash
# Test connection
ssh -T git@github.com

# If fails, check ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_work
ssh-add ~/.ssh/id_personal
```

---

## Timeline Estimate

- **Windows Setup**: 30 mins (WSL install, Windows Terminal)
- **Ubuntu Setup**: 30 mins (packages, tools)
- **Restoration**: 15 mins (configs, SSH, verification)
- **Total**: ~1.5 hours for complete setup

---

## Notes

- Keep your `migration-backup.tar.gz` safe until fully verified
- Update server IPs/hostnames in SSH config if they change
- Consider using a dotfiles manager like [chezmoi](https://www.chezmoi.io/) for future migrations
- Sync your Claude CLI sessions via the cloud if needed

---

**Generated**: 2026-01-30
**Source System**: Ubuntu 22.04.5 LTS on WSL2
**Target System**: New Windows laptop with WSL2
