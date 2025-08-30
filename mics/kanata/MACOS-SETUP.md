# Colemak Mod-DH with Kanata on macOS - Complete Setup Guide

## 🚨 Issue Analysis

The error you encountered:
```
IOHIDDeviceOpen error: (iokit/common) privilege violation
```

This happens because **Kanata needs special permissions on macOS** to access the keyboard hardware through IOKit.

## 📋 Prerequisites

1. **Kanata installed**: `brew install kanata` or download from GitHub releases
2. **Admin privileges**: You need sudo access
3. **macOS 10.15+**: Catalina or newer (for proper IOKit support)

## 🔧 Step-by-Step Setup

### Step 1: Grant Accessibility Permissions

1. **Open System Preferences** → **Security & Privacy** → **Privacy** tab
2. **Select "Accessibility"** from the left sidebar
3. **Click the lock** 🔒 to make changes (enter your password)
4. **Add your terminal application**:
   - If using Terminal: Click **+** → Navigate to `/Applications/Utilities/Terminal.app`
   - If using iTerm2: Click **+** → Navigate to `/Applications/iTerm.app`
   - If using another terminal, add that instead
5. **Check the box** next to your terminal application
6. **Click the lock** 🔒 again to save changes

### Step 2: Grant Input Monitoring Permissions

1. Still in **System Preferences** → **Security & Privacy** → **Privacy**
2. **Select "Input Monitoring"** from the left sidebar  
3. **Click the lock** 🔒 to make changes
4. **Add your terminal application** (same as Step 1)
5. **Check the box** next to your terminal application
6. **Click the lock** 🔒 to save changes

### Step 3: Use the macOS-Specific Configuration

Download and use the macOS-optimized configuration:

```bash
# Navigate to your config directory
cd ~/src/tries/2025-08-30-colemak/

# The macOS-specific config is already created: colemak-dh-macos.kbd
# It has proper macOS shortcuts (Cmd instead of Ctrl) and simplified input config
```

### Step 4: Run Kanata with Sudo

**⚠️ IMPORTANT**: Kanata must be run with `sudo` on macOS to access IOKit:

```bash
# Run with sudo - this is REQUIRED on macOS
sudo kanata --cfg colemak-dh-macos.kbd
```

If you get a password prompt, enter your admin password.

### Step 5: Verify It Works

You should see output like:
```
[INFO] kanata v1.9.0 starting
[INFO] process unmapped keys: true  
[INFO] config file is valid
[INFO] entering the processing loop
[INFO] Starting kanata proper
```

**No more IOKit errors!** 🎉

## 🎹 Layout Features

### Layer Control
- **Caps Lock**: Tap for Caps Lock, Hold for Extend layer
- **Caps + 1**: Switch to QWERTY
- **Caps + 2**: Switch to Colemak-DH  
- **Caps + 3**: Switch to Colemak-DHk

### Extend Layer (Hold Caps Lock)
```
Row 2:  Esc  ←   Find  →   Ins  PgUp Home  ↑   End  Menu
Row 3:  Alt  Cmd  Shift Ctrl RAlt PgDn  ←    ↓   →   Del
Row 4:  Cut  Copy Tab  Paste Undo PgDn Bspc Shift Ctrl Menu
```

### macOS-Specific Shortcuts
- **Copy/Paste/Cut**: Uses `Cmd+C/V/X` (not Ctrl)
- **Find**: Uses `Cmd+F`
- **Select All**: Uses `Cmd+A` 
- **Undo**: Uses `Cmd+Z`
- **Browser Navigation**: Uses `Cmd+[` and `Cmd+]`

## 🚀 Advanced Setup

### Run Kanata on Login (Optional)

Create a simple script to auto-start Kanata:

```bash
# Create a startup script
cat > ~/start-kanata.sh << 'EOF'
#!/bin/bash
cd ~/src/tries/2025-08-30-colemak/
sudo kanata --cfg colemak-dh-macos.kbd
EOF

# Make it executable
chmod +x ~/start-kanata.sh
```

**Note**: You'll still need to enter your sudo password each time.

### Alternative: Skip Sudo with Workaround

If you don't want to use sudo, you can try this approach (less reliable):

1. **Add Kanata binary to Accessibility/Input Monitoring** instead of Terminal
2. **Run without sudo**: `kanata --cfg colemak-dh-macos.kbd`

This sometimes works but is not guaranteed on all macOS versions.

## 🐞 Troubleshooting

### "Operation not permitted" Error

```bash
# Check if your terminal has the right permissions:
ls -la /Applications/Utilities/Terminal.app

# Re-grant permissions:
# System Preferences → Security & Privacy → Privacy → Reset permissions
```

### "Device not found" Error

Try specifying the exact keyboard name:
```bash
# Find your keyboard name:
ioreg -c IOHIDKeyboard -r

# Update the config to use specific name:
# input  (iokit-name "Apple Internal Keyboard / Trackpad")
```

### Keys Not Working

1. **Check sudo**: Make sure you're running with `sudo`
2. **Check permissions**: Verify Accessibility & Input Monitoring permissions
3. **Restart terminal**: Close and reopen your terminal app
4. **Test different config**: Try with `input (iokit-name)` (no device specified)

### Kanata Conflicts with Other Apps

If you use other keyboard software (Karabiner-Elements, etc.):
1. **Quit other keyboard software** before running Kanata
2. **Or**: Configure them to work together (advanced)

## 📄 Configuration Files

- `colemak-dh-macos.kbd` - macOS-optimized configuration (use this one!)
- `colemak-dh-ansi.kbd` - Generic ANSI configuration (needs modification for macOS)

## 🔗 Related Resources

- [Kanata Documentation](https://github.com/jtroo/kanata)
- [Colemak Mod-DH Project](https://colemakmods.github.io/mod-dh/)
- [macOS IOKit Documentation](https://developer.apple.com/documentation/iokit)

## ✅ Quick Test Commands

```bash
# 1. Test configuration syntax
kanata --cfg colemak-dh-macos.kbd --check

# 2. Run with debug output
sudo kanata --cfg colemak-dh-macos.kbd --debug

# 3. Run normally  
sudo kanata --cfg colemak-dh-macos.kbd
```

---

**💡 Pro Tip**: After setup, bookmark this command:
```bash
sudo kanata --cfg ~/src/tries/2025-08-30-colemak/colemak-dh-macos.kbd
```

Now your MacBook will have the ergonomic Colemak Mod-DH layout with advanced layer functionality! 🎉