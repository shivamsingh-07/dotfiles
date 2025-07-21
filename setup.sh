#!/usr/bin/env bash

set -euo pipefail

print_separator() {
    echo
    echo "##########################################################"
    echo
}

install_zsh() {
    echo "🌀 Installing Zsh..."
    if command -v zsh &>/dev/null; then
        echo "✅ zsh already installed: $(zsh --version)"
    else
        sudo apt install -y zsh
        
        echo "📦 Installing zsh plugins if available..."
        sudo apt install -y zsh-autosuggestions zsh-syntax-highlighting || echo "⚠️ Plugins may not be available in apt"
        
        echo "📂 Copying .zshrc..."
        cp .zshrc ~/.zshrc
        
        echo "💡 Changing default shell to zsh if needed (requires sudo)..."
        zsh_path=$(command -v zsh)
        if [ "$SHELL" != "$zsh_path" ]; then
            sudo chsh -s "$zsh_path" "$(whoami)" || echo "⚠️ Failed to change shell, please do manually."
        fi
    fi
    print_separator
}

install_starship() {
    echo "🌀 Installing Starship..."
    if command -v starship &>/dev/null; then
        echo "✅ Starship already installed: $(starship --version | head -n1)"
    else
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        echo 'eval "$(starship init zsh)"' >> ~/.zshrc
        echo "📂 Copying starship config..."
        mkdir -p ~/.config
        cp starship.toml ~/.config/starship.toml
    fi
    print_separator
}

install_neovim() {
    echo "🌀 Installing Neovim..."
    
    arch=$(uname -m)
    case "$arch" in
        x86_64) arch="x86_64" ;;
        aarch64 | arm64) arch="arm64" ;;
        *)
            echo "❌ Unsupported arch: $arch"
            return 1
        ;;
    esac
    
    latest_version=$(curl -sSL https://api.github.com/repos/neovim/neovim/releases/latest | grep -Po '"tag_name": "\K[^"]+')
    if [ -z "$latest_version" ]; then
        echo "❌ Could not fetch latest neovim version"
        return 1
    fi
    
    installed_version=""
    if command -v nvim &>/dev/null; then
        installed_version=$(nvim --version | head -n1 | awk '{print $2}')
    fi
    
    if [ "$installed_version" = "$latest_version" ]; then
        echo "✅ Neovim already installed: $(nvim --version | head -n1)"
    else
        echo "📦 Installing Neovim $latest_version"
        url="https://github.com/neovim/neovim/releases/download/${latest_version}/nvim-linux-${arch}.appimage"
        tmpfile=$(mktemp)
        curl -sSL "$url" -o "$tmpfile"
        chmod +x "$tmpfile"
        sudo mv "$tmpfile" /usr/local/bin/nvim
        
        # Backup old config if exists
        if [ -d ~/.config/nvim ]; then
            echo "⚠️ Backing up existing Neovim config"
            mv ~/.config/nvim ~/.config/nvim.backup.$(date +%s)
        fi
        
        echo "📂 Cloning NVChad config repo..."
        git clone --depth=1 https://github.com/shivamsingh-07/nvchad ~/.config/nvim
    fi
    print_separator
}

install_tmux() {
    echo "🌀 Installing Tmux..."
    
    latest_ver=$(curl -sSL https://api.github.com/repos/nelsonenzo/tmux-appimage/releases/latest | grep -Po '"tag_name": "\K[^"]+')
    if [ -z "$latest_ver" ]; then
        echo "❌ Failed to fetch latest tmux version"
        return 1
    fi
    
    installed_ver=""
    if command -v tmux &>/dev/null; then
        installed_ver=$(tmux -V | awk '{print $2}')
    fi
    
    if [ "$installed_ver" = "$latest_ver" ]; then
        echo "✅ Tmux already installed: $(tmux -V)"
    else
        echo "📦 Installing tmux $latest_ver..."
        url=$(curl -sSL https://api.github.com/repos/nelsonenzo/tmux-appimage/releases/latest | grep browser_download_url | grep -i AppImage | cut -d '"' -f 4)
        tmpfile=$(mktemp)
        curl -L "$url" -o "$tmpfile"
        chmod +x "$tmpfile"
        sudo mv "$tmpfile" /usr/local/bin/tmux
        
        echo "📂 Copying tmux config..."
        mkdir -p ~/.config/tmux
        cp tmux.conf ~/.config/tmux/tmux.conf
        
        echo "📦 Installing TPM (Tmux Plugin Manager)..."
        if [ ! -d ~/.config/tmux/plugins/tpm ]; then
            git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
        else
            echo "✅ TPM already installed"
        fi
    fi
    print_separator
}

install_git() {
    echo "🌀 Installing Git and GitHub CLI..."
    
    if command -v git &>/dev/null; then
        echo "✅ Git already installed: $(git --version)"
    else
        sudo apt install -y git
        
        echo "📂 Copying .gitconfig..."
        cp ./git/.gitconfig ~/.gitconfig
        
    fi
    
    if command -v gh &>/dev/null; then
        echo "✅ GitHub CLI already installed: $(gh --version | head -n1)"
    else
        if ! dpkg -s gpg &>/dev/null; then
            sudo apt install -y gpg
        fi
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/githubcli-archive-keyring.gpg >/dev/null
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
        sudo apt update && sudo apt install -y gh
        
        echo "🔐 Decrypting GitHub CLI credentials..."
        mkdir -p ~/.config/gh
        gpg --decrypt ./git/hosts.yml.gpg > ~/.config/gh/hosts.yml
    fi
    
    echo "🔍 Verifying GitHub CLI auth status..."
    if gh auth status &>/dev/null; then
        echo "✅ GitHub CLI is authenticated!"
    else
        echo "⚠️ GitHub CLI authentication not configured or failed"
    fi
    print_separator
}

install_vscode() {
    echo "🌀 Installing Visual Studio Code and configuring..."
    
    if command -v code &>/dev/null; then
        echo "✅ VS Code already installed: $(code --version | head -n1)"
    else
        for pkg in wget gpg apt-transport-https; do
            if ! dpkg -s "$pkg" &>/dev/null; then
                sudo apt install -y "$pkg"
            fi
        done
        
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
        echo "deb [arch=$(dpkg --print-architecture)] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
        sudo apt update && sudo apt install -y code
        
        echo "⚙️ Copying VS Code settings..."
        mkdir -p ~/.config/Code/User
        cp ./vscode/settings.json ~/.config/Code/User/settings.json
        
        if [ -f ./vscode/extensions.txt ]; then
            echo "📦 Installing VS Code extensions..."
            xargs -n 1 code --install-extension < ./vscode/extensions.txt
        else
            echo "⚠️ No VS Code extensions.txt found, skipping extension installs"
        fi
    fi
    print_separator
}

show_usage() {
    echo "Usage: $0 [zsh|starship|neovim|tmux|git|vscode]"
    echo "Install specified tools. Default: all"
}

main() {
    if [ $# -eq 0 ]; then
        tools=("zsh" "starship" "neovim" "tmux" "git" "vscode")
    else
        tools=("$@")
    fi
    
    sudo apt update
    print_separator
    
    for t in "${tools[@]}"; do
        case "$t" in
            zsh) install_zsh ;;
            starship) install_starship ;;
            neovim) install_neovim ;;
            tmux) install_tmux ;;
            git) install_git ;;
            vscode) install_vscode ;;
            *)
                show_usage
                exit 1
            ;;
        esac
    done
    echo "✅ Setup complete! Restart your terminal."
}

main "$@"
