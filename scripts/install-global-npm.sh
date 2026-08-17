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
		"@earendil-works/pi-coding-agent:0.84.2"
		"@ff-labs/pi-fff:0.10.3"
		"@futurelab-studio/telepi:0.4.2"
		"@juicesharp/rpiv-advisor:2.6.0"
		"@juicesharp/rpiv-ask-user-question:2.6.0"
		"@plannotator/pi-extension:0.27.3"
		"@yofriadi/pi-antigravity-oauth:0.3.0"
		"pi-annotate:0.5.0"
		"pi-btw:0.4.1"
		"pi-code-previews:0.1.36"
		"pi-codex-goal:0.2.0"
		"pi-cursor-sdk:0.2.0"
		"pi-dynamic-workflows:1.0.1"
		"pi-footer:0.5.1"
		"pi-manage-todo-list:0.4.0"
		"pi-mcp-adapter:2.26.0"
		"pi-simplify:0.2.3"
		"pi-subagents:0.50.0"
		"pi-tps-meter:3.0.4"
		"pi-web-access:0.23.0"
	)

	local -a agents=(
		"@agentmemory/agentmemory:0.9.28"
		"@alibaba-group/open-code-review:1.9.4"
		"@augmentcode/auggie:0.35.0"
		"@github/copilot:1.0.80"
		"@google/gemini-cli:0.55.1"
		"@kaitranntt/ccs:8.9.0"
		"@kilocode/cli:7.4.22"
		"@mimo-ai/cli:0.1.12"
		"@native-sdk/cli:0.9.1"
		"@openai/codex:0.147.0"
		"@rama_nigg/open-cursor:2.5.7"
		"@xai-official/grok:1.0.4"
		"agent-browser:0.34.0"
		"cline:3.0.55"
		"command-code:1.26.0"
	)

	local -a lang_servers=(
		"@tailwindcss/language-server:0.16.0"
		"@vtsls/language-server:0.3.0"
		"basedpyright:1.39.10"
		"typescript-language-server:5.3.0"
		"typescript:7.0.2"
		"vscode-langservers-extracted:4.10.0"
	)

	local -a format_lint=(
		"@fsouza/prettierd:0.29.0"
		"cspell:10.0.1"
		"eslint_d:15.0.3"
		"oxfmt:0.63.0"
		"oxlint:1.78.0"
		"prettier:3.9.6"
		"rustywind:0.27.0"
	)

	local -a tooling=(
		"@antfu/ni:30.5.0"
		"@mermaid-js/mermaid-cli:11.16.0"
		"9router:0.5.55"
		"bumpp:12.2.1"
		"cavemem:0.2.1"
		"clawpatch:0.7.2"
		"corepack:0.35.0"
		"eas-cli:22.0.0"
		"freebuff:0.0.149"
		"generate-license:1.0.0"
		"generate:0.14.0"
		"kanban:0.1.70"
		"mac-ocr:1.1.1"
		"nlf:2.1.1"
		"npm-check-updates:23.0.2"
		"npm:12.0.2"
		"omniroute:3.8.49"
		"portless:0.15.5"
		"reasonix:1.25.2"
		"vercel:59.1.3"
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
