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
echo ""
echo "⚠️  Next steps:"
echo "1. Restore your .bashrc, .gitconfig, and .ssh/ from backup"
echo "2. Run: source ~/.bashrc"
echo "3. Configure GitHub: gh auth login"
echo "4. Add your API keys to .bashrc or ~/.secrets"
echo ""
echo "Run the verification commands from the migration guide to ensure everything works!"
