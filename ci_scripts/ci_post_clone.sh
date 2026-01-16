#!/bin/bash

# ci_post_clone.sh - Xcode Cloud post-clone script
# This script runs after Xcode Cloud clones the repository
#
# For XcodeGen projects: The .xcodeproj should be committed to the repository.
# This script can regenerate it if needed (requires XcodeGen to be installed).

set -e

echo "=== Xcode Cloud Post-Clone Script ==="
echo "Working directory: $(pwd)"
echo "CI Workspace: ${CI_WORKSPACE:-'not set'}"
echo "CI Primary Repository Path: ${CI_PRIMARY_REPOSITORY_PATH:-'not set'}"

# Navigate to the repository root
cd "${CI_PRIMARY_REPOSITORY_PATH:-$CI_WORKSPACE}"

echo ""
echo "=== Project Structure ==="
ls -la

# Check if the Xcode project exists
if [ -d "SocraticJournal.xcodeproj" ]; then
    echo ""
    echo "=== SocraticJournal.xcodeproj found ==="
    echo "Project is ready for build."
else
    echo ""
    echo "=== SocraticJournal.xcodeproj not found ==="
    echo "Attempting to generate project with XcodeGen..."

    # Check if XcodeGen is available
    if command -v xcodegen &> /dev/null; then
        echo "XcodeGen found, generating project..."
        xcodegen generate
    else
        echo "XcodeGen not found. Installing via Homebrew..."

        # Install Homebrew if not available
        if ! command -v brew &> /dev/null; then
            echo "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        # Install XcodeGen
        brew install xcodegen

        # Generate the project
        echo "Generating Xcode project..."
        xcodegen generate
    fi
fi

echo ""
echo "=== Post-Clone Complete ==="
