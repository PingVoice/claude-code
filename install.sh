#!/usr/bin/env bash
#
# PingVoice Installer for Claude Code
# One-liner: curl -fsSL https://raw.githubusercontent.com/pingvoice/claude-code/master/install.sh | bash
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Voices available
VOICES=("Kore" "Puck" "Zephyr" "Charon" "Fenrir" "Aoede" "Leda" "Orus" "Perseus")

print_header() {
    echo ""
    echo -e "${BLUE}🔊 PingVoice Installer for Claude Code${NC}"
    echo "======================================"
    echo ""
}

print_success() {
    echo -e "  ${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "  ${RED}✗${NC} $1"
}

print_info() {
    echo -e "  ${YELLOW}→${NC} $1"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Check if running interactively (can read from terminal)
check_interactive() {
    if [ -t 0 ]; then
        return 0
    else
        # When piped from curl, we need to reopen stdin from the terminal
        exec < /dev/tty
        return 0
    fi
}

validate_api_key() {
    local api_key="$1"
    local response
    local http_code

    # Make a test request to the PingVoice API
    response=$(curl -s -w "\n%{http_code}" -X POST "https://pingvoice.io/api/tts" \
        -H "Authorization: Bearer ${api_key}" \
        -H "Content-Type: application/json" \
        -d '{"message": "API key validated"}' 2>/dev/null || echo -e "\n000")

    http_code=$(echo "$response" | tail -n1)

    if [ "$http_code" = "202" ]; then
        return 0
    elif [ "$http_code" = "401" ] || [ "$http_code" = "403" ]; then
        return 1
    elif [ "$http_code" = "000" ]; then
        print_error "Could not connect to PingVoice API. Check your internet connection."
        return 2
    else
        # Accept other codes as valid (might be rate limiting, etc.)
        return 0
    fi
}

detect_shell_profile() {
    local shell_name
    shell_name=$(basename "$SHELL")

    case "$shell_name" in
        zsh)
            echo "$HOME/.zshrc"
            ;;
        bash)
            if [ -f "$HOME/.bashrc" ]; then
                echo "$HOME/.bashrc"
            else
                echo "$HOME/.bash_profile"
            fi
            ;;
        *)
            # Default to bashrc
            echo "$HOME/.bashrc"
            ;;
    esac
}

add_to_profile() {
    local profile="$1"
    local var_name="$2"
    local var_value="$3"
    local export_line="export ${var_name}=\"${var_value}\""

    # Check if variable is already exported in profile
    if grep -q "^export ${var_name}=" "$profile" 2>/dev/null; then
        # Update existing line
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|^export ${var_name}=.*|${export_line}|" "$profile"
        else
            sed -i "s|^export ${var_name}=.*|${export_line}|" "$profile"
        fi
        return 1  # Updated existing
    else
        # Add new line
        echo "$export_line" >> "$profile"
        return 0  # Added new
    fi
}

main() {
    print_header
    check_interactive

    # Step 1: Check prerequisites
    echo "Checking prerequisites..."

    if check_command "claude"; then
        print_success "claude CLI found"
    else
        print_error "claude CLI not found"
        echo ""
        echo "Please install Claude Code first:"
        echo "  https://docs.anthropic.com/en/docs/claude-code"
        exit 1
    fi

    if check_command "uv"; then
        print_success "uv found"
    else
        print_error "uv not found"
        echo ""
        echo "Please install uv first:"
        echo "  curl -LsSf https://astral.sh/uv/install.sh | sh"
        exit 1
    fi

    echo ""

    # Step 2: Prompt for API key
    while true; do
        echo -n "Enter your PingVoice API key: "
        read -r PINGVOICE_API_KEY

        if [ -z "$PINGVOICE_API_KEY" ]; then
            print_error "API key is required"
            continue
        fi

        echo -n "  Validating..."
        if validate_api_key "$PINGVOICE_API_KEY"; then
            echo -e "\r                    \r"
            print_success "API key validated"
            break
        else
            echo -e "\r                    \r"
            print_error "Invalid API key. Please try again."
        fi
    done

    echo ""

    # Step 3: Prompt for user name (optional)
    echo -n "Enter your name (for personalized greetings) [skip]: "
    read -r PINGVOICE_USER_NAME

    if [ -n "$PINGVOICE_USER_NAME" ]; then
        print_success "Name set to: $PINGVOICE_USER_NAME"
    else
        print_info "Skipping personalized name"
    fi

    echo ""

    # Step 4: Voice selection
    echo "Select a voice (default: Kore):"
    for i in "${!VOICES[@]}"; do
        if [ "$i" -eq 0 ]; then
            echo "  $((i+1))) ${VOICES[$i]} (default)"
        else
            echo "  $((i+1))) ${VOICES[$i]}"
        fi
    done
    echo ""
    echo -n "Enter number [1]: "
    read -r voice_choice

    if [ -z "$voice_choice" ]; then
        voice_choice=1
    fi

    if [[ "$voice_choice" =~ ^[1-9]$ ]] && [ "$voice_choice" -le "${#VOICES[@]}" ]; then
        PINGVOICE_VOICE="${VOICES[$((voice_choice-1))]}"
        print_success "Voice set to: $PINGVOICE_VOICE"
    else
        PINGVOICE_VOICE="Kore"
        print_info "Invalid selection, using default: Kore"
    fi

    echo ""

    # Step 5: Install plugin
    echo "Installing plugin..."

    if claude plugin marketplace add pingvoice/claude-code 2>/dev/null; then
        print_success "Marketplace added"
    else
        print_info "Marketplace already added or updated"
    fi

    if claude plugin install pingvoice@pingvoice 2>/dev/null; then
        print_success "Plugin installed"
    else
        print_info "Plugin already installed or updated"
    fi

    echo ""

    # Step 6: Configure environment
    echo "Configuring environment..."

    PROFILE=$(detect_shell_profile)
    PROFILE_NAME=$(basename "$PROFILE")

    # Add a marker comment if not present
    if ! grep -q "# PingVoice Configuration" "$PROFILE" 2>/dev/null; then
        echo "" >> "$PROFILE"
        echo "# PingVoice Configuration" >> "$PROFILE"
    fi

    add_to_profile "$PROFILE" "PINGVOICE_API_KEY" "$PINGVOICE_API_KEY"

    if [ -n "$PINGVOICE_USER_NAME" ]; then
        add_to_profile "$PROFILE" "PINGVOICE_USER_NAME" "$PINGVOICE_USER_NAME"
    fi

    add_to_profile "$PROFILE" "PINGVOICE_API_VOICE_ID" "$PINGVOICE_VOICE"

    print_success "Added to ~/$PROFILE_NAME"

    # Export for current session
    export PINGVOICE_API_KEY
    export PINGVOICE_API_VOICE_ID="$PINGVOICE_VOICE"
    if [ -n "$PINGVOICE_USER_NAME" ]; then
        export PINGVOICE_USER_NAME
    fi

    echo ""

    # Step 7: Test TTS
    echo "Testing installation..."

    local test_message="Welcome to PingVoice!"
    if [ -n "$PINGVOICE_USER_NAME" ]; then
        test_message="Welcome to PingVoice, ${PINGVOICE_USER_NAME}!"
    fi

    local test_response
    test_response=$(curl -s -w "\n%{http_code}" -X POST "https://pingvoice.io/api/tts" \
        -H "Authorization: Bearer ${PINGVOICE_API_KEY}" \
        -H "Content-Type: application/json" \
        -d "{\"message\": \"${test_message}\", \"voiceId\": \"${PINGVOICE_VOICE}\"}" 2>/dev/null || echo -e "\n000")

    local test_code
    test_code=$(echo "$test_response" | tail -n1)

    if [ "$test_code" = "202" ]; then
        print_success "\"${test_message}\" - audio sent"
    else
        print_info "Test message sent (check your PingVoice Dashboard)"
    fi

    echo ""

    # Step 8: Success message
    echo "======================================"
    echo -e "${GREEN}✅ Installation complete!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal (or run: source ~/$PROFILE_NAME)"
    echo "  2. Open the PingVoice Dashboard in your browser"
    echo "  3. Start Claude Code and hear the greeting!"
    echo ""
    echo "To enable task summaries (optional):"
    echo "  Run /output-style in Claude Code and select 'pingvoice:TTS Summary'"
    echo ""
    echo "Docs: https://github.com/pingvoice/claude-code"
    echo ""
}

main
exit 0
