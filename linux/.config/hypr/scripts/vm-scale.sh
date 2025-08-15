#!/bin/bash
# VM Auto-scaling script for Hyprland
# Detects VM environment and sets appropriate display scaling

# Create config directory if it doesn't exist
mkdir -p ~/.config/hyprland

# Function to detect VM type (simplified VMware detection)
detect_vm_type() {
    local vm_type="unknown"
    local arch=$(uname -m)
    
    # Check for VMware (including Fusion, Workstation, ESXi)
    if lspci | grep -i vmware >/dev/null 2>&1; then
        vm_type="vmware"
    elif dmidecode -s system-manufacturer 2>/dev/null | grep -i "vmware" >/dev/null 2>&1; then
        vm_type="vmware"
    elif dmesg 2>/dev/null | grep -i "vmware\|vmxnet\|pvscsi" | head -1 >/dev/null 2>&1; then
        vm_type="vmware"
    
    # Check for UTM (common on macOS, especially Apple Silicon)
    elif dmidecode -s system-product-name 2>/dev/null | grep -i "utm\|apple virtualization" >/dev/null 2>&1; then
        vm_type="utm"
    elif lspci | grep -i "apple\|utm" >/dev/null 2>&1; then
        vm_type="utm"
    elif [[ "$arch" == "aarch64" ]] && (dmesg 2>/dev/null | grep -i "virtio\|qemu" >/dev/null 2>&1); then
        vm_type="utm"
    
    # Check for VirtualBox
    elif lspci | grep -i virtualbox >/dev/null 2>&1 || lsmod | grep -i vboxguest >/dev/null 2>&1; then
        vm_type="virtualbox"
    elif dmidecode -s system-product-name 2>/dev/null | grep -i "virtualbox" >/dev/null 2>&1; then
        vm_type="virtualbox"
    
    # Check for Parallels (common on macOS)
    elif lspci | grep -i parallels >/dev/null 2>&1; then
        vm_type="parallels"
    elif dmidecode -s system-manufacturer 2>/dev/null | grep -i "parallels" >/dev/null 2>&1; then
        vm_type="parallels"
    
    # Check for QEMU/KVM
    elif lscpu | grep -i "hypervisor vendor" | grep -i "kvm" >/dev/null 2>&1; then
        vm_type="qemu_kvm"
    elif lspci | grep -i "red hat\|virtio" >/dev/null 2>&1; then
        vm_type="qemu_kvm"
    elif dmesg 2>/dev/null | grep -i "kvm\|qemu" >/dev/null 2>&1; then
        vm_type="qemu_kvm"
    
    # Check DMI info for generic VM indicators
    elif dmidecode -s system-product-name 2>/dev/null | grep -i "virtual\|vmware\|qemu\|kvm\|xen\|bochs" >/dev/null 2>&1; then
        vm_type="generic_vm"
    fi
    
    echo "$vm_type"
}

# Function to get current resolution
get_resolution() {
    local resolution
    resolution=$(hyprctl monitors -j 2>/dev/null | jq -r '.[0] | "\(.width)x\(.height)"' 2>/dev/null || echo "")
    if [[ -z "$resolution" || "$resolution" == "null" ]]; then
        # Fallback to xrandr if hyprctl fails (using standard grep)
        resolution=$(xrandr 2>/dev/null | grep '\*' | head -1 | sed 's/.*\([0-9]\{3,4\}x[0-9]\{3,4\}\).*/\1/' || echo "")
    fi
    echo "${resolution:-1920x1080}"  # Default fallback
}

# Function to determine optimal scale based on VM type and resolution
determine_scale() {
    local vm_type="$1"
    local resolution="$2"
    local width height scale
    
    # Extract width and height
    width=$(echo "$resolution" | cut -d'x' -f1)
    height=$(echo "$resolution" | cut -d'x' -f2)
    
    # Default scale
    scale="1"
    
    # VM-specific scaling logic
    case "$vm_type" in
        "vmware")
            # VMware Fusion/Workstation typically handles scaling well
            if [[ $width -le 1366 ]]; then
                scale="1"      # Small screens - no scaling
            elif [[ $width -le 1920 ]]; then
                scale="1.25"   # Standard HD - slight scaling for readability
            elif [[ $width -le 2560 ]]; then
                scale="1.5"    # 1440p - more scaling needed
            else
                scale="1.75"   # 4K+ - significant scaling
            fi
            ;;
        "utm")
            # UTM on Apple Silicon may need conservative scaling
            if [[ $width -le 1366 ]]; then
                scale="1.1"    # Slight bump for small screens
            elif [[ $width -le 1920 ]]; then
                scale="1.25"   # Good balance for 1080p
            elif [[ $width -le 2560 ]]; then
                scale="1.4"    # Conservative scaling for high-res
            else
                scale="1.6"    # UTM may struggle with high scaling
            fi
            ;;
        "virtualbox")
            # VirtualBox often needs more aggressive scaling
            if [[ $width -le 1366 ]]; then
                scale="1.1"
            elif [[ $width -le 1920 ]]; then
                scale="1.3"    # Slightly more aggressive than VMware
            elif [[ $width -le 2560 ]]; then
                scale="1.6"
            else
                scale="1.8"
            fi
            ;;
        "parallels")
            # Similar to VMware but may need slight adjustments
            if [[ $width -le 1366 ]]; then
                scale="1"
            elif [[ $width -le 1920 ]]; then
                scale="1.2"
            elif [[ $width -le 2560 ]]; then
                scale="1.4"
            else
                scale="1.7"
            fi
            ;;
        "qemu_kvm"|"generic_vm")
            # Conservative scaling for generic VMs
            if [[ $width -le 1366 ]]; then
                scale="1"
            elif [[ $width -le 1920 ]]; then
                scale="1.2"
            elif [[ $width -le 2560 ]]; then
                scale="1.4"
            else
                scale="1.6"
            fi
            ;;
        *)
            # Unknown or native system - minimal scaling
            if [[ $width -le 1366 ]]; then
                scale="1"
            elif [[ $width -le 1920 ]]; then
                scale="1.1"
            else
                scale="1.2"
            fi
            ;;
    esac
    
    echo "$scale"
}

# Main execution
main() {
    local vm_type resolution scale
    
    echo "# VM Auto-scaling Configuration" > ~/.config/hyprland/vm-monitor.conf
    echo "# Generated on $(date)" >> ~/.config/hyprland/vm-monitor.conf
    echo "" >> ~/.config/hyprland/vm-monitor.conf
    
    # Detect VM type
    vm_type=$(detect_vm_type)
    echo "# Detected VM type: $vm_type" >> ~/.config/hyprland/vm-monitor.conf
    
    # Get current resolution (may take a moment for Hyprland to initialize)
    sleep 2
    resolution=$(get_resolution)
    echo "# Detected resolution: $resolution" >> ~/.config/hyprland/vm-monitor.conf
    
    # Determine optimal scale
    scale=$(determine_scale "$vm_type" "$resolution")
    echo "# Calculated scale: $scale" >> ~/.config/hyprland/vm-monitor.conf
    echo "" >> ~/.config/hyprland/vm-monitor.conf
    
    # Generate monitor configuration
    echo "# Auto-generated monitor configuration" >> ~/.config/hyprland/vm-monitor.conf
    
    # Always use simple monitor config for VMs to avoid issues
    if [[ "$vm_type" != "unknown" ]] || [[ "$(uname -m)" == "aarch64" ]]; then
        # VM detected or ARM system - use simple resolution with scaling
        echo "monitor=,1920x1080@60,auto,$scale" >> ~/.config/hyprland/vm-monitor.conf
    else
        # Non-VM system - use preferred resolution
        echo "monitor=,preferred,auto,1" >> ~/.config/hyprland/vm-monitor.conf
    fi
    
    # Add VM-specific optimizations
    echo "" >> ~/.config/hyprland/vm-monitor.conf
    echo "# VM-specific environment variables" >> ~/.config/hyprland/vm-monitor.conf
    
    case "$vm_type" in
        "vmware"|"parallels")
            echo "env = WLR_NO_HARDWARE_CURSORS,1" >> ~/.config/hyprland/vm-monitor.conf
            ;;
        "utm")
            echo "env = WLR_NO_HARDWARE_CURSORS,1" >> ~/.config/hyprland/vm-monitor.conf
            echo "env = WLR_RENDERER_ALLOW_SOFTWARE,1" >> ~/.config/hyprland/vm-monitor.conf
            ;;
        "virtualbox")
            echo "env = WLR_NO_HARDWARE_CURSORS,1" >> ~/.config/hyprland/vm-monitor.conf
            echo "env = LIBGL_ALWAYS_SOFTWARE,1" >> ~/.config/hyprland/vm-monitor.conf
            ;;
        "qemu_kvm"|"generic_vm")
            echo "env = WLR_NO_HARDWARE_CURSORS,1" >> ~/.config/hyprland/vm-monitor.conf
            echo "env = WLR_RENDERER_ALLOW_SOFTWARE,1" >> ~/.config/hyprland/vm-monitor.conf
            ;;
    esac
    
    # Log the result
    echo "VM auto-scaling configured:"
    echo "  VM Type: $vm_type"
    echo "  Resolution: $resolution"
    echo "  Scale Factor: $scale"
    echo "  Config: ~/.config/hyprland/vm-monitor.conf"
}

# Run main function
main "$@"