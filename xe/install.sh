#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Defaults / flags (can be overridden via CLI args or env)
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
FORCE_OVERWRITE=${FORCE_OVERWRITE:-0}
SKIP_OVERWRITE=${SKIP_OVERWRITE:-0}

# Helper function for colored output
echo_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Prompt helper that works even when stdin is not a TTY (e.g., curl | bash)
prompt_overwrite() {
    # Forced accept
    if [[ "$FORCE_OVERWRITE" == "1" ]]; then
        return 0
    fi

    # Forced decline
    if [[ "$SKIP_OVERWRITE" == "1" ]]; then
        return 1
    fi

    local prompt_msg="Do you want to overwrite it? (y/n): "

    # Interact with the user's terminal directly
    if [[ -e /dev/tty ]]; then
        printf "%s" "$prompt_msg" > /dev/tty
        local response
        # Read from the terminal, not from stdin (which may be a pipe)
        read -r response < /dev/tty || true
        if [[ "$response" =~ ^[Yy]$ ]]; then
            return 0
        else
            return 1
        fi
    fi

    # No TTY and not forced
    echo_color "$YELLOW" "⚠️  Non-interactive shell detected. Re-run with --yes to auto-overwrite or --no-overwrite to cancel."
    return 1
}

# Parse CLI arguments (works with: bash install.sh --yes, or curl ... | bash -s -- --yes)
while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--yes|--force)
            FORCE_OVERWRITE=1
            shift
            ;;
        -n|--no|--no-overwrite)
            SKIP_OVERWRITE=1
            shift
            ;;
        --install-dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        *)
            echo_color "$YELLOW" "⚠️  Ignoring unknown option: $1"
            shift
            ;;
    esac
done

# Main installation function
install_xe() {
    echo_color "$BLUE" "🚀 Installing xe - Web Development Script"
    echo ""
    
    # Check if running on macOS or Linux
    if [[ "$OSTYPE" != "darwin"* && "$OSTYPE" != "linux-gnu"* ]]; then
        echo_color "$RED" "❌ This installer only supports macOS and Linux"
        exit 1
    fi
    
    # Determine installation directory (can be overridden via --install-dir or env)
    INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
    
    # Check if we need sudo for /usr/local/bin
    if [[ -w "$INSTALL_DIR" ]]; then
        SUDO=""
    else
        SUDO="sudo"
        echo_color "$YELLOW" "⚠️  Installation to $INSTALL_DIR requires sudo permissions"
    fi
    
    # Create temporary directory
    TMP_DIR=$(mktemp -d)
    trap "rm -rf $TMP_DIR" EXIT
    
    echo_color "$BLUE" "📦 Downloading xe script..."
    
    # Download the xe script
    # Check if script is in the same directory (local install)
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    if [[ -f "$SCRIPT_DIR/xe" ]]; then
        # Local installation - copy from same directory
        echo_color "$GREEN" "✅ Found local xe script"
        cp "$SCRIPT_DIR/xe" "$TMP_DIR/xe"
    elif command -v curl &> /dev/null; then
        # Try to download from GitHub (you'll need to update this URL when hosted)
        GITHUB_RAW_URL="https://raw.githubusercontent.com/akdevv/micro-utils/main/xe/xe"
        curl -fsSL "$GITHUB_RAW_URL" -o "$TMP_DIR/xe" 2>/dev/null || {
            echo_color "$YELLOW" "⚠️  Could not download from GitHub, trying local file..."
            if [[ -f "./xe" ]]; then
                cp "./xe" "$TMP_DIR/xe"
            else
                echo_color "$RED" "❌ Could not find xe script"
                exit 1
            fi
        }
    elif command -v wget &> /dev/null; then
        GITHUB_RAW_URL="https://raw.githubusercontent.com/akdevv/micro-utils/main/xe/xe"
        wget -qO "$TMP_DIR/xe" "$GITHUB_RAW_URL" 2>/dev/null || {
            echo_color "$YELLOW" "⚠️  Could not download from GitHub, trying local file..."
            if [[ -f "./xe" ]]; then
                cp "./xe" "$TMP_DIR/xe"
            else
                echo_color "$RED" "❌ Could not find xe script"
                exit 1
            fi
        }
    else
        # No curl or wget, try local file
        if [[ -f "./xe" ]]; then
            cp "./xe" "$TMP_DIR/xe"
        else
            echo_color "$RED" "❌ Please install curl or wget, or run this script from the xe directory"
            exit 1
        fi
    fi
    
    # Make executable
    chmod +x "$TMP_DIR/xe"
    
    # Check if xe already exists
    if [[ -f "$INSTALL_DIR/xe" ]]; then
        echo_color "$YELLOW" "⚠️  xe is already installed at $INSTALL_DIR/xe"
        if ! prompt_overwrite; then
            echo_color "$RED" "❌ Installation cancelled"
            exit 1
        fi
    fi
    
    # Install xe
    echo_color "$BLUE" "📂 Installing xe to $INSTALL_DIR..."
    $SUDO mv "$TMP_DIR/xe" "$INSTALL_DIR/xe"
    
    # Verify installation
    if command -v xe &> /dev/null; then
        echo_color "$GREEN" "✅ xe has been successfully installed!"
        echo ""
        echo_color "$BLUE" "📋 Quick Start:"
        echo "  • Run 'xe --help' to see all available commands"
        echo "  • Run 'xe dev' to start your development server"
        echo "  • Run 'xe install' to install dependencies"
        echo ""
        echo_color "$GREEN" "🎉 Happy coding with xe!"
    else
        echo_color "$YELLOW" "⚠️  xe was installed but may not be in your PATH"
        echo_color "$YELLOW" "   Add $INSTALL_DIR to your PATH or use the full path: $INSTALL_DIR/xe"
    fi
}

# Run the installer
install_xe