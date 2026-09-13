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

# npm is often the vite-plus shim (~/.vite-plus/bin/npm → vp). After a
# successful `npm install -g`, vp checks whether the new bin is on PATH.
# If stdin is a TTY it prints:
#   '<bin>' is not available on your PATH.
#   Create a link in ~/.vite-plus/bin/ to make it available? [Y/n]
# Capturing stdout/stderr hides that prompt, so the script looks hung
# (telepi was the first new bin in the list). Closing stdin makes vp
# treat the install as non-interactive and auto-create the link.
npm_install_global() {
	# stdin must not be a TTY (see comment above). Caller captures output.
	npm install -g "$@" </dev/null
}

# packages: "name:version" (scoped names use first colon as separator)
install_package() {
	local spec="$1"
	local name="${spec%%:*}"
	local version="${spec#*:}"

	log_info "Installing ${name}@${version}..."
	local logfile
	logfile="$(mktemp)"
	if npm_install_global "${name}@${version}" >"$logfile" 2>&1; then
		log_success "✓ ${name}@${version}"
		rm -f "$logfile"
		return 0
	fi
	# npm 12 defaults allow-remote=none. Some packages pin URL tarballs
	# (e.g. pi-mcp-adapter → pkg.pr.new) and need an explicit opt-in.
	if grep -q EALLOWREMOTE "$logfile"; then
		log_warning "Retrying ${name}@${version} with --allow-remote=all"
		if npm_install_global --allow-remote=all "${name}@${version}" >"$logfile" 2>&1; then
			log_success "✓ ${name}@${version} (allow-remote)"
			rm -f "$logfile"
			return 0
		fi
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
		"@earendil-works/pi-coding-agent:0.85.1"
		"@ff-labs/pi-fff:0.10.6"
		"@futurelab-studio/telepi:0.4.2"
		"@juicesharp/rpiv-advisor:2.10.0"
		"@juicesharp/rpiv-ask-user-question:2.10.0"
		"@plannotator/pi-extension:0.27.14"
		"@yofriadi/pi-antigravity-oauth:0.3.0"
		"pi-annotate:0.5.2"
		"pi-btw:0.4.1"
		"pi-code-previews:0.1.36"
		"pi-codex-goal:0.3.0"
		"pi-cursor-sdk:0.3.6"
		"pi-dynamic-workflows:1.0.1"
		"pi-footer:0.5.1"
		"pi-manage-todo-list:0.4.0"
		"pi-mcp-adapter:2.33.0"
		"pi-simplify:0.2.3"
		"pi-subagents:0.67.0"
		"pi-tps-meter:3.0.4"
		"pi-web-access:0.29.0"
	)

	local -a agents=(
		"@agentmemory/agentmemory:0.9.29"
		"@alibaba-group/open-code-review:1.12.0"
		"@augmentcode/auggie:0.36.0"
		"@github/copilot:1.0.83"
		"@google/gemini-cli:0.59.0"
		"@deepseek-ai/dsh:0.1.5-rc.1"
		"@kaitranntt/ccs:8.10.0"
		"@kilocode/cli:7.6.2"
		"@mimo-ai/cli:0.1.14"
		"@native-sdk/cli:0.10.1"
		"@openai/codex:0.154.0"
		"@rama_nigg/open-cursor:2.5.8"
		"@xai-official/grok:1.0.30"
		"agent-browser:0.37.1"
		"cline:3.0.61"
		"command-code:1.53.1"
	)

	local -a lang_servers=(
		"@tailwindcss/language-server:0.16.0"
		"@vtsls/language-server:0.3.0"
		"basedpyright:1.40.1"
		"typescript-language-server:6.0.0"
		"typescript:7.0.2"
		"vscode-langservers-extracted:4.10.0"
	)

	local -a format_lint=(
		"@fsouza/prettierd:0.29.0"
		"cspell:10.3.0"
		"eslint_d:15.0.3"
		"oxfmt:0.67.0"
		"oxlint:1.82.0"
		"prettier:3.9.6"
		"rustywind:0.28.0"
	)

	local -a tooling=(
		"@antfu/ni:30.5.0"
		"@mermaid-js/mermaid-cli:11.17.0"
		"9router:0.5.75"
		"bumpp:12.3.0"
		"better-sqlite3:13.0.3"
		"cavemem:0.2.1"
		"clawpatch:0.8.0"
		"corepack:0.36.0"
		"eas-cli:24.3.0"
		"freebuff:0.0.174"
		"generate-license:1.0.0"
		"generate:0.14.0"
		"kanban:0.1.70"
		"mac-ocr:1.1.1"
		"nlf:2.1.1"
		"npm-check-updates:23.1.0"
		"npm:12.0.2"
		"omniroute:3.8.50"
		"portless:0.15.6"
		"reasonix:1.38.7"
		"vercel:59.16.0"
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
