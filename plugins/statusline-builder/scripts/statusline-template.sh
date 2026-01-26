#!/bin/bash
# Statusline Builder - Generated statusline script
# Components: {{COMPONENTS}}

input=$(cat)

# Colors
RESET=$'\033[0m'
RED=$'\033[38;5;174m'
GREEN=$'\033[38;5;114m'
YELLOW=$'\033[38;5;179m'
BLUE=$'\033[38;5;153m'
LAVENDER=$'\033[1;38;5;183m'
MINT=$'\033[38;5;151m'
PEACH=$'\033[38;5;216m'
PINK=$'\033[38;5;218m'
CYAN=$'\033[38;5;117m'
GRAY=$'\033[38;5;248m'

SEP="${GRAY}|${RESET}"

# ==== COMPONENT: model ====
# {{BEGIN:model}}
MODEL=$(echo "$input" | jq -r '.model.display_name // .model.id // "Unknown"')
MODEL_LOWER=$(echo "$MODEL" | tr '[:upper:]' '[:lower:]')

case "$MODEL_LOWER" in
    *opus*)   MODEL_COLOR=$LAVENDER; MODEL_SYMBOL="✦" ;;
    *sonnet*) MODEL_COLOR=$BLUE;     MODEL_SYMBOL="◆" ;;
    *haiku*)  MODEL_COLOR=$MINT;     MODEL_SYMBOL="⬦" ;;
    *)        MODEL_COLOR=$RESET;    MODEL_SYMBOL="◆" ;;
esac

MODEL_DISPLAY="${MODEL_COLOR}${MODEL_SYMBOL} ${MODEL}${RESET}"
# {{END:model}}

# ==== COMPONENT: context ====
# {{BEGIN:context}}
read -r CONTEXT_SIZE INPUT_TOKENS CACHE_CREATE CACHE_READ < <(
    echo "$input" | jq -r '[
        .context_window.context_window_size // 0,
        .context_window.current_usage.input_tokens // 0,
        .context_window.current_usage.cache_creation_input_tokens // 0,
        .context_window.current_usage.cache_read_input_tokens // 0
    ] | @tsv'
)

PERCENT=0
if [ "$CONTEXT_SIZE" -gt 0 ] 2>/dev/null; then
    CURRENT_TOKENS=$((INPUT_TOKENS + CACHE_CREATE + CACHE_READ))
    PERCENT=$((CURRENT_TOKENS * 100 / CONTEXT_SIZE))
    [ "$PERCENT" -gt 100 ] && PERCENT=100
fi

BAR_WIDTH=15
FILLED=$((PERCENT * BAR_WIDTH / 100))

if [ "$PERCENT" -lt 50 ]; then
    BAR_COLOR=$GREEN
elif [ "$PERCENT" -lt 70 ]; then
    BAR_COLOR=$YELLOW
else
    BAR_COLOR=$RED
fi

printf -v FILLED_BAR '%*s' "$FILLED" ''
printf -v EMPTY_BAR '%*s' "$((BAR_WIDTH - FILLED))" ''
BAR="${BAR_COLOR}${FILLED_BAR// /█}${EMPTY_BAR// /░}${RESET}"

CONTEXT_DISPLAY="${BAR} ${PERCENT}%"
# {{END:context}}

# ==== COMPONENT: costs (daily_cost, monthly_cost) ====
# {{BEGIN:costs}}
SESSION_CACHE="/tmp/ccusage_session_cache.json"
DAILY_CACHE="/tmp/ccusage_daily_cache.json"
CACHE_AGE=60

fetch_ccusage() {
    local cache_file="$1"
    local command="$2"

    if [ -f "$cache_file" ]; then
        local file_age=$(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || echo 0)))
        if [ "$file_age" -lt "$CACHE_AGE" ]; then
            cat "$cache_file"
            return 0
        fi
    fi

    if command -v npx &>/dev/null; then
        local output
        if output=$(npx ccusage@latest "$command" --json 2>/dev/null) && [ -n "$output" ]; then
            echo "$output" > "$cache_file" 2>/dev/null
            echo "$output"
            return 0
        fi
    fi
    return 1
}

SESSION_OUTPUT=$(fetch_ccusage "$SESSION_CACHE" "session")
DAILY_OUTPUT=$(fetch_ccusage "$DAILY_CACHE" "daily")

if [ -n "$SESSION_OUTPUT" ]; then
    MONTHLY_COST=$(echo "$SESSION_OUTPUT" | jq -r '.totals.totalCost // 0')
    DAILY_COST=$(echo "$DAILY_OUTPUT" | jq -r '.daily[-1].totalCost // 0' 2>/dev/null || echo "0")

    # {{BEGIN:daily_cost}}
    DAILY_COST_DISPLAY="${YELLOW}📅 \$$(printf "%.2f" "$DAILY_COST")${RESET}"
    # {{END:daily_cost}}

    # {{BEGIN:monthly_cost}}
    MONTHLY_COST_DISPLAY="${PINK}Σ \$$(printf "%.2f" "$MONTHLY_COST")${RESET}"
    # {{END:monthly_cost}}
else
    COST_ERROR="${RED}⚠ ccusage: run 'npx ccusage@latest'${RESET}"
fi
# {{END:costs}}

# ==== COMPONENT: git ====
# {{BEGIN:git}}
GIT_DISPLAY=""
if git rev-parse --is-inside-work-tree &>/dev/null; then
    BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null ||
             git describe --tags --exact-match 2>/dev/null ||
             git rev-parse --short HEAD 2>/dev/null)

    DIRTY=""
    git diff --quiet 2>/dev/null && git diff --cached --quiet 2>/dev/null || DIRTY="*"
    [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ] && DIRTY="${DIRTY}+"

    GIT_DISPLAY="${CYAN}⎇ ${BRANCH}${RED}${DIRTY}${RESET}"
fi
# {{END:git}}

# ==== COMPONENT: directory ====
# {{BEGIN:directory}}
DIR_NAME=$(basename "$PWD")
DIR_DISPLAY="${YELLOW}📁 ${DIR_NAME}${RESET}"
# {{END:directory}}

# ==== COMPONENT: project ====
# {{BEGIN:project}}
PROJECT_NAME=""
for manifest in package.json Cargo.toml go.mod pyproject.toml; do
    [ -f "$manifest" ] || continue
    case "$manifest" in
        package.json)   PROJECT_NAME=$(jq -r '.name // empty' "$manifest" 2>/dev/null) ;;
        Cargo.toml)     PROJECT_NAME=$(grep -m1 '^name' "$manifest" 2>/dev/null | cut -d'"' -f2) ;;
        go.mod)         PROJECT_NAME=$(head -1 "$manifest" 2>/dev/null | awk '{print $2}' | xargs basename 2>/dev/null) ;;
        pyproject.toml) PROJECT_NAME=$(grep -m1 '^name' "$manifest" 2>/dev/null | cut -d'"' -f2) ;;
    esac
    [ -n "$PROJECT_NAME" ] && break
done

PROJECT_DISPLAY=""
[ -n "$PROJECT_NAME" ] && [ "$PROJECT_NAME" != "$DIR_NAME" ] && PROJECT_DISPLAY="${MINT}📦 ${PROJECT_NAME}${RESET}"
# {{END:project}}

# ==== COMPONENT: version ====
# {{BEGIN:version}}
VERSION_DISPLAY=""
if command -v claude &>/dev/null; then
    VERSION=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    [ -n "$VERSION" ] && VERSION_DISPLAY="${GRAY}v${VERSION}${RESET}"
fi
# {{END:version}}

# ==== BUILD OUTPUT ====
# {{BEGIN:output}}
OUTPUT=""

# {{OUTPUT:model}}
[ -n "$MODEL_DISPLAY" ] && OUTPUT="${MODEL_DISPLAY}"

# {{OUTPUT:context}}
[ -n "$CONTEXT_DISPLAY" ] && OUTPUT="${OUTPUT:+$OUTPUT $SEP }${CONTEXT_DISPLAY}"

# {{OUTPUT:daily_cost}}
if [ -n "$DAILY_COST_DISPLAY" ]; then
    OUTPUT="${OUTPUT:+$OUTPUT $SEP }${DAILY_COST_DISPLAY}"
elif [ -n "$COST_ERROR" ] && [ "{{HAS_COSTS}}" = "true" ]; then
    OUTPUT="${OUTPUT:+$OUTPUT $SEP }${COST_ERROR}"
fi

# {{OUTPUT:monthly_cost}}
[ -n "$MONTHLY_COST_DISPLAY" ] && OUTPUT="${OUTPUT:+$OUTPUT $SEP }${MONTHLY_COST_DISPLAY}"

# {{OUTPUT:git}}
[ -n "$GIT_DISPLAY" ] && OUTPUT="${OUTPUT:+$OUTPUT $SEP }${GIT_DISPLAY}"

# {{OUTPUT:directory}}
[ -n "$DIR_DISPLAY" ] && OUTPUT="${OUTPUT:+$OUTPUT $SEP }${DIR_DISPLAY}"

# {{OUTPUT:project}}
[ -n "$PROJECT_DISPLAY" ] && OUTPUT="${OUTPUT:+$OUTPUT $SEP }${PROJECT_DISPLAY}"

# {{OUTPUT:version}}
[ -n "$VERSION_DISPLAY" ] && OUTPUT="${OUTPUT:+$OUTPUT $SEP }${VERSION_DISPLAY}"

printf "%s" "$OUTPUT"
# {{END:output}}
