#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                                                                              ║
# ║   ███████╗██╗   ██╗██████╗ ███████╗███╗   ██╗██╗   ██╗███╗   ███╗          ║
# ║   ██╔════╝██║   ██║██╔══██╗██╔════╝████╗  ██║██║   ██║████╗ ████║          ║
# ║   ███████╗██║   ██║██████╔╝█████╗  ██╔██╗ ██║██║   ██║██╔████╔██║          ║
# ║   ╚════██║██║   ██║██╔══██╗██╔══╝  ██║╚██╗██║██║   ██║██║╚██╔╝██║          ║
# ║   ███████║╚██████╔╝██████╔╝███████╗██║ ╚████║╚██████╔╝██║ ╚═╝ ██║          ║
# ║   ╚══════╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝          ║
# ║                                                                              ║
# ║   S U B D O M A I N   E N U M E R A T O R   v2.0                           ║
# ║   Professional Bash Reconnaissance Framework                                 ║
# ║                                                                              ║
# ╠══════════════════════════════════════════════════════════════════════════════╣
# ║  Author    : SANJAIAJAIRATHINAM                                              ║
# ║  Role      : Founder | Security Researcher | CTF Platform Developer          ║
# ║  Domain    : Cybersecurity | Ethical Hacking | AI Security                  ║
# ║  Projects  : DragonByte  PromptShield  LLM Prompt Injection Auditor         ║
# ║  GitHub    : github.com/sanjaiajairathinam                                   ║
# ║  LinkedIn  : linkedin.com/in/sanjaiajairathinam                              ║
# ╠══════════════════════════════════════════════════════════════════════════════╣
# ║  LEGAL : Authorized penetration testing & security research ONLY.           ║
# ║  Unauthorized use violates computer fraud laws. Use responsibly.             ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Description  : Pure-Bash subdomain brute-force enumeration with parallel DNS
#                resolution, live HTTP validation, colored terminal output,
#                progress tracking, and structured reporting.
#
# Dependencies : bash 4+, dig (dnsutils), host, xargs, curl (optional)
# Platform     : Linux / macOS / WSL2 / Kali / Parrot / BlackArch
# Usage        : ./subenum.sh -d <domain> -w <wordlist> [options]
# ──────────────────────────────────────────────────────────────────────────────

set -euo pipefail
IFS=$'\n\t'

# ══════════════════════════════════════════════════════════════════════════════
# §1  TERMINAL COLOR PALETTE
# ══════════════════════════════════════════════════════════════════════════════
BOLD='\033[1m'       DIM='\033[2m'        RESET='\033[0m'
C_RED='\033[38;5;196m'    C_ORANGE='\033[38;5;208m'  C_YELLOW='\033[38;5;226m'
C_GREEN='\033[38;5;46m'   C_CYAN='\033[38;5;51m'     C_BLUE='\033[38;5;27m'
C_MAGENTA='\033[38;5;201m' C_WHITE='\033[38;5;255m'  C_GRAY='\033[38;5;245m'
C_DKGRAY='\033[38;5;238m' C_LIME='\033[38;5;118m'    C_GOLD='\033[38;5;220m'
C_PINK='\033[38;5;213m'   C_TEAL='\033[38;5;44m'     C_INDIGO='\033[38;5;57m'

# ══════════════════════════════════════════════════════════════════════════════
# §2  GLOBAL CONSTANTS & STATE
# ══════════════════════════════════════════════════════════════════════════════
readonly VERSION="2.0"
readonly TOOL_NAME="SubEnum"
readonly AUTHOR="SANJAIAJAIRATHINAM"
readonly AUTHOR_ROLE="Founder | Security Researcher | CTF Platform Developer"
readonly AUTHOR_FIELD="Cybersecurity · Ethical Hacking · AI Security"
readonly AUTHOR_GITHUB="github.com/sanjaiajairathinam"
readonly AUTHOR_LINKEDIN="linkedin.com/in/sanjaiajairathinam"
readonly AUTHOR_INSTAGRAM="instagram.com/sanjaiajairathinam"
readonly AUTHOR_TEAM="Traveling Beats"
readonly AUTHOR_QUOTE='"I do not just break systems — I build the next generation of defenders."'

DOMAIN=""
WORDLIST=""
OUTPUT=""
SILENT=false
THREADS=10
HTTP_CHECK=false
TIMEOUT=3
FOUND=0
TOTAL=0
START_TIME=0
WORK_DIR=""
VERBOSE=false
DNS_SERVER=""
LOG_FILE=""
PROGRESS_PID=""

# ══════════════════════════════════════════════════════════════════════════════
# §3  BANNER
# ══════════════════════════════════════════════════════════════════════════════
print_banner() {
    $SILENT && return
    echo
    echo -e "${C_CYAN}${BOLD}"
    cat << 'ASCIIART'
  ██████╗ ██╗   ██╗██████╗ ███████╗███╗   ██╗██╗   ██╗███╗   ███╗
  ██╔════╝██║   ██║██╔══██╗██╔════╝████╗  ██║██║   ██║████╗ ████║
  ███████╗██║   ██║██████╔╝█████╗  ██╔██╗ ██║██║   ██║██╔████╔██║
  ╚════██║██║   ██║██╔══██╗██╔══╝  ██║╚██╗██║██║   ██║██║╚██╔╝██║
  ███████║╚██████╔╝██████╔╝███████╗██║ ╚████║╚██████╔╝██║ ╚═╝ ██║
  ╚══════╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝
ASCIIART
    echo -e "${RESET}"

    local SEP="${C_DKGRAY}${BOLD}$(printf '═%.0s' {1..72})${RESET}"
    local sep="${C_DKGRAY}$(printf '─%.0s' {1..72})${RESET}"

    echo -e "  $SEP"
    printf "  ${C_GOLD}${BOLD}  %-22s${RESET}  ${C_WHITE}%-43s${RESET}\n" \
        "✦  ${TOOL_NAME} v${VERSION}" \
        "DNS Recon · Subdomain Brute-Force · Web Fingerprinting"
    echo -e "  $sep"
    printf "  ${C_GRAY}  %-16s${RESET}  ${C_CYAN}${BOLD}%s${RESET}\n"    "Author"    "$AUTHOR"
    printf "  ${C_GRAY}  %-16s${RESET}  ${C_LIME}%s${RESET}\n"           "Role"      "$AUTHOR_ROLE"
    printf "  ${C_GRAY}  %-16s${RESET}  ${C_TEAL}%s${RESET}\n"           "Focus"     "$AUTHOR_FIELD"
    printf "  ${C_GRAY}  %-16s${RESET}  ${C_BLUE}%s${RESET}\n"           "GitHub"    "$AUTHOR_GITHUB"
    printf "  ${C_GRAY}  %-16s${RESET}  ${C_INDIGO}%s${RESET}\n"         "LinkedIn"  "$AUTHOR_LINKEDIN"
    echo -e "  $sep"
    echo -e "  ${C_RED}${BOLD}  ⚠  LEGAL:${RESET}${C_ORANGE} For authorized penetration testing ONLY.${RESET}"
    echo -e "  ${C_DKGRAY}  Unauthorized scanning is illegal. Author assumes zero liability.${RESET}"
    echo -e "  $SEP"
    echo
}

# ══════════════════════════════════════════════════════════════════════════════
# §4  AUTHOR PROFILE CARD  (./subenum.sh -p)
# ══════════════════════════════════════════════════════════════════════════════
print_author_profile() {
    local SEP="${C_GOLD}${BOLD}$(printf '═%.0s' {1..72})${RESET}"
    local sep="${C_CYAN}$(printf '─%.0s' {1..72})${RESET}"

    echo
    echo -e "  $SEP"
    echo -e "  ${C_GOLD}${BOLD}  ◈  AUTHOR PROFILE — ${AUTHOR}${RESET}"
    echo -e "  $SEP"

    # ── Professional Bio ──────────────────────────────────────────────────────
    echo
    echo -e "  ${C_MAGENTA}${BOLD}  ◉  PROFESSIONAL BIO${RESET}"
    echo -e "  $sep"
    echo -e "  ${C_WHITE}"
    printf '%s\n' \
"  SANJAIAJAIRATHINAM is a passionate cybersecurity researcher, ethical hacker," \
"  and platform builder on a mission to reshape how the next generation learns" \
"  offensive and defensive security. As the founder of DragonByte — a real-world" \
"  CTF training platform — and the creator of PromptShield and the LLM Prompt" \
"  Injection Auditor, he bridges the gap between cutting-edge AI security research" \
"  and practical, hands-on learning. Deeply active in the global security community," \
"  he crafts challenges that test real-world skills and builds tools that defend AI" \
"  systems from emerging prompt injection attack vectors."
    echo -e "${RESET}"

    # ── Personal Branding Summary ─────────────────────────────────────────────
    echo -e "  ${C_CYAN}${BOLD}  ◉  PERSONAL BRANDING SUMMARY${RESET}"
    echo -e "  $sep"
    echo -e "  ${C_WHITE}"
    printf '%s\n' \
"  The intersection of hacking and building — that is where SANJAIAJAIRATHINAM" \
"  operates. Not just a security researcher, but an architect of learning" \
"  ecosystems. Whether auditing LLM prompts for injection vulnerabilities," \
"  engineering CTF challenges that mirror real exploits, or shipping full-stack" \
"  security platforms with Next.js and Firebase — his work carries a singular" \
"  philosophy: security knowledge must be accessible, applied, and alive."
    echo -e "${RESET}"

    # ── Portfolio ─────────────────────────────────────────────────────────────
    echo -e "  ${C_LIME}${BOLD}  ◉  PORTFOLIO HIGHLIGHTS${RESET}"
    echo -e "  $sep"
    printf "    ${C_GOLD}${BOLD}▸ %-22s${RESET}  ${C_WHITE}%s${RESET}\n" \
        "DragonByte"    "CTF platform for real-world hacking practice & challenge labs"
    printf "    ${C_GOLD}${BOLD}▸ %-22s${RESET}  ${C_WHITE}%s${RESET}\n" \
        "PromptShield"  "AI security tool detecting & blocking prompt injection attacks"
    printf "    ${C_GOLD}${BOLD}▸ %-22s${RESET}  ${C_WHITE}%s${RESET}\n" \
        "LLM Auditor"   "Deep analysis & hardening framework for LLM prompt surfaces"
    printf "    ${C_GOLD}${BOLD}▸ %-22s${RESET}  ${C_WHITE}%s${RESET}\n" \
        "SubEnum v2.0"  "This tool — professional Bash recon framework"
    echo

    # ── LinkedIn About ────────────────────────────────────────────────────────
    echo -e "  ${C_TEAL}${BOLD}  ◉  LINKEDIN 'ABOUT' SECTION${RESET}"
    echo -e "  $sep"
    echo -e "  ${C_WHITE}"
    printf '%s\n' \
"  Cybersecurity Researcher | Ethical Hacker | CTF Platform Builder" \
"" \
"  I build platforms that teach hackers to hack — ethically." \
"  Founder of DragonByte CTF, creator of PromptShield (AI prompt injection" \
"  defense), and researcher focused on web exploitation and LLM security." \
"" \
"  Stack  : Web Security · Pentesting · Next.js · Firebase · Bash · AI Sec" \
"  Mission: Building the tools and challenges the next generation of defenders need." \
"  Open to: CTF design collabs, AI security research & red team tooling."
    echo -e "${RESET}"

    # ── Skills Matrix ─────────────────────────────────────────────────────────
    echo -e "  ${C_PINK}${BOLD}  ◉  SKILLS MATRIX${RESET}"
    echo -e "  $sep"
    local -A SKILLS=(
        ["Web Security"]="20:Expert"
        ["Penetration Testing"]="17:Advanced"
        ["CTF Development"]="20:Expert"
        ["AI / Prompt Injection Defense"]="16:Advanced"
        ["JavaScript / Next.js"]="14:Proficient"
        ["Firebase / Backend"]="13:Proficient"
        ["Bash Scripting"]="20:Expert"
    )
    local skill_order=(
        "Web Security"
        "Penetration Testing"
        "CTF Development"
        "AI / Prompt Injection Defense"
        "JavaScript / Next.js"
        "Firebase / Backend"
        "Bash Scripting"
    )
    for skill in "${skill_order[@]}"; do
        local val="${SKILLS[$skill]}"
        local filled="${val%%:*}"
        local empty=$(( 20 - filled ))
        local level="${val##*:}"
        local bar=""
        for (( i=0; i<filled; i++ )); do bar+="█"; done
        for (( i=0; i<empty; i++ )); do bar+="░"; done
        printf "    ${C_WHITE}%-32s${RESET}  ${C_CYAN}%s${RESET}  ${C_GRAY}%s${RESET}\n" \
            "$skill" "$bar" "$level"
    done
    echo

    # ── Signature Quote ───────────────────────────────────────────────────────
    echo -e "  ${C_ORANGE}${BOLD}  ◉  SIGNATURE QUOTE${RESET}"
    echo -e "  $sep"
    echo -e "    ${C_GOLD}${BOLD}${AUTHOR_QUOTE}${RESET}"
    echo -e "    ${C_GRAY}                                                — ${AUTHOR}${RESET}"
    echo

    # ── Social Links ──────────────────────────────────────────────────────────
    echo -e "  ${C_DKGRAY}$(printf '─%.0s' {1..72})${RESET}"
    echo -e "  ${C_GRAY}${BOLD}  Social Links${RESET}"
    printf "    ${C_BLUE}${BOLD}%-14s${RESET}  %s\n"    "GitHub:"    "$AUTHOR_GITHUB"
    printf "    ${C_INDIGO}${BOLD}%-14s${RESET}  %s\n"  "LinkedIn:"  "$AUTHOR_LINKEDIN"
    printf "    ${C_PINK}${BOLD}%-14s${RESET}  %s\n"    "Instagram:" "$AUTHOR_INSTAGRAM"
    printf "    ${C_TEAL}${BOLD}%-14s${RESET}  %s\n"    "Team:"      "$AUTHOR_TEAM"
    echo
    echo -e "  $SEP"
    echo
}

# ══════════════════════════════════════════════════════════════════════════════
# §5  USAGE / HELP
# ══════════════════════════════════════════════════════════════════════════════
usage() {
    local sep="${C_DKGRAY}$(printf '─%.0s' {1..68})${RESET}"
    echo -e "  ${C_GOLD}${BOLD}USAGE${RESET}"
    echo -e "    $(basename "$0") ${C_CYAN}-d${RESET} <domain> ${C_CYAN}-w${RESET} <wordlist> [OPTIONS]"
    echo
    echo -e "  $sep"
    echo -e "  ${C_WHITE}${BOLD}REQUIRED${RESET}"
    echo -e "  $sep"
    printf "    ${C_CYAN}%-20s${RESET}  %s\n" "-d <domain>"   "Target root domain  (e.g. example.com)"
    printf "    ${C_CYAN}%-20s${RESET}  %s\n" "-w <wordlist>" "Subdomain wordlist file path"
    echo
    echo -e "  $sep"
    echo -e "  ${C_WHITE}${BOLD}OPTIONS${RESET}"
    echo -e "  $sep"
    printf "    ${C_CYAN}%-20s${RESET}  %s\n" "-o <file>"     "Write discovered subdomains to output file"
    printf "    ${C_CYAN}%-20s${RESET}  %s\n" "-t <num>"      "Parallel threads (default: 10)"
    printf "    ${C_CYAN}%-20s${RESET}  %s\n" "-T <sec>"      "DNS/HTTP timeout in seconds (default: 3)"
    printf "    ${C_CYAN}%-20s${RESET}  %s\n" "-r <dns>"      "Custom DNS resolver (e.g. 8.8.8.8)"
    printf "    ${C_CYAN}%-20s${RESET}  %s\n" "-l <logfile>"  "Write full session log to file"
    printf "    ${C_CYAN}%-20s${RESET}  %s\n" "-x"            "HTTP check — verify live hosts via curl"
    printf "    ${C_CYAN}%-20s${RESET}  %s\n" "-s"            "Silent mode — output found subdomains only"
    printf "    ${C_CYAN}%-20s${RESET}  %s\n" "-v"            "Verbose — show all DNS attempts"
    printf "    ${C_CYAN}%-20s${RESET}  %s\n" "-p"            "Show author profile card & exit"
    printf "    ${C_CYAN}%-20s${RESET}  %s\n" "-h"            "Show this help message"
    echo
    echo -e "  $sep"
    echo -e "  ${C_WHITE}${BOLD}EXAMPLES${RESET}"
    echo -e "  $sep"
    echo -e "    ${C_GRAY}# Basic scan${RESET}"
    echo -e "    $(basename "$0") -d example.com -w wordlist.txt"
    echo
    echo -e "    ${C_GRAY}# Fast 50-thread scan with HTTP check and saved output${RESET}"
    echo -e "    $(basename "$0") -d target.com -w wordlist.txt -t 50 -x -o results.txt"
    echo
    echo -e "    ${C_GRAY}# Silent pipe-friendly output${RESET}"
    echo -e "    $(basename "$0") -d target.com -w wordlist.txt -s | tee subs.txt"
    echo
    echo -e "    ${C_GRAY}# Custom DNS resolver with verbose log${RESET}"
    echo -e "    $(basename "$0") -d target.com -w wl.txt -r 1.1.1.1 -v -l scan.log"
    echo
    echo -e "    ${C_GRAY}# View author profile card${RESET}"
    echo -e "    $(basename "$0") -p"
    echo
}

# ══════════════════════════════════════════════════════════════════════════════
# §6  LOGGING HELPERS
# ══════════════════════════════════════════════════════════════════════════════
_ts()  { date '+%H:%M:%S'; }

_log() {
    local level="$1" color="$2" icon="$3"
    shift 3
    if ! $SILENT || [[ "$level" == "FOUND" ]]; then
        printf "  %s${BOLD}[%s]${RESET} %s\n" "$color" "$icon" "$*"
    fi
    [[ -n "$LOG_FILE" ]] && printf "[%s] [%-5s] %s\n" "$(_ts)" "$level" "$*" >> "$LOG_FILE"
}

log_info()    { _log "INFO"  "$C_BLUE"    "*"  "$@"; }
log_ok()      { _log "OK"    "$C_GREEN"   "✓"  "$@"; }
log_warn()    { _log "WARN"  "$C_YELLOW"  "!"  "$@"; }
log_error()   { _log "ERROR" "$C_RED"     "✗"  "$@" >&2; }
log_verbose() { $VERBOSE && _log "VERB" "$C_DKGRAY" "~" "$@" || true; }

log_section() {
    $SILENT && return
    echo
    printf "  ${C_GOLD}${BOLD}  ▶  %-60s${RESET}\n" "$*"
    echo -e "  ${C_DKGRAY}$(printf '─%.0s' {1..68})${RESET}"
}

# ══════════════════════════════════════════════════════════════════════════════
# §7  ARGUMENT PARSING
# ══════════════════════════════════════════════════════════════════════════════
parse_args() {
    [[ $# -eq 0 ]] && { print_banner; usage; exit 0; }

    while getopts ":d:w:o:t:T:r:l:sxvph" opt; do
        case "$opt" in
            d) DOMAIN="${OPTARG}" ;;
            w) WORDLIST="${OPTARG}" ;;
            o) OUTPUT="${OPTARG}" ;;
            t) THREADS="${OPTARG}" ;;
            T) TIMEOUT="${OPTARG}" ;;
            r) DNS_SERVER="${OPTARG}" ;;
            l) LOG_FILE="${OPTARG}" ;;
            s) SILENT=true ;;
            x) HTTP_CHECK=true ;;
            v) VERBOSE=true ;;
            p) print_banner; print_author_profile; exit 0 ;;
            h) print_banner; usage; exit 0 ;;
            :) log_error "Option -${OPTARG} requires an argument."; usage; exit 1 ;;
           \?) log_error "Unknown option: -${OPTARG}"; usage; exit 1 ;;
        esac
    done

    [[ -z "$DOMAIN"   ]] && { log_error "Target domain required. Use -d <domain>";   exit 1; }
    [[ -z "$WORDLIST" ]] && { log_error "Wordlist required. Use -w <wordlist>";       exit 1; }
    [[ ! -f "$WORDLIST" ]] && { log_error "Wordlist not found: $WORDLIST";            exit 1; }

    if ! [[ "$THREADS" =~ ^[0-9]+$ ]] || [[ "$THREADS" -lt 1 ]]; then
        log_error "Threads must be a positive integer."; exit 1
    fi
    if ! [[ "$TIMEOUT" =~ ^[0-9]+$ ]] || [[ "$TIMEOUT" -lt 1 ]]; then
        log_error "Timeout must be a positive integer."; exit 1
    fi
}

# ══════════════════════════════════════════════════════════════════════════════
# §8  DEPENDENCY CHECK
# ══════════════════════════════════════════════════════════════════════════════
check_deps() {
    log_section "DEPENDENCY CHECK"
    local missing=() ok=()

    for cmd in dig host xargs awk grep sort wc date; do
        command -v "$cmd" &>/dev/null && ok+=("$cmd") || missing+=("$cmd")
    done
    $HTTP_CHECK && { command -v curl &>/dev/null && ok+=("curl") || missing+=("curl"); }

    log_info "Found     : ${ok[*]}"

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing: ${missing[*]}"
        log_warn  "Install: sudo apt install dnsutils curl"
        exit 1
    fi
    log_ok "All dependencies present."
}

# ══════════════════════════════════════════════════════════════════════════════
# §9  ENUMERATE ONE SUBDOMAIN  (exported — runs inside xargs subshell)
# ══════════════════════════════════════════════════════════════════════════════
enumerate_one() {
    local word="$1"  domain="$2"  tmpdir="$3"  http_flag="$4"
    local silent_flag="$5"  verbose_flag="$6"  timeout="$7"  dns_server="$8"

    local sub="${word}.${domain}"
    local ip=""

    # ── DNS via dig ─────────────────────────────────────────────────────────
    local dig_opts=(+short "+time=${timeout}" +tries=1)
    [[ -n "$dns_server" ]] && dig_opts+=("@${dns_server}")

    ip=$(dig "${dig_opts[@]}" "$sub" A 2>/dev/null \
        | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' \
        | head -1) || true

    # ── Fallback: host ───────────────────────────────────────────────────────
    if [[ -z "$ip" ]]; then
        ip=$(host -W "${timeout}" "$sub" 2>/dev/null \
            | awk '/has address/{print $NF; exit}') || true
    fi

    # ── Progress tick ────────────────────────────────────────────────────────
    printf '\n' >> "${tmpdir}/checked.tick"

    # ── Not found ────────────────────────────────────────────────────────────
    if [[ -z "$ip" ]]; then
        [[ "$verbose_flag" == "true" ]] && \
            printf "  \033[2m[~]\033[0m \033[38;5;238m%-44s NXDOMAIN\033[0m\n" "$sub"
        return 0
    fi

    # ── HTTP check ───────────────────────────────────────────────────────────
    local badge="" http_status="" proto_used=""
    if [[ "$http_flag" == "true" ]]; then
        local code proto
        for proto in http https; do
            local curl_flags=(-s -o /dev/null -w "%{http_code}"
                              --max-time "${timeout}"
                              --connect-timeout "${timeout}" -L)
            [[ "$proto" == "https" ]] && curl_flags+=(-k)
            code=$(curl "${curl_flags[@]}" "${proto}://${sub}" 2>/dev/null) || true
            if [[ "$code" =~ ^[2-4][0-9]{2}$ ]]; then
                http_status="$code"; proto_used="${proto^^}"; break
            fi
        done
        if [[ -n "$http_status" ]]; then
            local bc='\033[0;32m'
            [[ "$http_status" =~ ^3 ]] && bc='\033[0;33m'
            [[ "$http_status" =~ ^4 ]] && bc='\033[0;31m'
            badge="${bc}[${proto_used} ${http_status}]\033[0m"
        fi
    fi

    # ── Record ────────────────────────────────────────────────────────────────
    printf '%s\n' "$sub" >> "${tmpdir}/found.txt"

    # ── Display ───────────────────────────────────────────────────────────────
    if [[ "$silent_flag" == "true" ]]; then
        printf '%s\n' "$sub"
    else
        printf \
          "  \033[1;32m[✓]\033[0m \033[1;38;5;46m%-42s\033[0m  \033[38;5;245m%-18s\033[0m  %b\n" \
          "$sub" "$ip" "$badge"
    fi
}

export -f enumerate_one

# ══════════════════════════════════════════════════════════════════════════════
# §10  LIVE PROGRESS BAR
# ══════════════════════════════════════════════════════════════════════════════
show_progress() {
    local tmpdir="$1"  total="$2"
    local W=26  checked found elapsed pct filled empty bar speed eta

    while true; do
        checked=$(wc -l < "${tmpdir}/checked.tick" 2>/dev/null || echo 0)
        found=$(wc -l   < "${tmpdir}/found.txt"    2>/dev/null || echo 0)
        elapsed=$(( $(date +%s) - START_TIME ))
        [[ $elapsed -eq 0 ]] && elapsed=1

        pct=$(( checked * 100 / total ))
        [[ $pct -gt 100 ]] && pct=100
        filled=$(( pct * W / 100 ))
        empty=$(( W - filled ))

        bar="\033[38;5;51m\033[1m"
        for (( i=0; i<filled; i++ )); do bar+="█"; done
        bar+="\033[38;5;238m"
        for (( i=0; i<empty;  i++ )); do bar+="░"; done
        bar+="\033[0m"

        speed=$(( checked / elapsed ))
        [[ $speed -gt 0 ]] && eta=$(( (total - checked) / speed )) || eta="?"

        printf "\r  [%b] \033[38;5;220m\033[1m%3d%%\033[0m  \033[38;5;118m\033[1m%d found\033[0m  %d/%d checks  %d/s  ETA:%ss     " \
            "$bar" "$pct" "$found" "$checked" "$total" "$speed" "$eta"

        [[ $checked -ge $total ]] && break
        sleep 0.3
    done
    printf "\r%-90s\r" ""
}

# ══════════════════════════════════════════════════════════════════════════════
# §11  ENUMERATION ORCHESTRATOR
# ══════════════════════════════════════════════════════════════════════════════
run_enumeration() {
    WORK_DIR="$(mktemp -d /tmp/subenum.XXXXXX)"
    touch "${WORK_DIR}/found.txt" "${WORK_DIR}/checked.tick"

    TOTAL=$(grep -cv '^\s*\(#\|$\)' "$WORDLIST" 2>/dev/null || wc -l < "$WORDLIST")
    START_TIME=$(date +%s)

    log_section "SCAN CONFIGURATION"
    printf "  ${C_GRAY}  %-22s${RESET}  ${C_WHITE}${BOLD}%s${RESET}\n" \
        "Target Domain"    "$DOMAIN"
    printf "  ${C_GRAY}  %-22s${RESET}  ${C_WHITE}${BOLD}%s${RESET} (${TOTAL} entries)\n" \
        "Wordlist"         "$WORDLIST"
    printf "  ${C_GRAY}  %-22s${RESET}  ${C_WHITE}${BOLD}%s threads${RESET}\n" \
        "Parallelism"      "$THREADS"
    printf "  ${C_GRAY}  %-22s${RESET}  ${C_WHITE}${BOLD}%ss${RESET}\n" \
        "Timeout"          "$TIMEOUT"
    printf "  ${C_GRAY}  %-22s${RESET}  ${C_WHITE}${BOLD}%s${RESET}\n" \
        "DNS Resolver"     "${DNS_SERVER:-system default}"
    printf "  ${C_GRAY}  %-22s${RESET}  ${C_WHITE}${BOLD}%s${RESET}\n" \
        "HTTP Verify"      "$($HTTP_CHECK && echo "enabled" || echo "disabled")"
    [[ -n "$OUTPUT"   ]] && printf "  ${C_GRAY}  %-22s${RESET}  ${C_WHITE}${BOLD}%s${RESET}\n" "Output File" "$OUTPUT"
    [[ -n "$LOG_FILE" ]] && printf "  ${C_GRAY}  %-22s${RESET}  ${C_WHITE}${BOLD}%s${RESET}\n" "Log File"    "$LOG_FILE"

    log_section "LIVE RESULTS"

    if ! $SILENT; then
        printf "  ${C_DKGRAY}%-3s %-44s %-20s %s${RESET}\n" \
            ""  "SUBDOMAIN"  "IP ADDRESS"  "HTTP"
        echo -e "  ${C_DKGRAY}$(printf '─%.0s' {1..72})${RESET}"
    fi

    # ── Start progress monitor ─────────────────────────────────────────────
    if ! $SILENT; then
        show_progress "$WORK_DIR" "$TOTAL" &
        PROGRESS_PID=$!
    fi

    # ── Parallel DNS brute-force ───────────────────────────────────────────
    grep -v '^\s*#' "$WORDLIST" | grep -v '^\s*$' | \
        xargs -P "$THREADS" -I{} \
            bash -c 'enumerate_one "$@"' _ \
                {} "$DOMAIN" "$WORK_DIR" \
                "$HTTP_CHECK" "$SILENT" "$VERBOSE" \
                "$TIMEOUT" "$DNS_SERVER" 2>/dev/null

    # ── Stop progress monitor ──────────────────────────────────────────────
    if ! $SILENT && [[ -n "${PROGRESS_PID:-}" ]]; then
        sleep 0.5
        kill "$PROGRESS_PID" 2>/dev/null || true
        wait "$PROGRESS_PID" 2>/dev/null || true
    fi
}

# ══════════════════════════════════════════════════════════════════════════════
# §12  OUTPUT & FINAL REPORT
# ══════════════════════════════════════════════════════════════════════════════
handle_output() {
    FOUND=$(wc -l < "${WORK_DIR}/found.txt" 2>/dev/null | tr -d '[:space:]')
    local elapsed=$(( $(date +%s) - START_TIME ))
    local rate=0
    [[ $elapsed -gt 0 ]] && rate=$(( TOTAL / elapsed ))

    local SEP="${C_DKGRAY}${BOLD}$(printf '═%.0s' {1..72})${RESET}"
    local sep="${C_DKGRAY}$(printf '─%.0s' {1..72})${RESET}"

    if ! $SILENT; then
        echo
        echo -e "  $SEP"
        echo -e "  ${C_GOLD}${BOLD}  ✦  SCAN COMPLETE${RESET}"
        echo -e "  $sep"
        printf "  ${C_GRAY}  %-26s${RESET}  ${C_LIME}${BOLD}%s${RESET}\n" \
            "Subdomains Discovered"    "$FOUND"
        printf "  ${C_GRAY}  %-26s${RESET}  ${C_WHITE}${BOLD}%s${RESET}\n" \
            "Total Words Checked"      "$TOTAL"
        printf "  ${C_GRAY}  %-26s${RESET}  ${C_WHITE}${BOLD}%s seconds${RESET}\n" \
            "Elapsed Time"             "$elapsed"
        printf "  ${C_GRAY}  %-26s${RESET}  ${C_WHITE}${BOLD}%s checks/sec${RESET}\n" \
            "Average Speed"            "$rate"
        echo -e "  $sep"
    fi

    # ── Write output file ──────────────────────────────────────────────────
    if [[ -n "$OUTPUT" && "$FOUND" -gt 0 ]]; then
        sort -u "${WORK_DIR}/found.txt" > "$OUTPUT"
        log_ok "Results saved to: ${C_CYAN}${BOLD}${OUTPUT}${RESET}"
    fi

    # ── Write log file footer ──────────────────────────────────────────────
    if [[ -n "$LOG_FILE" ]]; then
        {
            printf '═%.0s' {1..60}; echo
            echo "SCAN SUMMARY"
            echo "Target  : $DOMAIN"
            echo "Found   : $FOUND"
            echo "Checked : $TOTAL"
            echo "Time    : ${elapsed}s"
            printf '─%.0s' {1..60}; echo
            echo "DISCOVERED SUBDOMAINS:"
            sort -u "${WORK_DIR}/found.txt" 2>/dev/null || true
            printf '═%.0s' {1..60}; echo
        } >> "$LOG_FILE"
        log_ok "Full log saved to: ${C_CYAN}${BOLD}${LOG_FILE}${RESET}"
    fi

    # ── Footer branding ────────────────────────────────────────────────────
    if ! $SILENT; then
        echo
        echo -e "  ${C_DKGRAY}  Created by ${C_CYAN}${BOLD}${AUTHOR}${RESET}${C_DKGRAY} · ${AUTHOR_GITHUB}${RESET}"
        echo -e "  ${C_DKGRAY}  ${AUTHOR_QUOTE}${RESET}"
        echo -e "  $SEP"
        echo
    fi
}

# ══════════════════════════════════════════════════════════════════════════════
# §13  CLEANUP & SIGNAL TRAPS
# ══════════════════════════════════════════════════════════════════════════════
cleanup() {
    [[ -n "${PROGRESS_PID:-}" ]] && kill "$PROGRESS_PID" 2>/dev/null || true
    [[ -n "${WORK_DIR:-}" && -d "${WORK_DIR}" ]] && rm -rf "${WORK_DIR}"
}

trap cleanup EXIT
trap 'echo; log_warn "Interrupted (SIGINT). Partial data may be saved."; exit 130' INT
trap 'log_warn "Terminated (SIGTERM)."; exit 143' TERM

# ══════════════════════════════════════════════════════════════════════════════
# §14  MAIN ENTRY POINT
# ══════════════════════════════════════════════════════════════════════════════
main() {
    parse_args "$@"
    print_banner
    check_deps
    run_enumeration
    handle_output
}

main "$@"

# ══════════════════════════════════════════════════════════════════════════════
#  EOF  SubEnum v2.0  ·  by SANJAIAJAIRATHINAM  ·  github.com/sanjaiajairathinam
#  "I do not just break systems — I build the next generation of defenders."
# ══════════════════════════════════════════════════════════════════════════════