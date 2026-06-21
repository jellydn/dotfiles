#!/usr/bin/env bash
# Install pinned global npm packages. Update versions here; run from dotfiles repo.
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

check_npm() {
	if ! command -v npm >/dev/null 2>&1; then
		log_error "npm is not installed. Install Node.js first."
		exit 1
	fi
	log_info "Using npm $(npm --version)"
}

# packages: "name:version" (scoped names use first colon as separator)
install_package() {
	local spec="$1"
	local name="${spec%%:*}"
	local version="${spec#*:}"

	log_info "Installing ${name}@${version}..."
	local logfile
	logfile="$(mktemp)"
	if npm install -g "${name}@${version}" >"$logfile" 2>&1; then
		log_success "✓ ${name}@${version}"
		rm -f "$logfile"
		return 0
	fi
	log_warning "✗ Failed ${name}@${version}"
	tail -n 15 "$logfile" >&2
	rm -f "$logfile"
	return 1
}

main() {
	log_info "Installing global npm packages..."
	check_npm

	local -a pi_tools=(
		"@earendil-works/pi-coding-agent:0.79.3"
		"@ff-labs/pi-fff:0.9.4"
		"@plannotator/pi-extension:0.20.1"
		"pi-annotate:0.4.3"
		"pi-btw:0.4.1"
		"pi-code-previews:0.1.32"
		"pi-codex-goal:0.1.26"
		"pi-manage-todo-list:0.4.0"
		"pi-mcp-adapter:2.10.0"
		"pi-simplify:0.2.2"
		"pi-subagents:0.28.0"
	)

	local -a agents=(
		"@agentmemory/agentmemory:0.9.27"
		"@github/copilot:1.0.62"
		"@google/gemini-cli:0.46.0"
		"@kaitranntt/ccs:8.2.0"
		"@kilocode/cli:7.3.45"
		"@mimo-ai/cli:0.1.0"
		"@openai/codex:0.139.0"
		"agent-browser:0.27.3"
		"cline:3.0.24"
		"command-code:0.37.2"
	)

	local -a lang_servers=(
		"@tailwindcss/language-server:0.14.29"
		"@vtsls/language-server:0.3.0"
		"basedpyright:1.39.7"
		"typescript-language-server:5.3.0"
		"typescript:6.0.3"
		"vscode-langservers-extracted:4.10.0"
	)

	local -a format_lint=(
		"@fsouza/prettierd:0.28.0"
		"cspell:10.0.1"
		"eslint_d:15.0.2"
		"oxfmt:0.54.0"
		"oxlint:1.69.0"
		"prettier:3.8.4"
		"rustywind:0.24.3"
	)

	local -a tooling=(
		"@antfu/ni:30.1.0"
		"@mermaid-js/mermaid-cli:11.15.0"
		"bumpp:11.1.0"
		"clawpatch:0.6.0"
		"corepack:0.35.0"
		"eas-cli:20.1.0"
		"freebuff:0.0.107"
		"generate-license:1.0.0"
		"generate:0.14.0"
		"kanban:0.1.68"
		"npm-check-updates:22.2.3"
		"npm:11.17.0"
		"portless:0.14.0"
		"vercel:54.13.0"
	)

	local -a all=()
	all+=("${pi_tools[@]}" "${agents[@]}" "${lang_servers[@]}" "${format_lint[@]}" "${tooling[@]}")

	local total=${#all[@]}
	local installed=0
	local failed=0

	log_info "Found $total packages"
	echo

	for spec in "${all[@]}"; do
		if install_package "$spec"; then
			((installed++)) || true
		else
			((failed++)) || true
		fi
	done

	echo
	log_success "Installation complete: $installed / $total installed"
	if [[ $failed -gt 0 ]]; then
		log_warning "Failed: $failed (see stderr above)"
	fi

	echo
	log_info "Global packages:"
	npm list -g --depth=0 2>/dev/null || true
}

main "$@"