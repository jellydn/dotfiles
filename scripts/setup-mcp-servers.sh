#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Path to Claude settings file
CLAUDE_JSON="$HOME/.claude.json"
MCP_SERVERS_CONFIG="$(dirname "$0")/../common/.claude/mcp-servers.json"

# Check if Claude settings exist
if [[ ! -f "$CLAUDE_JSON" ]]; then
    log_error "Claude settings file not found at $CLAUDE_JSON"
    log_info "Please ensure Claude is installed and has been run at least once"
    exit 1
fi

# Check if MCP servers config exists
if [[ ! -f "$MCP_SERVERS_CONFIG" ]]; then
    log_error "MCP servers configuration not found at $MCP_SERVERS_CONFIG"
    exit 1
fi

# Backup existing Claude settings
backup_file="$CLAUDE_JSON.backup.$(date +%Y%m%d-%H%M%S)"
cp "$CLAUDE_JSON" "$backup_file"
log_info "Backed up existing settings to $backup_file"

# Read MCP servers configuration
mcp_servers=$(jq -r '.mcpServers' "$MCP_SERVERS_CONFIG")

# Update Claude settings with MCP servers
if jq --argjson servers "$mcp_servers" '.mcpServers = $servers' "$CLAUDE_JSON" > "$CLAUDE_JSON.tmp"; then
    mv "$CLAUDE_JSON.tmp" "$CLAUDE_JSON"
    log_success "MCP servers configuration updated successfully"
else
    log_error "Failed to update MCP servers configuration"
    log_info "Restoring backup..."
    mv "$backup_file" "$CLAUDE_JSON"
    exit 1
fi

# Verify the update
installed_servers=$(jq -r '.mcpServers | keys[]' "$CLAUDE_JSON" 2>/dev/null)
if [[ -n "$installed_servers" ]]; then
    log_info "Installed MCP servers:"
    echo "$installed_servers" | while read -r server; do
        echo "  ✅ $server"
    done
else
    log_warning "No MCP servers found after update"
fi

log_success "MCP servers setup complete!"
log_info "Restart Claude to apply changes"