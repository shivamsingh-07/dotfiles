# 🗂️ My Dotfiles

Welcome to my personal **dotfiles repository** – a collection of configuration files and automation scripts to quickly set up a consistent developer environment on any machine.

---

## 🚀 Features

This setup includes:

-   🐚 **Zsh** with syntax highlighting, autosuggestions, and a custom `.zshrc`
-   🚀 **Starship** — minimal, blazing-fast shell prompt
-   ✨ **Neovim** with [NvChad](https://nvchad.com/) and personal config
-   🔧 **Tmux** with plugins and custom keybindings
-   🧬 **Git** with pre-configured `.gitconfig` and GitHub CLI auth
-   💻 **VS Code** with extensions and settings

---

## 📁 Repository Structure

```text
.
├── setup.sh                  # Master install script
├── .zshrc                    # Zsh configuration
├── starship.toml             # Starship prompt config
├── tmux.conf                 # Tmux configuration
├── git/
│   ├── .gitconfig            # Git configuration
│   └── hosts.yml.gpg         # Encrypted GitHub CLI credentials
├── vscode/
│   ├── settings.json         # VS Code user settings
│   └── extensions.txt        # List of extensions to install
```

---

## ⚙️ Installation

### 🧪 Full Setup (Recommended)

Clone the repository and run the main setup script:

```bash
git clone https://github.com/shivamsingh-07/dotfiles.git
cd dotfiles
chmod +x setup.sh
./setup.sh
```

---

## 🧩 Install Specific Tools

You can install only selected tools by specifying them as arguments. By default all tools will get installed.

```bash
./setup.sh zsh git starship
```

### Supported options:

-   zsh
-   starship
-   neovim
-   tmux
-   git
-   vscode

---

## 🔐 GitHub CLI Auth (Optional)

This setup supports automatically configuring `gh` (GitHub CLI) authentication using a GPG-encrypted credentials file.

### ✅ Steps

1. Make sure the file `git/hosts.yml.gpg` exists.
2. To create or update the encrypted credentials file, use symmetric encryption with a password:

    ```bash
    gpg --symmetric --cipher-algo AES256 git/hosts.yml
    ```

---

## 📦 Requirements

-   Ubuntu or Debian-based system

-   Internet access

-   Basic system packages:

    -   `curl`, `git`, `sudo`, `gpg`

### To install required dependencies:

```bash
sudo apt update && sudo apt install -y git curl gpg sudo
```

---

## 📎 Credits

-   [Starship Prompt](https://starship.rs/)
-   [NvChad](https://nvchad.com/)
-   [Tmux AppImage](https://github.com/nelsonenzo/tmux-appimage)
-   [GitHub CLI](https://cli.github.com/)
-   [Visual Studio Code](https://code.visualstudio.com/)
