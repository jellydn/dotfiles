# K9s Configuration

A Kubernetes CLI to manage your clusters in style with custom aliases and optimized settings.

## Features

- **Custom Aliases**: Quick shortcuts for common k8s resources (dp, sec, jo, etc.)
- **Mouse Disabled**: Keyboard-first navigation for efficiency
- **Optimized Refresh**: 2-second refresh rate for balanced performance
- **Resource Thresholds**: CPU/Memory warnings at 70%, critical at 90%
- **Enhanced Logger**: 5000 line buffer, 100 line tail

## Installation

The k9s configuration is integrated into the dotfiles:

```sh
# Using the dotfiles install script
./install.sh stow-app k9s

# Or install k9s itself
./install.sh k9s
```

**Note:** On macOS, k9s stores config in `~/Library/Application Support/k9s/`, but this will be symlinked to `~/.config/k9s/` for consistency.

## Configuration

### Main Settings (config.yaml)

```yaml
refreshRate: 2              # Refresh every 2 seconds
ui:
  enableMouse: false        # Keyboard-only navigation
  noIcons: false           # Show icons

thresholds:
  cpu:
    critical: 90
    warn: 70
  memory:
    critical: 90
    warn: 70
```

### Aliases (aliases.yaml)

Quick shortcuts for resources:

| Alias | Resource | Description |
|-------|----------|-------------|
| `dp` | deployments | Deployments |
| `sec` | v1/secrets | Secrets |
| `jo` | jobs | Jobs |
| `cr` | clusterroles | Cluster Roles |
| `crb` | clusterrolebindings | Cluster Role Bindings |
| `ro` | roles | Roles |
| `rb` | rolebindings | Role Bindings |
| `np` | networkpolicies | Network Policies |

## Key Bindings

K9s uses vim-style navigation:

### Global

| Key | Action |
|-----|--------|
| `:` | Command mode |
| `/` | Filter/search |
| `?` | Help |
| `Ctrl-a` | Show all namespaces |
| `Ctrl-c` | Exit |
| `0` | Show all pods |

### Navigation

| Key | Action |
|-----|--------|
| `j/k` | Down/Up |
| `g/G` | Top/Bottom |
| `h/l` | Left/Right (columns) |
| `Enter` | View details |
| `Esc` | Back |

### Actions

| Key | Action |
|-----|--------|
| `d` | Describe resource |
| `e` | Edit resource |
| `l` | View logs |
| `y` | YAML view |
| `Ctrl-d` | Delete resource |
| `s` | Shell into pod |
| `f` | Port-forward |

### Context & Namespace

| Key | Action |
|-----|--------|
| `:ctx` | Switch context |
| `:ns` | Switch namespace |
| `:po` | View pods |
| `:svc` | View services |
| `:dp` | View deployments (alias) |

## Usage

### Starting K9s

```sh
# Start in default namespace
k9s

# Start in specific namespace
k9s -n kube-system

# Start with specific context
k9s --context production

# Read-only mode (safe for production)
k9s --readonly
```

### Common Workflows

```sh
# View pods and their logs
:po                    # Go to pods
/myapp                 # Filter by name
Enter                  # View details
l                      # View logs
0                      # View all containers
s                      # Shell into pod

# Manage deployments
:dp                    # Or use alias
Enter                  # Select deployment
e                      # Edit
y                      # View YAML
d                      # Describe

# Port forwarding
:svc                   # Go to services
Enter                  # Select service
f                      # Port forward
```

## Customization

### Add Custom Aliases

Edit `~/.config/k9s/aliases.yaml`:

```yaml
aliases:
  # Add your custom aliases
  ing: networking.k8s.io/v1/ingresses
  cm: v1/configmaps
  pvc: v1/persistentvolumeclaims
```

### Add Custom Skins

Create a skin file in `~/.config/k9s/skins/`:

```yaml
# Example: kanagawa.yaml
k9s:
  body:
    fgColor: "#dcd7ba"
    bgColor: "#1f1f28"
    logoColor: "#7e9cd8"
  # ... more color definitions
```

Then reference it in `config.yaml`:

```yaml
k9s:
  ui:
    skin: kanagawa
```

## Cluster-Specific Configs

K9s automatically creates cluster-specific configs in `clusters/<cluster-name>/`:
- These are **not** included in dotfiles (machine-specific)
- Contains view settings and benchmarks per cluster
- Auto-generated when you connect to a cluster

## Troubleshooting

### Config not loading

Check symlink:
```sh
ls -la ~/.config/k9s
# Should point to dotfiles
```

### Mouse not working

Mouse is intentionally disabled for keyboard-first workflow. To enable:
```yaml
# In config.yaml
ui:
  enableMouse: true
```

### Slow refresh

Adjust refresh rate:
```yaml
refreshRate: 5  # Slower (5 seconds)
refreshRate: 1  # Faster (1 second)
```

### Permission errors

Ensure you have proper kubeconfig and cluster access:
```sh
kubectl cluster-info
kubectl auth can-i get pods
```

## Resources

- [Official K9s Documentation](https://k9scli.io/)
- [K9s GitHub](https://github.com/derailed/k9s)
- [Skins Gallery](https://k9scli.io/topics/skins/)

## Author

👤 **Huynh Duc Dung**

- Website: https://productsway.com/
- Twitter: [@jellydn](https://twitter.com/jellydn)
- Github: [@jellydn](https://github.com/jellydn)

## Show your support

If this guide has been helpful, please give it a ⭐️.
