# GNU Stow: Symlink Management for Dotfiles

This document explains why we use GNU Stow, how it works, and how to test and verify your dotfiles setup.

## 🤔 Why GNU Stow?

### Problems with Traditional Dotfiles Management

**Manual Symlink Hell:**
```bash
# Traditional approach - error-prone and hard to maintain
ln -sf ~/dotfiles/.vimrc ~/.vimrc
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
# ... hundreds of files later
```

**Script-Based Solutions:**
- Custom shell scripts become complex and brittle
- Hard to undo installations
- Platform-specific logic scattered everywhere
- No standard way to handle conflicts

### GNU Stow Benefits

✅ **Automatic Symlink Management** - Stow handles all symlink creation/removal  
✅ **Conflict Detection** - Warns before overwriting existing files  
✅ **Easy Undo** - Simple command to remove all symlinks  
✅ **Package Organization** - Group related configs together  
✅ **Cross-Platform** - Works on macOS, Linux, and other Unix systems  
✅ **Mature & Stable** - Battle-tested tool used by thousands  

## 🔧 How GNU Stow Works

### Core Concept: Package Directory Structure

Stow treats each subdirectory as a "package" and mirrors its structure in the target directory (usually `$HOME`):

```
dotfiles/                    # Stow directory
├── common/                  # Package: common configs
│   ├── .config/
│   │   ├── nvim/           # Will become ~/.config/nvim/
│   │   └── fish/           # Will become ~/.config/fish/
│   └── .gitconfig          # Will become ~/.gitconfig
├── macos/                   # Package: macOS configs
│   ├── .zshrc              # Will become ~/.zshrc
│   └── .yabairc            # Will become ~/.yabairc
└── linux/                  # Package: Linux configs
    └── .config/
        ├── i3/             # Will become ~/.config/i3/
        └── waybar/         # Will become ~/.config/waybar/
```

### Stow Commands

```bash
# Install (create symlinks)
stow common                  # Stow just common package
stow common macos           # Stow multiple packages
stow .                      # Stow all packages

# Uninstall (remove symlinks)
stow -D common              # Remove common package symlinks
stow -D common macos        # Remove multiple packages

# Restow (remove and reinstall)
stow -R common              # Useful after adding new files

# Simulate (dry run)
stow -n common              # See what would happen without doing it
stow -nv common             # Verbose simulation
```

### Example: How Stowing Works

**Before stowing:**
```
~/dotfiles/common/.config/nvim/init.lua  # Source file
~/.config/nvim/                          # Directory doesn't exist
```

**After `stow common`:**
```
~/dotfiles/common/.config/nvim/init.lua  # Source file (unchanged)
~/.config/nvim -> ../dotfiles/common/.config/nvim/  # Symlink created
```

**Result:**
- `~/.config/nvim/init.lua` now points to your dotfiles
- Any changes to either location affect the same file
- Your dotfiles are version controlled and organized

## 🧪 Testing and Verification

### 1. Pre-Installation Testing

**Simulate Installation (Dry Run):**
```bash
cd ~/.dotfiles

# Test common configs
stow -nv common
# Output shows what symlinks would be created

# Test platform-specific configs
stow -nv macos    # On macOS
stow -nv linux    # On Linux

# Test everything at once
stow -nv common macos  # On macOS
stow -nv common linux  # On Linux
```

**Check for Conflicts:**
```bash
# Stow will warn about existing files
stow -n common
# Example output:
# WARNING! stowing common would cause conflicts:
#   * existing target is not owned by stow: .gitconfig
```

### 2. Safe Installation

**Backup Existing Configs:**
```bash
# Create backup of existing dotfiles
mkdir ~/dotfiles-backup
cp ~/.zshrc ~/dotfiles-backup/ 2>/dev/null || true
cp ~/.gitconfig ~/dotfiles-backup/ 2>/dev/null || true
# ... backup other important configs

# Or use our install script which handles this
./install.sh install
```

**Install Step by Step:**
```bash
# Install common configs first
stow common

# Verify common configs work
nvim --version  # Test if nvim config loads
fish --version  # Test if fish config loads

# Then install OS-specific configs
stow macos  # or linux
```

### 3. Verification Steps

#### A. Check Symlinks Are Created

```bash
# Verify symlinks exist and point to correct locations
ls -la ~/.config/nvim
# Should show: nvim -> ../../dotfiles/common/.config/nvim

ls -la ~/.gitconfig
# Should show: .gitconfig -> dotfiles/common/.gitconfig

# Check all stow-managed symlinks
find ~ -maxdepth 2 -type l -ls | grep dotfiles
```

#### B. Test Configuration Loading

```bash
# Test editors load configs
nvim +':checkhealth' +qa          # Neovim loads without errors
helix --health                    # Helix config works

# Test shell configs
fish -c 'echo $status'            # Fish config loads
zsh -c 'echo $ZSH_VERSION'        # Zsh config loads (macOS)

# Test terminal configs
ghostty --version                 # Ghostty finds its config
kitty --version                   # Kitty finds its config
```

#### C. Test Cross-Platform Compatibility

```bash
# Verify only appropriate configs are stowed
# On macOS - should not have Linux-specific configs
ls ~/.config/i3          # Should not exist on macOS
ls ~/.config/waybar      # Should not exist on macOS

# On Linux - should not have macOS-specific configs  
ls ~/.yabairc            # Should not exist on Linux
ls ~/.skhdrc             # Should not exist on Linux
```

#### D. Test Installation Script

```bash
# Test our automated installation
./install.sh --help              # Shows usage
./install.sh install --simulate  # Dry run (if supported)
./install.sh install             # Full installation
```

### 4. Troubleshooting Common Issues

#### Symlink Conflicts
```bash
# Problem: Existing file conflicts
# WARNING! stowing common would cause conflicts:
#   * existing target is not owned by stow: .gitconfig

# Solutions:
# 1. Backup and remove the file
mv ~/.gitconfig ~/.gitconfig.bak
stow common

# 2. Adopt the existing file (if it's identical)
stow --adopt common
git diff  # Check if changes need to be committed
```

#### Broken Symlinks
```bash
# Find broken symlinks
find ~ -maxdepth 3 -type l ! -exec test -e {} \; -print

# Fix by restowing
stow -R common macos
```

#### Wrong Target Directory
```bash
# Problem: Stowed to wrong location
# Solution: Use -t flag to specify target
stow -t ~ common              # Explicitly stow to home directory
stow -t ~/.config app-config  # Stow app-config to ~/.config
```

### 5. Maintenance and Updates

#### Update Configs
```bash
# After editing configs in dotfiles repo
git add .
git commit -m "Update nvim config"

# No need to restow - symlinks automatically reflect changes!
# Test the changes immediately
nvim ~/.config/nvim/init.lua
```

#### Add New Configs
```bash
# After adding new files to packages
stow -R common  # Restow to create new symlinks

# Or unstow and restow
stow -D common
stow common
```

#### Remove Configs
```bash
# Remove specific package
stow -D macos

# Remove all dotfiles
stow -D common macos linux

# Verify removal
find ~ -maxdepth 3 -type l -ls | grep dotfiles
# Should return empty
```

## 📝 Best Practices

### 1. Package Organization
- **common/**: Cross-platform configs (nvim, git, tmux)
- **macos/**: macOS-specific configs (yabai, karabiner)  
- **linux/**: Linux-specific configs (i3, waybar)
- **optional/**: Experimental or optional configs

### 2. File Naming
- Use actual dotfile names: `.gitconfig`, `.zshrc`
- Mirror home directory structure exactly
- Keep package directories shallow (avoid deep nesting)

### 3. Testing Workflow
```bash
# 1. Always simulate first
stow -nv new-package

# 2. Test in isolated environment
docker run -it --rm -v $(pwd):/dotfiles ubuntu bash
cd /dotfiles && ./install.sh

# 3. Backup before major changes
tar czf ~/dotfiles-backup-$(date +%Y%m%d).tar.gz ~/.config ~/.zshrc ~/.gitconfig

# 4. Test incrementally
stow common     # Test common first
stow macos      # Then OS-specific
```

### 4. Version Control Integration
```bash
# Always commit before major stow operations
git add .
git commit -m "Add new nvim config before stowing"

# Use .stow-local-ignore for generated files
echo "*.log" >> .stow-local-ignore
echo "cache/" >> .stow-local-ignore
```

## 🎯 Quick Verification Checklist

After installation, verify these key points:

- [ ] **Symlinks created**: `ls -la ~/.config/nvim` shows symlink
- [ ] **No broken links**: `find ~ -maxdepth 3 -type l ! -exec test -e {} \; -print` is empty
- [ ] **Configs load**: `nvim +checkhealth +qa` succeeds
- [ ] **Shell works**: `fish -c 'echo OK'` or `zsh -c 'echo OK'` succeeds  
- [ ] **Git config**: `git config --global user.name` shows your name
- [ ] **Platform-appropriate**: No Linux configs on macOS, no macOS configs on Linux
- [ ] **Install script works**: `./install.sh uninstall && ./install.sh install` succeeds

## 🔗 Useful Resources

- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html)
- [Stow GitHub Repository](https://github.com/aspiers/stow)
- [Managing Dotfiles with Stow](https://spin.atomicobject.com/2014/12/26/manage-dotfiles-gnu-stow/)
- [Dotfiles Community](https://dotfiles.github.io/)

---

*This documentation is part of a comprehensive dotfiles management system. For more information, see the main [README.md](../README.md).*